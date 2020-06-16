module BinaryPList
  module Parser
    module ObjectReaders
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

        def object(ref)
          trailer.check_object_reference!(ref)

          read_object(offset_table.object_offset(ref))
        end

        def read_object(offset)
          trailer.check_object_offset!(offset)

          io.seek(offset)
          marker = io.getbyte

          reader = reader_for(marker)
          raise UnsupportedMarkerError, marker if reader.nil?

          reader.read(marker)
        end

        def reader_for(marker)
          @main_class.readers.find do |klass|
            klass.reads? marker
          end&.new(@main_class, io, offset_table, trailer)
        end

        def read_objref
          read_int(trailer.object_ref_size)
        end

        def read_int(size)
          size.times
              .map { read_byte }
              .reduce(0) do |acc, byte|
            (acc << 8) | byte
          end
        end

        def read_byte
          trailer.check_object_offset!(io.tell)
          io.getbyte
        end

        def read_bytes(bytes)
          return "" if bytes.zero?

          trailer.check_object_offset!(io.tell + bytes - 1)
          io.read(bytes)
        end


        attr_reader :offset_table, :trailer, :io
      end
    end
  end
end
