require "support/object_reader"
require "binary_plist/parser/object_readers/null"

ORs = BinaryPList::Parser::ObjectReaders
RSpec.describe BinaryPList::Parser::ObjectReaders::Null do
  describe ".reads?" do
    subject { described_class.reads?(marker) }

    context "when marker is 0x00" do
      let(:marker) { 0x00 }

      it { is_expected.to be true }
    end

    (0x01..0xFF).each do |marker_value|
      context "when marker is 0x#{marker_value.to_s(16)}" do
        let(:marker) { marker_value }

        it { is_expected.to be false }
      end
    end
  end

  describe "#reads?" do
    subject { described_class.new(nil, nil, nil, nil).read(marker) }

    context "when marker is 0x00" do
      let(:marker) { 0x00 }

      it { is_expected.to be nil }
    end

    include_examples "raises UnsupportedMarkerError when marker outside", (0..0)
  end
end
