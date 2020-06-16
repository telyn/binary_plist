RSpec.shared_examples_for "returns true when marker inside" do |range|
  UnsupportedMarkerError = BinaryPList::Parser::ObjectReaders::UnsupportedMarkerError
  (0x00...range.begin).each do |marker_value|
    context "when marker is 0x#{marker_value.to_s(16)}" do
      let(:marker) { marker_value }

      it { is_expected.to be false }
    end
  end

  range.each do |marker_value|
    context "when marker is 0x#{marker_value.to_s(16)}" do
      let(:marker) { marker_value }

      it { is_expected.to be true }
    end
  end

  ((range.end + 1)..0xFF).each do |marker_value|
    context "when marker is 0x#{marker_value.to_s(16)}" do
      let(:marker) { marker_value }

      it { is_expected.to be false }
    end
  end
end

RSpec.shared_examples_for "raises UnsupportedMarkerError when marker outside" do |range|
  UnsupportedMarkerError = BinaryPList::Parser::ObjectReaders::UnsupportedMarkerError
  (0x00...range.begin).each do |marker_value|
    context "when marker is 0x#{marker_value.to_s(16)}" do
      let(:marker) { marker_value }

      it "raises UnsupportedMarkerError" do
        expect { subject }.to raise_error(UnsupportedMarkerError)
      end
    end
  end

  ((range.end + 1 )..0xFF).each do |marker_value|
    context "when marker is 0x#{marker_value.to_s(16)}" do
      let(:marker) { marker_value }

      it "raises UnsupportedMarkerError" do
        expect { subject }.to raise_error(UnsupportedMarkerError)
      end
    end
  end
end
