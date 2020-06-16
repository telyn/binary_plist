require "binary_plist/parser/object_readers/base"

module BinaryPList
  module Parser
    module ObjectReaders
      class Array < Base
        def self.reads?(marker)
          return true if (0b1010_0000..0b1010_1111).include?(marker)

          false
        end

        def read(marker)
          raise UnsupportedMarkerError, marker unless self.class.reads?(marker)

          len = marker - 0b1010_0000
          puts "reading #{len.to_s(16)} objects"
          len.times.to_a.map do |i|
            object_ref = io.getbyte
            object(object_ref)
          end
        end
      end
    end
  end
end
