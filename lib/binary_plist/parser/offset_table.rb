# frozen_string_literal: true

module BinaryPList
  module Parser
    OutOfBoundsError = Class.new(StandardError)

    class OffsetTable
      def initialize(io, offset, int_size)
        @io = io
        @int_size = int_size
        @offset = offset

        pos = io.tell
        io.seek(-32, File::SEEK_END)
        @last_int_loc = io.tell - @int_size
        io.seek(pos)
      end

      def object_offset(num)
        seek(object_offset_location(num))
        read_arbitrary_int(int_size)
      end

      private

      attr_reader :io, :offset, :int_size

      def object_offset_location(num)
        offset + num * int_size
      end

      # TODO: refactor into helper module
      def read_arbitrary_int(len)
        bytes = io.read(len)
        bytes.split("").reduce(0) do |int, byte|
          (int << 8) | byte.unpack("C").first
        end
      end

      def seek(pos)
        raise OutOfBoundsError if @last_int_loc < pos

        @io.seek(pos)
      end
    end
  end
end
