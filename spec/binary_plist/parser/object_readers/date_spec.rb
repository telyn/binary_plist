# frozen_string_literal: true

require "support/object_reader"
require "binary_plist/parser/object_readers/date"
require "binary_plist/trailer"

RSpec.describe BinaryPList::Parser::ObjectReaders::Date do
  describe ".reads?" do
    subject { described_class.reads?(marker) }

    include_examples "returns true when marker inside", (0b0011_0011..0b0011_0011)
  end

  describe "#read" do
    subject { described_class.new(nil, io, nil, trailer).read(marker) }

    include_examples "raises UnsupportedMarkerError when marker outside", (0b0011_0011..0b0011_0011)

    let(:io) do
      StringIO.new("bplist00" + str)
    end
    let(:str) do
      # Cocoa epoch: 157907045.0 or 2006-01-02 15:04:05 +00:00
      "A\xA2\xD2\xF0\xCA\x00\x00\x00"
    end
    before { io.seek(8) }
    let(:trailer) { BinaryPList::Trailer.new(0, 1, 1, 1, 0, 8 + 8) }

    let(:marker) { 0b0011_0011 }

    it { is_expected.to eq Time.new(2006, 1, 2, 15, 4, 5, "+00:00") }
  end
end
