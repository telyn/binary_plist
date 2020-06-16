module BinaryPList
  module Parser
    module ObjectReaders
      class ObjectOutOfRangeError < StandardError; end
      class UnsupportedMarkerError < StandardError; end

      # In order for a subclass to be used by Base#read_object, it must do three
      # things:
      # 1) Be included in the main_class.readers
      # 2) Implement .reads?(marker) - which returns true when it can read the
      #    given marker
      # 3) Implement #read(marker) - which reads the given marker.
      class Base
        def initialize(main_class, io, offset_table, trailer)
          @main_class = main_class
          @io = io
          @offset_table = offset_table
          @trailer = trailer
        end

        # called in subclasses by #read_object.
        # at the beginning of #read,, the next byte read by any read calls to
        # #io will be the byte immediately following the marker byte.
        # @param [Integer] marker the marker byte
        # @return some object
        def read(marker)
          raise NotImplementedError
        end

        private

        def object(num)
          puts "object(#{num})"
          if num > trailer.num_objects
            raise ObjectOutOfRangeError, num: num, max: trailer.num_objects
          end

          read_object(offset_table.object_offset(num))
        end

        def read_object(offset)
          io.seek(offset)
          marker = io.getbyte

          reader = reader_for(marker)
          raise UnsupportedMarkerError, marker if reader.nil?

          reader.read(marker)
        end

        def reader_for(marker)
          @main_class.readers.first do |klass|
            klass.reads? marker
          end&.new(@main_class, io, offset_table, trailer)
        end

        attr_reader :offset_table, :trailer, :io
      end
    end
  end
end
