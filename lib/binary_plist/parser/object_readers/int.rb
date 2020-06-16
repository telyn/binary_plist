# frozen_string_literal: true

require "binary_plist/parser/object_readers/base"

module BinaryPList
  module Parser
    module ObjectReaders
      class Int < Base
        def self.reads?(marker)
          (0b0001_0000..0b0001_1111).include?(marker)
        end

        def read(marker)
          raise UnsupportedMarkerError, marker unless self.class.reads?(marker)

          marker_length = marker & 0xF

          bytes_count = (1 << marker_length)
          # raise OffsetOutOfRangeError if outside_object_table?(io.tell + bytes_count)

          bytes = bytes_count.times.map { io.getbyte }

          bytes.reduce(0) do |acc, byte|
            (acc << 8) | byte
          end
        end
      end
    end
  end
end
