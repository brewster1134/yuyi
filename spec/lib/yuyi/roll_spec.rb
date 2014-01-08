require 'spec_helper'

describe Yuyi::Roll do
  context 'class' do
    subject { RollTestClass }

    before do
      # Bypass actually requiring a file when dependency methods are called
      # Just add it straight to the @@classes object on the menu
      Yuyi::Menu.stub(:require_roll) do |roll|
        Yuyi::Menu.add_roll(roll, roll)
      end

      class RollTestClass < Yuyi::Roll
        install {}
        uninstall {}
        update {}
        installed? {}
        dependencies :foo
        add_dependencies :bar
      end
    end

    after do
      Yuyi::Menu.unstub(:require_roll)
    end

    it 'should create a title' do
      expect(subject.title).to eq 'Roll Test Class'
    end

    it 'should create a file name' do
      expect(subject.file_name).to eq :roll_spec
    end

    it 'should add the roll and its dependencies to the menu' do
      expect(Yuyi::Menu.class_var(:classes).keys).to include(:roll_spec, :foo, :bar)
    end

    # Test Methods
    #
    it 'should return .available_options' do
      expect(subject.available_options).to eq({})
    end

    it 'should return .dependencies' do
      expect(subject.dependencies).to eq([:foo, :bar])
    end

    it 'should respond to .installed?' do
      expect(subject.installed?).to be_a Proc
    end

    it 'should respond to .install' do
      expect(subject.install).to be_a Proc
    end

    it 'should respond to .update' do
      expect(subject.update).to be_a Proc
    end

    it 'should respond to .uninstall' do
      expect(subject.uninstall).to be_a Proc
    end

    context 'with no options' do
      before do
        Yuyi::Menu.stub(:object).and_return({ :roll_spec => nil })
      end

      after do
        Yuyi::Menu.unstub(:object)
      end

      it 'should have an empty hash of options' do
        expect(subject.options).to eq({})
      end
    end

    context 'with options' do
      before do
        Yuyi::Menu.stub(:object).and_return({ :roll_spec => { :foo => 'bar' }})
      end

      after do
        Yuyi::Menu.unstub(:object)
      end

      it 'should have return options' do
        expect(subject.options).to eq({ :foo => 'bar' })
      end

      context 'when options change' do
        before do
          Yuyi::Menu.stub(:object).and_return({ :roll_spec => { :bar => 'foo' }})
        end

        it 'should return the new options from the menu' do
          expect(subject.options).to eq({ :bar => 'foo' })
        end
      end
    end

    context 'when already installed' do
      before do
        subject.any_instance.stub(:installed?).and_return(true)
      end

      after do
        subject.new
        subject.any_instance.unstub(:installed?)
      end

      it 'should not call install' do
        expect_any_instance_of(subject).to_not receive(:install)
      end

      context 'when uninstall option is set' do
        before do
          subject.any_instance.stub(:options).and_return({ :uninstall => true })
        end

        after do
          subject.any_instance.unstub(:options)
        end

        it 'should not call .uninstall' do
          expect_any_instance_of(subject).to_not receive(:uninstall)
        end
      end

      context 'when uninstall option is not set' do
        before do
          subject.any_instance.stub(:options).and_return({})
        end

        after do
          subject.any_instance.unstub(:options)
        end

        it 'should call .update' do
          expect_any_instance_of(subject).to receive(:update)
        end

        it 'should not call .uninstall' do
          expect_any_instance_of(subject).to_not receive(:uninstall)
        end
      end
    end

    context 'when not already installed' do
      before do
        subject.any_instance.stub(:installed?).and_return(false)
      end

      after do
        subject.new
        subject.any_instance.unstub(:installed?)
      end

      it 'should call install' do
        expect_any_instance_of(subject).to receive(:install)
      end
    end
  end
end

# These are sanity tests for the actual rolls.
# These should reflect the development requirements for new rolls.
#
describe 'Rolls' do
  Dir.glob(File.join Yuyi::ROLLS_DIR, '*.rb').each do |file_name|
    require file_name

    # get the class name after roll is required
    roll_class = Yuyi::Menu.class_var(:classes)[File.basename(file_name, '.rb').to_sym]

    describe roll_class.title do
      before do
        # prevent `already initialized constant` warnings during testing
        roll_class.constants.each{ |c| roll_class.send(:remove_const, c) }
      end

      after do
        load file_name
      end

      # Smoke tests...
      #
      it 'should define .install' do
        expect(roll_class).to receive(:install){ |&block| expect(block).to be_a(Proc) }
      end

      it 'should define .uninstall' do
        expect(roll_class).to receive(:uninstall){ |&block| expect(block).to be_a(Proc) }
      end

      it 'should define .update' do
        expect(roll_class).to receive(:update){ |&block| expect(block).to be_a(Proc) }
      end

      it 'should define .installed?' do
        expect(roll_class).to receive(:installed?){ |&block| expect(block).to be_a(Proc) }
      end
    end
  end
end
