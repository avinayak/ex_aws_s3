defmodule ExAws.S3.Parsers.EventStream do
  @moduledoc false

  # Parses EventStream messages.

  # AWS encodes EventStream messages in binary as follows:
  # [      prelude     ][     headers   ][    payload    ][   message-crc  ]
  # |<--  12 bytes  -->|<-- variable -->|<-- variable -->|<--  4 bytes  -->|

  # This module parses this information and returns a struct with the prelude, headers and payload.
  # The prelude contains the total length of the message, the length of the headers,
  # the length of the prelude, the CRC of the message, and the length of the payload.

  # The headers are a map of header names to values.
  # The payload is the actual message data.
  # The message-crc is a CRC32 checksum of the message (excluding the message-crc itself).
  # Refer to https://docs.aws.amazon.com/AmazonS3/latest/API/RESTSelectObjectAppendix.html for more information.

  alias ExAws.S3.Parsers.EventStream.Message

  defp parse_message(chunk) do
    with {:ok, message} <- Message.parse(chunk) do
      message
    end
  end

  def parse_raw_stream(
        {:ok,
         %{
           stream: stream
         }}
      ) do
    stream
    |> Stream.map(&parse_message/1)
    |> Stream.filter(&Message.is_record?/1)
    |> Stream.map(&Message.get_payload/1)
  end
end
