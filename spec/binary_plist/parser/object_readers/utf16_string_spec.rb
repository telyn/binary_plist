# frozen_string_literal: true

require "support/object_reader"
require "binary_plist/parser/object_readers/utf16_string"
require "binary_plist/trailer"

RSpec.describe BinaryPList::Parser::ObjectReaders::UTF16String do
  describe ".reads?" do
    subject { described_class.reads?(marker) }

    include_examples "returns true when marker inside", (0b0110_0000..0b0110_1111)
  end

  describe "#read" do
    subject { described_class.new(nil, io, nil, trailer).read(marker) }

    include_examples "raises UnsupportedMarkerError when marker outside",
                     (0b0110_0000..0b0110_1111)

    let(:io) do
      # "€hello world!"
      StringIO.new("bplist00" + str)
    end
    before { io.seek(8) }
    let(:str) { main_str }
    let(:main_str) { "\x20\xAC\x00h\x00e\x00l\x00l\x00o\x00 \x00w\x00o\x00r\x00l\x00d\x00!" }
    let(:trailer) { BinaryPList::Trailer.new(0, 1, 1, 1, 0, 8 + str.length + 1) }

    let(:marker) { 0b0110_0000 | marker_length }

    context "when marker length is 0 characters" do
      let(:marker_length) { 0 }

      it { is_expected.to eq "" }
    end

    context "when marker length is 1 characters" do
      let(:marker_length) { 1 }

      it { is_expected.to eq "€" }
    end

    (2..12).each do |length|
      context "when marker length is #{length} characters" do
        let(:marker_length) { length }
        it { is_expected.to eq "€hello world!"[0,length] }
      end
    end

    context "when marker length is 13 characters" do
      let(:marker_length) { 13 }

      it { is_expected.to eq "€hello world!" }
    end

    context "when marker length is 14 characters" do
      let(:marker_length) { 14 }

      it "raises OffsetOutOfRangeError" do
        expect { subject }.to raise_error(BinaryPList::OffsetOutOfRangeError)
      end
    end

    context "when marker length is 0xF (15)" do
      let(:marker_length) { 0xF }
      let(:str) { length_int + main_str }
      let(:length_int) { [0b0001_0000, length_num].pack("C*") }

      context "when length_num is 0 characters" do
        let(:length_num) { 0 }

        it { is_expected.to eq "" }
      end

      context "when length_num is 1 characters" do
        let(:length_num) { 1 }

        it { is_expected.to eq "€" }
      end

      (2..12).each do |length|
        context "when length_num is #{length} characters" do
          let(:length_num) { length }

          it { is_expected.to eq "€hello world!"[0, length] }
        end
      end

      context "when length_num is 13 characters" do
        let(:length_num) { 13 }

        it { is_expected.to eq "€hello world!" }
      end

      context "when length_num is 14 characters" do
        let(:length_num) { 14 }

        it "raises OffsetOutOfRangeError" do
          expect { subject }.to raise_error(BinaryPList::OffsetOutOfRangeError)
        end
      end
    end
  end
end
