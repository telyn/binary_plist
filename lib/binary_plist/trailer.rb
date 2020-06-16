# frozen_string_literal: true

module BinaryPList
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
  end
end
