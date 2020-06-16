# frozen_string_literal: true

require "binary_plist/parser/object_readers/base"
require "binary_plist/parser/object_readers/int"

module BinaryPList
  module Parser
    module ObjectReaders
      class UTF16String < Base
        def self.reads?(marker)
          (0b0110_0000..0b0110_1111).include?(marker)
        end

        def read(marker)
          raise UnsupportedMarkerError, marker unless self.class.reads?(marker)

          @marker = marker

          read_bytes(string_length * 2)
            .force_encoding("UTF-16BE")
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
