# frozen_string_literal: true

module BinaryPList
  # Error raised when attempting to reference an object.
  # When the reference number is larger than the number of objects specified in
  # the trailer.
  class ObjectOutOfRangeError < StandardError; end
  # Error raised when attempting to read an offset from outside the range it
  # should be in.
  # For example, if an array object says it is 12 bytes, but there're only 6
  # more bytes in the Object Table, then this error will be raised.
  class OffsetOutOfRangeError < StandardError; end

  Trailer = Struct.new(:sort_version,
                       :offset_int_size,
                       :object_ref_size,
                       :num_objects,
                       :top_object,
                       :offset_table_offset) do
    def self.load(io)
      bytes = io.is_a?(String) ? bytes : io.read(32)

      sort_version, offset_int_size, object_ref_size,
        num_objects, top_object, offset_table_offset =
        bytes.unpack("@5 CCC Q>3")

      Trailer.new(sort_version,
                  offset_int_size,
                  object_ref_size,
                  num_objects,
                  top_object,
                  offset_table_offset)
    end

    def pack
      [0, 0, 0, 0, 0, sort_version, offset_int_size, object_ref_size,
       num_objects, top_object, offset_table_offset].pack("C8Q>3")
    end

    def check_object_offset!(offset)
      return if object_table_range.include?(offset)

      raise OffsetOutOfRangeError, offset: offset, range: object_table_range
    end

    def check_object_reference!(ref)
      return unless num_objects < ref

      raise ObjectOutOfRangeError, num: num, max: trailer.num_objects
    end

    def object_table_range
      (8...offset_table_offset)
    end

    def offset_table_range
      (offset_table_offset..offset_table_offset + num_objects * offset_int_size)
    end
  end
end
