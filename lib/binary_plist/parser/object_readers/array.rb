require "binary_plist/parser/object_readers/base"
require "binary_plist/parser/object_readers/int"

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

          @marker = marker

          object_refs.map do |object_ref|
            object(object_ref)
          end
        end

        def object_refs
          array_length.times.map do
            read_objref
          end
        end

        def array_length
          if @marker == 0b1010_1111
            Int.new(nil, io, offset_table, trailer).read(io.getbyte)
          else
            @marker - 0b1010_0000
          end
        end
      end
    end
  end
end
