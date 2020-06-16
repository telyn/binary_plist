require "support/object_reader"
require "binary_plist/parser/object_readers/array"
require "binary_plist/parser/offset_table"
require "binary_plist/trailer"

BPL = BinaryPList
P = BinaryPList::Parser
RSpec.describe BinaryPList::Parser::ObjectReaders::Array do
  describe ".reads?" do
    subject { described_class.reads?(marker) }
    (0b0000_0000...0b1010_0000).each do |marker_value|
      context "when marker is 0x#{marker_value.to_s(16)}" do
        let(:marker) { marker_value }

        it { is_expected.to eq false }
      end
    end

    (0b1010_0000..0b1010_1111).each do |marker_value|
      context "when marker is 0x#{marker_value.to_s(16)}" do
        let(:marker) { marker_value }

        it { is_expected.to eq true }
      end
    end

    (0b1011_0000..0b1111_1111).each do |marker_value|
      context "when marker is 0x#{marker_value.to_s(16)}" do
        let(:marker) { marker_value }

        it { is_expected.to eq false }
      end
    end
  end

  describe "#read" do
    subject do
      described_class.new(main_class,
                          io,
                          fake_offset_table,
                          trailer)
                     .read(marker)
    end

    include_examples "raises UnsupportedMarkerError when marker outside",
                     (0b1010_0000..0b1010_1111)

    # this setup is all a bit complicated but basically object_offset(0) = 0,
    # object_offset(1) = 1.
    # The offsets are all relative to the beginning of the string passed to
    # StringIO.new - which is 256 uint8s, starting at 0 and increasing by 1 each
    # character.
    # The FakeObjectReader simply returns whatever marker it receives.
    #
    # When you put that all together you get a system where object(0) = 0,
    # object(1) = 1, and so on.
    #
    # It's going to struggle when it comes to reading more bytes though. Erm.
    class FakeObjectReader < P::ObjectReaders::Base
      def self.reads?(marker)
        true
      end

      def read(marker)
        marker
      end
    end

    let(:main_class) { Struct.new(:readers).new([FakeObjectReader]) }
    let(:fake_offset_table) do
      fake = double(P::OffsetTable)
      allow(fake).to(receive(:object_offset) do |x|
        puts "object_offset(#{x.inspect}) = #{x.inspect}"
        x
      end)
      fake
    end
    let(:bplist) { (0..255).to_a.pack("C*") + [marker].pack("C") + array_obj }
    let(:io) { StringIO.new(bplist) }
    let(:trailer) { BPL::Trailer.new(0, 1, object_ref_size, num_objects, 0, 0) }
    let(:object_ref_size) { 1 }
    # 256 numbers from 0..255 and 1 array
    let(:num_objects) { 257 }
    let(:array_obj) { "" }


    context "when object_ref_size is 1" do
      context "when array is [100, 200, 10, 20, 30]" do
        let(:array_obj) { [100, 200, 10, 20, 30].pack("C*") }

        context "with valid marker" do
          let(:marker) { 0b1010_0000 + marker_length }

          context "when marker_length is 0x0" do
            let(:marker_length) { 0 }

            it { is_expected.to eq [] }
          end

          context "when marker_length is 0x1" do
            let(:marker_length) { 0x01 }

            it { is_expected.to eq [100] }
          end

          context "when marker_length is 0x2" do
            let(:marker_length) { 0x02 }

            it { is_expected.to eq [100, 200] }
          end

          # we.. need to write the Int reader in order to get this baby goin
          xcontext "when marker_length is 0xF" do
            context "when length_num is " do
              it { is_expected.to eq [100, 200, 10, 20, 30] }
            end
          end
        end
      end
    end
