require "binary_plist/parser/version"

module BinaryPlistParser
  class Error < StandardError; end
  class UnsupportedMarkerError < Error; end
end

require "binary_plist/parser/bplist00"
