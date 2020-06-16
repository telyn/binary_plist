# frozen_string_literal: true

require "support/test_data"
require "binary_plist/trailer"
require "binary_plist/parser/bplist00"

RSpec.describe BinaryPList::Parser::BPList00 do
  NULL_BPLIST = "bplist00\0\x08" + BinaryPList::Trailer.new(0, 1, 1, 1, 0, 9).pack
  subject(:parser) { described_class.new(arg) }

  describe "#parse" do
    subject { parser.parse }

    shared_examples_for "bplist00 parser" do
      context "when bplist contains one object" do
        context "which is null" do
          let(:bplist00) { NULL_BPLIST }

          it { is_expected.to eq nil }
        end
      end

      context "with test_data bplist0" do
        let(:test_data) { bplist_fixture("0") }
        let(:bplist00) { test_data[:bplist] }

        it { is_expected.to eq test_data[:expected] }
      end
    end

    context "when given a string" do
      let(:arg) { bplist00 }

      it_behaves_like "bplist00 parser"
    end

    context "when given an io" do
      let(:arg) { StringIO.new(bplist00) }

      it_behaves_like "bplist00 parser"
    end
  end
end
