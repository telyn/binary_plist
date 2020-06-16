# frozen_string_literal: true

require "binary_plist/parser/offset_table"

RSpec.describe BinaryPList::Parser::OffsetTable do
  subject(:table) { described_class.new(io, offset, int_size) }
  let(:io) { StringIO.new(str) }
  let(:offset) { 100 }
  let(:int_size) { 1 }
  let(:str) { ("\x00" * 100) + "\xFE\xED\xFA\xCE" + ("\x00" * 32) }

  describe "#object_offset" do
    subject { table.object_offset(num) }

    let(:num) { 0 }

    context "when num is 0" do
      let(:num) { 0 }

      it { is_expected.to eq 0xFE }
    end

    context "when num is 1" do
      let(:num) { 1 }

      it { is_expected.to eq 0xED }
    end

    context "when num is 2" do
      let(:num) { 2 }

      it { is_expected.to eq 0xFA }
    end

    context "when num is 3" do
      let(:num) { 3 }

      it { is_expected.to eq 0xCE }
    end

    context "when num is 4" do
      let(:num) { 4 }

      it { expect { subject }.to raise_error(BinaryPList::Parser::OutOfBoundsError) }
    end
  end
end
