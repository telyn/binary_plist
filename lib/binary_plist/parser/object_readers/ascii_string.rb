# frozen_string_literal: true

require "binary_plist/parser/object_readers/base"
require "binary_plist/parser/object_readers/int"

module BinaryPList
  module Parser
    module ObjectReaders
      class ASCIIString < Base
        def self.reads?(marker)
          (0b0101_0000..0b0101_1111).include?(marker)
        end

        def read(marker)
          raise UnsupportedMarkerError, marker unless self.class.reads?(marker)

          @marker = marker

          read_bytes(string_length)
            .force_encoding("ASCII-8BIT")
            .encode("UTF-8")
        end

        def string_length
          @string_length ||= if (@marker & 0xF) == 0xF
                               Int.new(nil, io, offset_table, trailer)
                                  .read(read_byte)
                             else
                               @marker & 0xF
                             end
        end
      end
    end
  end
end
