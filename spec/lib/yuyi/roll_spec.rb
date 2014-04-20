require 'spec_helper'

describe Yuyi::Roll do
  before do
    Yuyi::Menu.stub :add_roll
    Yuyi::Menu.stub :find_roll
    Yuyi::Menu.stub(:options).and_return({ :foo => 'menu option' })
    Yuyi::Menu.stub(:on_the_menu?).and_return false

    class TestRoll < Yuyi::Roll
      install {}
      uninstall {}
      upgrade {}
      installed? {}
      dependencies :foo
      options({
        :foo => {
          :description => 'Foo.',
          :example => 'foo example',
          :default => 'foo default',
          :required => true
        },
        :bar => {
          :description => 'Bar.',
          :example => 'bar example',
          :default => 'bar default'
        }
      })
    end
  end

  after do
    Yuyi::Menu.unstub :add_roll
    Yuyi::Menu.unstub :find_roll
    Yuyi::Menu.unstub :options
    Yuyi::Menu.unstub :on_the_menu?
  end

  context 'when inherited' do
    it 'should add the roll to the menu' do
      Yuyi::Menu.stub :add_roll

      class TestInheritRoll < Yuyi::Roll
        install {}
        uninstall {}
        upgrade {}
        installed? {}
      end

      expect(Yuyi::Menu).to have_received(:add_roll).with :roll_spec, TestInheritRoll
    end

    # DSL Methods
    #
    it 'should create a title' do
      expect(TestRoll.title).to eq 'Test Roll'
    end

    it 'should create a file name' do
      expect(TestRoll.file_name).to eq :roll_spec
    end

    it 'should add dependencies' do
      expect(Yuyi::Menu).to have_received(:find_roll).with :foo
    end

    it 'should respond to .install' do
      expect(TestRoll.install).to be_a Proc
    end

    it 'should respond to .uninstall' do
      expect(TestRoll.uninstall).to be_a Proc
    end

    it 'should respond to .upgrade' do
      expect(TestRoll.upgrade).to be_a Proc
    end

    it 'should respond to .installed?' do
      expect(TestRoll.installed?).to be_a Proc
    end

    it 'should return .dependencies' do
      expect(TestRoll.dependencies).to eq([:foo])
    end

    it 'should return .options' do
      expect(TestRoll.options[:foo][:default]).to eq 'foo default'
    end
  end

  context 'when initialized' do
    it 'should return the title' do
      expect(TestRoll.new.send(:title)).to eq 'Test Roll'
    end

    it 'should return the file_name' do
      expect(TestRoll.new.send(:file_name)).to eq :roll_spec
    end

    it 'should return options' do
      expect(TestRoll.new.options).to eq({
        :foo => 'menu option',
        :bar => 'bar default'
      })

      expect(TestRoll.new.option_defs).to eq({
        :foo => {
          :description => 'Foo.',
          :example => 'foo example',
          :default => 'foo default',
          :required => true
        },
        :bar => {
          :description => 'Bar.',
          :example => 'bar example',
          :default => 'bar default'
        }
      })
    end
  end

  context '#order' do
    before do
      @roll = TestRoll.new
      @roll.stub(:install)
      @roll.stub(:uninstall)
      @roll.stub(:upgrade)
    end

    context 'when not installed' do
      before do
        @roll.stub(:installed?).and_return false
        @roll.send :order
      end

      it 'should call install' do
        expect(@roll).to have_received :install
        expect(@roll).to_not have_received :uninstall
        expect(@roll).to_not have_received :upgrade
      end
    end

    context 'when installed' do
      before do
        @roll.stub(:installed?).and_return true
      end

      context 'when uninstall option is set' do
        before do
          Yuyi::Menu.stub(:options).and_return({ :uninstall => true })
          @roll.send :order
        end

        it 'should call uninstall' do
          expect(@roll).to_not have_received :install
          expect(@roll).to have_received :uninstall
          expect(@roll).to_not have_received :upgrade
        end
      end

      context 'when uninstall option is not set & upgrade is true' do
        before do
          @roll.stub(:upgrade?).and_return true
          @roll.send :order
        end

        it 'should call upgrade' do
          expect(@roll).to_not have_received :install
          expect(@roll).to_not have_received :uninstall
          expect(@roll).to have_received :upgrade
        end
      end
    end
  end
end
