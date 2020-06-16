require "binary_plist/parser/object_readers/base"
require "binary_plist/parser/object_readers/null"
require "binary_plist/parser/offset_table"

module BinaryPList
  module Parser
    class BPList00 < ObjectReaders::Base
      class << self
        def readers
          @readers ||= [
            ObjectReaders::Null,
          ]
        end
      end

      MAGIC = "bplist00"
      NotBPList00 = Class.new(StandardError)

      def initialize(io)
        io = StringIO.new(io) if io.is_a? String
        raise NotBPList00 unless io.read(MAGIC.length).eql? MAGIC

        @io = io
        super(self.class, io, offset_table, trailer)
      end

      def parse
        top_object
      end

      private

      def top_object
        object(trailer.top_object)
      end

      def offset_table
        @offset_table ||= OffsetTable.new(@io,
                                          trailer.offset_table_offset,
                                          trailer.offset_int_size)
      end

      def trailer
        @trailer ||=
          begin
            @io.seek(-32, File::SEEK_END)
            Trailer.load(io)
          end
      end
    end
  end
end
