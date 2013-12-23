require 'spec_helper'

describe Yuyi::Roll do
  before do
    # Bypass actually requiring a file and just add it straight to the @@classes object on the menu
    Yuyi::Menu.stub(:require_roll) do |roll|
      Yuyi::Menu.add_roll(roll, roll)
    end

    class RollTestClass < Yuyi::Roll
      dependencies :foo
      add_dependencies :bar
    end
    RollTestClass.any_instance.stub(:installed?).and_return(true)
  end

  after do
    Yuyi::Menu.unstub(:require_roll)
    RollTestClass.any_instance.unstub(:installed?)
  end

  context 'when testing a generic roll' do
    describe 'class' do
      it 'should return a title' do
        expect(RollTestClass.title).to eq('Roll Test Class')
      end

      it 'should add the roll' do
        expect(Yuyi::Menu.class_var(:classes)[:roll_spec]).to eq RollTestClass
      end

      it 'should add dependencies' do
        expect(RollTestClass.dependencies).to eq([:foo, :bar])
      end

      context 'with no options' do
        before do
          Yuyi::Menu.stub(:object).and_return({ :roll_spec => nil })
        end

        after do
          Yuyi::Menu.unstub(:object)
        end

        it 'should have an empty hash of options' do
          expect(RollTestClass.options).to eq({})
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
          expect(RollTestClass.options).to eq({ :foo => 'bar' })
        end

        context 'when options change' do
          before do
            Yuyi::Menu.stub(:object).and_return({ :roll_spec => { :bar => 'foo' }})
          end

          it 'should return the new options from the menu' do
            expect(RollTestClass.options).to eq({ :bar => 'foo' })
          end
        end
      end
    end

    describe 'instance' do
      describe '.initialize' do
        after do
          RollTestClass.new
        end

        context 'when roll is already installed' do
          before do
            RollTestClass.any_instance.stub(:installed?).and_return(true)
          end

          it 'should not call install' do
            expect_any_instance_of(RollTestClass).to_not receive(:install)
          end
        end

        context 'when roll is not already installed' do
          before do
            RollTestClass.any_instance.stub(:installed?).and_return(false)
          end

          it 'should call install' do
            expect_any_instance_of(RollTestClass).to receive(:install)
          end
        end
      end
    end
  end

  context 'when testing the' do
    Dir.glob(File.join Yuyi::ROLLS_DIR, '*.rb').each do |file_name|
      # set menu object to empty hash to prevent errors if any rolls access it
      Yuyi::Menu.class_var(:object, {})

      require file_name
      roll_class = Yuyi::Menu.class_var(:classes)[File.basename(file_name, '.rb').to_sym]

      describe roll_class.title do
        let(:roll_class) { Yuyi::Menu.class_var(:classes)[File.basename(file_name, '.rb').to_sym] }
        let(:roll){ roll_class.new }

        before do
          # prevent `already initialized constant` warnings during testing
          roll_class.constants.each{ |c| roll_class.send(:remove_const, c) }
        end

        describe 'class' do
          before do
            Yuyi::Roll.stub(:install)
          end

          after do
            Yuyi::Roll.unstub(:install)
          end

          after :each do
            load file_name
          end

          # Test required roll methods here...
          #
          it 'should call the install method' do
            expect(Yuyi::Roll).to receive(:install)
          end
        end

        describe 'instance' do
          before do
            roll_class.stub(:dependencies).and_return([:foo])
            roll_class.stub(:install).and_return(Proc.new{'foo'})
            roll_class.stub(:installed?).and_return(Proc.new{true})
            roll_class.stub(:available_options).and_return({ :foo => 'bar' })
            load file_name
          end

          after do
            roll_class.unstub(:dependencies)
            roll_class.unstub(:install)
            roll_class.unstub(:installed?)
            roll_class.unstub(:available_options)
          end

          it 'should respond to #dependencies' do
            expect(roll_class).to receive(:dependencies)
            expect(roll.dependencies).to eq [:foo]
          end

          it 'should respond to #install' do
            expect(roll_class).to receive(:install)
            expect(roll.install).to eq 'foo'
          end

          it 'should respond to #installed?' do
            expect(roll_class).to receive(:installed?)
            expect(roll.installed?).to eq true
          end

          it 'should respond to #available_options' do
            expect(roll_class).to receive(:available_options)
            expect(roll.available_options).to eq({ :foo => 'bar' })
          end
        end
      end
    end
  end
end
