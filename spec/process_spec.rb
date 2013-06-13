require 'spec_helper'

describe Tnnl::Process do

  describe ".list" do
    context "when there are no open tunnels" do
      it "returns an empty array" do
        Tnnl::Process.stub(:parse_process_list).and_return([])
        Tnnl::Process.list.should == []
      end
    end

    context "when there are open tunnels" do
      it "returns an array of Tnnl::Process instances" do
        Tnnl::Process.stub(:parse_process_list).and_return([["123", "tnnl[3000:fakehost:3000]"]])
        list = Tnnl::Process.list
        expect(list).to be_instance_of(Array)
        expect(list.first).to be_instance_of(Tnnl::Process)
      end
    end
  end

  describe ".kill_several" do
    it "finds processes by index and calls kill on them" do
      ps1 = double()
      ps2 = double()
      ps3 = double()
      ps1.should_receive(:kill)
      ps2.should_receive(:kill)
      ps3.should_receive(:kill).never
      Tnnl::Process.stub(:list).and_return([ps1, ps2, ps3])
      Tnnl::Process.kill_several(1,2)
    end
  end

  describe ".kill_all" do
    it "calls kill on all listed processes" do
      ps1 = double()
      ps2 = double()
      ps1.should_receive(:kill)
      ps2.should_receive(:kill)
      Tnnl::Process.stub(:list).and_return([ps1, ps2])
      Tnnl::Process.kill_all
    end
  end

  describe "#initialize" do
    it "casts pid to an integer" do
      expect(Tnnl::Process.new("123", "").pid).to eq(123)
    end
  end

  describe "#kill" do
    it "sends an INT signal to the process" do
      Process.should_receive(:kill).with('INT', 123)
      Tnnl::Process.new(123, "").kill
    end
  end

end
