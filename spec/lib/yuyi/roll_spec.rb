require 'spec_helper'

describe Yuyi::Roll do
  before do
    allow(Yuyi::Menu).to receive :add_roll
    allow(Yuyi::Menu).to receive :find_roll
    allow(Yuyi::Menu).to receive(:options).and_return({ :foo => 'menu option' })
    allow(Yuyi::Menu).to receive(:on_the_menu?).and_return false

    class Yuyi::TestRoll < Yuyi::Roll
      pre_install { :pre_install }
      install { :install }
      post_install { :post_install }
      uninstall { :uninstall }
      upgrade { :upgrade }
      installed? { :installed? }
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
    allow(Yuyi::Menu).to receive(:add_roll).and_call_original
    allow(Yuyi::Menu).to receive(:find_roll).and_call_original
    allow(Yuyi::Menu).to receive(:options).and_call_original
    allow(Yuyi::Menu).to receive(:on_the_menu?).and_call_original
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
    it 'should add the roll to the menu' do
      allow(Yuyi::Menu).to receive :add_roll

      class Yuyi::TestInheritRoll < Yuyi::Roll
        install {}
        uninstall {}
        upgrade {}
        installed? {}
      end

      expect(Yuyi::Menu).to have_received(:add_roll).with :roll_spec, Yuyi::TestInheritRoll
    end

    # DSL Methods
    #

    it 'should add dependencies' do
      expect(Yuyi::Menu).to have_received(:find_roll).with :foo
    end

    it 'should create a title' do
      expect(Yuyi::TestRoll.title).to eq 'Test Roll'
    end

    it 'should create a file name' do
      expect(Yuyi::TestRoll.file_name).to eq :roll_spec
    end

    it 'should respond to .pre_install' do
      expect(Yuyi::TestRoll.pre_install).to be_a Proc
    end

    it 'should respond to .install' do
      expect(Yuyi::TestRoll.install).to be_a Proc
    end

    it 'should respond to .post_install' do
      expect(Yuyi::TestRoll.post_install).to be_a Proc
    end

    it 'should respond to .uninstall' do
      expect(Yuyi::TestRoll.uninstall).to be_a Proc
    end

    it 'should respond to .upgrade' do
      expect(Yuyi::TestRoll.upgrade).to be_a Proc
    end

    it 'should respond to .installed?' do
      expect(Yuyi::TestRoll.installed?).to be_a Proc
    end

    it 'should return .dependencies' do
      expect(Yuyi::TestRoll.dependencies).to eq([:foo])
    end

    it 'should return .options' do
      expect(Yuyi::TestRoll.options[:foo][:default]).to eq 'foo default'
    end
  end

  context 'when initialized' do
    before do
      @test_roll = Yuyi::TestRoll.new
    end

    it 'should return the title' do
      expect(@test_roll.title).to eq 'Test Roll'
    end

    it 'should return the file_name' do
      expect(@test_roll.file_name).to eq :roll_spec
    end

    it 'should add dependencies' do
      expect(@test_roll.dependencies).to eq([:foo])
    end

    it 'should return the pre_install results' do
      expect(@test_roll.send(:pre_install)).to eq :pre_install
    end

    it 'should return the install results' do
      expect(@test_roll.send(:install)).to eq :install
    end

    it 'should return the post_install results' do
      expect(@test_roll.send(:post_install)).to eq :post_install
    end

    it 'should return the uninstall results' do
      expect(@test_roll.send(:uninstall)).to eq :uninstall
    end

    it 'should return the upgrade results' do
      expect(@test_roll.send(:upgrade)).to eq :upgrade
    end

    it 'should return the installed? boolean' do
      expect(@test_roll.send(:installed?)).to eq true
    end

    it 'should return options' do
      expect(@test_roll.options).to eq({
        :foo => 'menu option',
        :bar => 'bar default'
      })

      expect(@test_roll.option_defs).to eq({
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
      @roll = Yuyi::TestRoll.new
      allow(@roll).to receive(:install)
      allow(@roll).to receive(:uninstall)
      allow(@roll).to receive(:upgrade)
    end

    context 'when not installed' do
      before do
        allow(@roll).to receive(:installed?).and_return false
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
        allow(@roll).to receive(:installed?).and_return true
      end

      context 'when uninstall option is set' do
        before do
          allow(Yuyi::Menu).to receive(:options).and_return({ :uninstall => true })
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
          allow(@roll).to receive(:upgrade?).and_return true
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

describe 'Yuyi::RollModel' do
  before do
    allow(Yuyi::Menu).to receive(:add_roll)

    class Yuyi::FooRollModel < Yuyi::Roll
      def self.inherited  klass
        @@name = 'Foo Name'
        super klass
      end
    end

    class Yuyi::FooModelRoll < Yuyi::FooRollModel
      install do
        @@name
      end
    end
  end

  after do
    allow(Yuyi::Menu).to receive(:add_roll).and_call_original
  end

  it 'should not add the roll model' do
    class Yuyi::BarRollModel < Yuyi::Roll; end
    expect(Yuyi::Menu).to_not have_received(:add_roll).with :roll_spec, Yuyi::BarRollModel
  end

  it 'should add the inherited roll' do
    class Yuyi::FooInheritedRoll < Yuyi::FooRollModel; end
    expect(Yuyi::Menu).to have_received(:add_roll).with :roll_spec, Yuyi::FooInheritedRoll
  end

  it 'should use the roll model methods' do
    expect(Yuyi::FooModelRoll.new.send(:install)).to eq 'Foo Name'
  end
end
