require "binary_plist/trailer"

RSpec.describe BinaryPList::Trailer do
  describe ".load" do
    subject { described_class.load(io) }

    let(:num_objs) { "\xDE\xAD\xBE\xEF\xBA\xAD\xF0\x0D" }
    let(:top_object) { "\xCA\xFE\xBA\xBE\xFE\xED\xFA\xCE" }
    let(:offset_table_offset) { "\xFE\xE1\xBA\xAD\xDE\xAD\xD0\x0D" }
    let(:io) do
      StringIO.new("\x01\x02\x03\x04\x05\x06\x07\x08" \
                   "#{num_objs}#{top_object}#{offset_table_offset}")
    end

    it do
      is_expected.to eql(BinaryPList::Trailer.new(
                           0x06,
                           0x07,
                           0x08,
                           0xDEADBEEFBAADF00D,
                           0xCAFEBABEFEEDFACE,
                           0xFEE1BAADDEADD00D
                         ))
    end
  end

  describe "#pack" do
    subject do
      BinaryPList::Trailer.new(0x06,
                               0x07,
                               0x08,
                               0xDEADBEEFBAADF00D,
                               0xCAFEBABEFEEDFACE,
                               0xFEE1BAADDEADD00D)
                          .pack
    end

    it do
      is_expected.to eq([
        0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x07, 0x08,
        0xDE, 0xAD, 0xBE, 0xEF, 0xBA, 0xAD, 0xF0, 0x0D,
        0xCA, 0xFE, 0xBA, 0xBE, 0xFE, 0xED, 0xFA, 0xCE,
        0xFE, 0xE1, 0xBA, 0xAD, 0xDE, 0xAD, 0xD0, 0x0D,
      ].pack("C*"))
    end
  end
end
