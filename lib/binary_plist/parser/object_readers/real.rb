# frozen_string_literal: true

require "binary_plist/parser/object_readers/base"

module BinaryPList
  module Parser
    module ObjectReaders
      class Real < Base
        def self.reads?(marker)
          (0b0010_0001..0b0010_1111).include?(marker)
        end

        def read(marker)
          raise UnsupportedMarkerError, marker unless self.class.reads?(marker)

          marker_length = marker & 0x7 # last 3 bits

          bytes_count = 2 ** marker_length

          read_real(bytes_count)
        end
      end
    end
  end
end
