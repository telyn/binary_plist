# frozen_string_literal: true

require "binary_plist/parser/object_readers/base"

module BinaryPList
  module Parser
    module ObjectReaders
      class Null < Base
        def self.reads?(marker)
          (0..0).include?(marker)
        end

        def read(marker)
          raise UnsupportedMarkerError, marker unless self.class.reads?(marker)

          nil
        end
      end
    end
  end
end
