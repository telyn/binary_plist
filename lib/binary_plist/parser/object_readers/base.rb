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

        # Read a date from the stream.
        #
        # @return [Time] The date read from the stream
        def read_date
          epoch_offset = read_double
          # Cocoa epoch starts at 2001-01-01 00:00:00 +0000
          cocoa_epoch = Time.new(2001, 1, 1, 0, 0, 0, "+00:00")
          cocoa_epoch + epoch_offset
        end

        # Read a big-endian float from the stream.
        #
        # @return [Float] The float read from the stream
        def read_float
          io.read(4).unpack('g')[0]
        end

        # Read a big-endian double from the stream.
        #
        # @return [Float] The double read from the stream
        def read_double
          io.read(8).unpack('G')[0]
        end

        # Read a big-endian float from the stream.
        #
        # @param [Integer] size Bytesize of the number (4 or 8)
        # @return [Float] The float read from the stream
        def read_real(size)
          case size
          when 4
            read_float
          when 8
            read_double
          else
            raise ArgumentError, "byte size must be 4 or 8 bytes (got: #{size})"
          end
        end

        attr_reader :offset_table, :trailer, :io
      end
    end
  end
end
