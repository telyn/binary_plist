TEST_DATA = {
  '0' => ["Cool Idea\n7", "abandoned\n1"]
}

def bplist_fixture(name)
  { bplist: IO.read(__dir__ + "/test-data/#{name}"),
    expected: TEST_DATA[name] }
end
