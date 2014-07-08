require 'spec_helper'

describe Yuyi::Roll do
  describe '.dependencies' do
    before do
      allow(Yuyi::Menu).to receive(:find_roll)
    end

    after do
      allow(Yuyi::Menu).to receive(:find_roll).and_call_original
    end

    it 'should call find dependency rolls' do
      expect(Yuyi::Menu).to receive(:find_roll).with :foo
      expect(Yuyi::Menu).to receive(:find_roll).with :bar
      Yuyi::Roll.dependencies :foo, :bar
    end
  end

  describe '.class_to_title' do
    it 'should render a title' do
      expect(Yuyi::Roll.class_to_title('Yuyi::RollModel::FooBar')).to eq 'Foo Bar'
    end
  end

  describe '.caller_to_file_name' do
    it 'should render a file name' do
      expect(Yuyi::Roll.caller_to_file_name(['/foo/bar/foo_bar.rb'])).to eq :foo_bar
    end
  end

  context 'when inherited' do
    before do
      allow(Yuyi::Menu).to receive(:add_roll)
    end

    after do
      allow(Yuyi::Menu).to receive(:add_roll).and_call_original
    end

    it 'should add the roll to the menu' do
      class RollSpecInheritedRoll < Yuyi::Roll; end
      expect(Yuyi::Menu).to have_received(:add_roll).with :roll_spec, RollSpecInheritedRoll
    end

    it 'should respond to title' do
      class RollSpecTitle < Yuyi::Roll; end
      expect(RollSpecTitle.title).to eq  'Roll Spec Title'
    end

    it 'should respond to file_name' do
      class RollSpecFileName < Yuyi::Roll; end
      expect(RollSpecFileName.file_name).to eq  :roll_spec
    end
  end

  describe 'instance' do
    before do
      allow(Yuyi::Menu).to receive(:add_roll)
      allow(Yuyi::Menu).to receive(:find_roll)

      class RollSpecInstance < Yuyi::Roll
        dependencies :foo, :bar
        installed? { false }
        pre_install { 'Pre Install' }
      end

      @roll = RollSpecInstance.new
    end

    after do
      allow(Yuyi::Menu).to receive(:add_roll).and_call_original
      allow(Yuyi::Menu).to receive(:find_roll).and_call_original
    end

    it 'should respond to pre_install' do
      expect(@roll.pre_install).to eq 'Pre Install'
    end

    it 'should respond to dependencies' do
      expect(@roll.dependencies).to eq [ :foo, :bar ]
    end
  end
end
