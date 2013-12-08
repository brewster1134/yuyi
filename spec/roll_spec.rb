require 'spec_helper'

describe Yuyi::Roll do
  before do
    class RollTestClass < Yuyi::Roll; end
    RollTestClass.any_instance.stub(:install)
    RollTestClass.any_instance.stub(:installed?).and_return(true)
  end

  let(:roll_class) { RollTestClass }
  let(:roll) { RollTestClass.new }

  context 'when testing a generic roll' do
    describe 'class' do
      it 'should set the file_name' do
        expect(RollTestClass.file_name).to be_an_instance_of Symbol
      end

      it 'should add the roll' do
        expect(Yuyi::Rolls.class_var(:all_on_menu)[:roll_spec]).to eq RollTestClass
      end
    end

    describe 'instance' do
      describe '.initialize' do
        after do
          roll
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

    describe '.write_to_file' do
      before do
        roll.write_to_file 'test', 'foo'
      end

      after do
        FileUtils.rm 'test'
      end

      it 'should create a file if it doesnt exist' do
        expect(File.exists?('test')).to be_true
      end

      it 'should append to the file' do
        roll.write_to_file 'test', 'bar'
        expect(File.open('test').read).to eq "foo\nbar\n"
      end

      it 'should accept multiple text arguments' do
        roll.write_to_file 'test', 'array_one', 'array_two'
        expect(File.open('test').read).to eq "foo\narray_one\narray_two\n"
      end
    end

    describe '.on_the_menu?' do
      before do
        Yuyi::Rolls.stub(:on_the_menu?)
        roll.on_the_menu? :foo
      end

      after do
        Yuyi::Rolls.unstub(:on_the_menu?)
      end

      it 'should call Yuyi::Rolls.on_the_menu? method' do
        expect(Yuyi::Rolls).to have_received(:on_the_menu?)
      end
    end

    describe '.options' do
      before do
        RollTestClass.stub(:file_name).and_return('roll')
        Yuyi::Menu.stub(:object).and_return({ 'roll' => { :foo => :bar }})
      end

      after do
        Yuyi::Menu.unstub(:object)
      end

      it 'should return options form the menu' do
        expect(roll.options[:foo]).to eq :bar
      end
    end

    describe '.command?' do
      it 'should return true if command exists' do
        expect(roll.command?('ruby')).to eq true
        expect(roll.command?('rubyfoo')).to eq false
      end
    end
  end

  context 'when testing each individual roll' do
    Dir.glob(File.join Yuyi::ROLLS_DIR, '*.rb').each do |file_name|
      before do
        require file_name
      end

      describe File.basename(file_name, '.rb') do
        let(:roll_class) { Yuyi::Rolls.class_var(:all_on_menu)[File.basename(file_name, '.rb').to_sym] }
        let(:roll){ roll_class.new }

        before do
          # prevent `already initialized constant` warnings during testing
          roll_class.constants.each{ |c| roll_class.send(:remove_const, c) }
        end

        describe 'the class' do
          after :each do
            load file_name
          end

          # Test required roll methods here...
          #
          it 'should call the title method' do
            expect(Yuyi::Roll).to receive(:title)
          end

          it 'should call the install method' do
            expect(Yuyi::Roll).to receive(:install)
          end
        end

        describe 'the instance' do
          before do
            roll_class.stub(:title).and_return('Foo')
            roll_class.stub(:dependencies).and_return([:foo])
            roll_class.stub(:install).and_return(Proc.new{'foo'})
            roll_class.stub(:installed?).and_return(Proc.new{true})
            roll_class.stub(:available_options).and_return({ :foo => 'bar' })
            load file_name
          end

          it 'should respond to #title' do
            expect(roll_class).to receive(:title)
            expect(roll.title).to eq 'Foo'
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
