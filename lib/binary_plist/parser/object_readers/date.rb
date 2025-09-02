# frozen_string_literal: true

require "binary_plist/parser/object_readers/base"

module BinaryPList
  module Parser
    module ObjectReaders
      class Date < Base
        def self.reads?(marker)
          # Per: https://web.archive.org/web/20120605072625/http://opensource.apple.com/source/CF/CF-635/CFBinaryPList.c
          marker == 0b0011_0011
        end

        def read(marker)
          raise UnsupportedMarkerError, marker unless self.class.reads?(marker)
          read_date
        end
      end
    end
  end
end
