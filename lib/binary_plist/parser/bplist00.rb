# frozen_string_literal: true

require "binary_plist/trailer"
require "binary_plist/parser/offset_table"

require "binary_plist/parser/object_readers/base"
require "binary_plist/parser/object_readers/array"
require "binary_plist/parser/object_readers/ascii_string"
require "binary_plist/parser/object_readers/int"
require "binary_plist/parser/object_readers/null"
require "binary_plist/parser/object_readers/utf16_string"

module BinaryPList
  module Parser
    class BPList00 < ObjectReaders::Base
      class << self
        def readers
          @readers ||= [
            ObjectReaders::ASCIIString,
            ObjectReaders::Array,
            ObjectReaders::Int,
            ObjectReaders::Null,
            ObjectReaders::UTF16String,
          ]
        end
      end

      MAGIC = "bplist00"
      NotBPList00 = Class.new(StandardError)

      def initialize(io)
        io = StringIO.new(io) if io.is_a? String
        raise NotBPList00 unless io.read(MAGIC.length).eql? MAGIC

        @io = io
        super(self.class, io, nil, nil)
      end

      def parse
        object(trailer.top_object)
      end

      private

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
