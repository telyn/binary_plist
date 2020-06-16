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

    # This setup is all a bit complicated but basically object_offset(0) = 0,
    # object_offset(1) = 1 - for the first 256 objects.
    # The data stored at object_offset(0) is a single byte: 0. And at
    # object_offset(1) is a also a single byte: 1. Let's call those 256 bytes
    # `ints`. FakeObjectReader is the only object reader in fake_main_class's
    # `readers` array - and it just returns the marker byte - so object(0)
    # returns 0, object(1) returns 1, and so on.
    #
    # The string in the IO object the parser has is made up of these blocks:
    # ------------------------------------------
    # | 'bplist00' | ints | marker | ^array_obj |
    # ------------------------------------------
    #
    # The offset table and the trailer are entirely virtual - not in the io
    # object we're sending through. We don't need a real one - since we only
    # need to test that the array object reads the object refs correctly and
    # calls object() for each one.
    # The current offset of `io` is right at the beginning of array_obj
    # (i.e. the byte after `marker`)
    # Strictly speaking the marker doesn't need to be there. 'bplist00' is only
    # included so that everything plays nicely with Trailer#check_object_offset!
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
        x + 8
      end)
      fake
    end
    let(:bplist) { "bplist00" + (0..255).to_a.pack("C*") + [marker].pack("C") + array_obj }
    let(:io) { StringIO.new(bplist) }
    before { io.seek(8) }
    let(:trailer) { BPL::Trailer.new(0, 1, object_ref_size, num_objects, 0, offset_table_offset) }
    let(:offset_table_offset) { bplist.length }
    let(:object_ref_size) { 1 }
    # 256 numbers from 0..255 and 1 array
    let(:num_objects) { 257 }
    let(:array_obj) { "" }

    context "when object_ref_size is 1" do
      context "when array is [100, 200, 10, 20, 30]" do
        let(:array_obj) { [100, 200, 10, 20, 30].pack("C*") }
        before { io.seek(-array_obj.length, File::SEEK_END) }

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
          context "when marker_length is 0xF" do
            let(:marker_length) { 0xF }
            let(:array_obj) { length_int + [100, 200, 10, 20, 30].pack("C*") }
            let(:length_int) { [0b0001_0000, length_num].pack("C*") }


            context "when length_num is 1" do
              let(:length_num) { 1 }

              it { is_expected.to eq [100] }
            end

            context "when length_num is 2" do
              let(:length_num) { 2 }

              it { is_expected.to eq [100, 200] }
            end

            context "when length_num is 3" do
              let(:length_num) { 3 }

              it { is_expected.to eq [100, 200, 10] }
            end

            context "when length_num is 5" do
              let(:length_num) { 4 }

              it { is_expected.to eq [100, 200, 10, 20] }
            end

            context "when length_num is 5" do
              let(:length_num) { 5 }

              it { is_expected.to eq [100, 200, 10, 20, 30] }
            end
          end
        end
      end
    end
  end
end
