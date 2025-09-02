# frozen_string_literal: true

require "support/object_reader"
require "binary_plist/parser/object_readers/real"
require "binary_plist/trailer"

RSpec.describe BinaryPList::Parser::ObjectReaders::Real do
  describe ".reads?" do
    subject { described_class.reads?(marker) }

    include_examples "returns true when marker inside", (0b0010_0001..0b0010_1111)
  end

  describe "#read" do
    subject { described_class.new(nil, io, nil, trailer).read(marker) }

    include_examples "raises UnsupportedMarkerError when marker outside", (0b0010_0001..0b0010_1111)

    let(:io) do
      StringIO.new("bplist00" + str)
    end
    let(:str) do
      # 157907045.0 as a 64-bit float
      "A\xA2\xD2\xF0\xCA\x00\x00\x00"
    end
    before { io.seek(8) }

    let(:trailer) { BinaryPList::Trailer.new(0, 1, 1, 1, 0, 8 + 8) }

    let(:marker) { 0b0010_0011 } # 64-bit float

    it { is_expected.to eq(157907045.0) }
  end
end
