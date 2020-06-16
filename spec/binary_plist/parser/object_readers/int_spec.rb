# frozen_string_literal: true

require "support/object_reader"
require "binary_plist/parser/object_readers/int"

RSpec.describe BinaryPList::Parser::ObjectReaders::Int do
  describe ".reads?" do
    subject { described_class.reads?(marker) }

    include_examples "returns true when marker inside", (0b0001_0000..0b0001_1111)
  end

  describe "#read" do
    subject { described_class.new(nil, io, nil, nil).read(marker) }
    let(:io) { StringIO.new(str) }
    let(:str) { "" }

    include_examples "raises UnsupportedMarkerError when marker outside",
                     (0b0001_0000..0b0001_1111)

    let(:marker) { 0b0001_0000 + marker_length }

    context "when marker_length is 0" do
      let(:marker_length) { 0 }
      let(:str) { "\xC0" }

      it { is_expected.to be 0xC0 }
    end

    # int len = 2^1 == 2 bytes
    context "when marker_length is 1" do
      let(:marker_length) { 1 }
      let(:str) { "\xC0\x01" }

      it { is_expected.to eq 0xC001 }
    end

    # int len = 2^2 == 4 bytes
    context "when marker_length is 2" do
      let(:marker_length) { 2 }
      let(:str) { "\xC0\x01\xCA\xFE" }

      it { is_expected.to eq 0xC001CAFE }
    end

    # int len = 2^3 == 8 bytes
    context "when marker_length is 3" do
      let(:str) { "\xC0\x01\xCA\xFE\xBA\xAD\xD0\x0D" }
      let(:marker_length) { 3 }

      it { is_expected.to eq 0xC001CAFEBAADD00D }
    end
  end
end
