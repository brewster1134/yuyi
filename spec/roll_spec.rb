require 'spec_helper'

describe Yuyi::Roll do
  context 'when testing the generic roll class' do
    subject(:roll_class) { RollTestClass }
    subject(:roll) { RollTestClass.new }

    before do
      class RollTestClass < Yuyi::Roll; end
      RollTestClass.any_instance.stub(:installed?).and_return(true)
    end

    describe '#initialize' do
      before do
        roll_class.any_instance.stub(:install).and_return(Proc.new {})
        roll_class.any_instance.stub(:installed?).and_return(true)
      end

      it 'should call #installed?' do
        expect(roll).to have_received(:installed?)
      end

      context 'when roll is already installed' do
        before do
          roll_class.any_instance.stub(:installed?).and_return(true)
        end

        it 'should not call install' do
          expect(roll).to_not receive(:install)
        end
      end

      context 'when roll is not already installed' do
        before do
          roll_class.any_instance.stub(:installed?).and_return(false)
        end

        it 'should call install' do
          expect(roll).to have_received(:install)
        end
      end
    end

    describe '#write_to_file' do
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
    end

    describe '#on_the_menu?' do
      before do
        Yuyi::Rolls.stub(:on_the_menu?)
        roll.on_the_menu? :foo
      end

      it 'should call Yuyi::Rolls.on_the_menu? method' do
        expect(Yuyi::Rolls).to have_received(:on_the_menu?)
      end
    end
  end

  context 'when testing each individual roll' do
    before do
      Yuyi::Roll.stub(:installed?).and_return(true)
    end

    Dir.glob(File.join Yuyi::ROLLS_DIR, '*.rb').each do |file_name|

      before do
        require file_name
      end

      describe File.basename(file_name, '.rb') do
        subject(:roll_class){ Yuyi::Rolls.class_var(:all_on_menu)[File.basename(file_name, '.rb')] }
        subject(:roll){ roll_class.new }

        describe 'the class' do
          after :each do
            load file_name
          end

          it 'should call the title method' do
            expect(Yuyi::Roll).to receive(:title)
          end

          it 'should call the install method' do
            expect(Yuyi::Roll).to receive(:install)
          end
        end

        describe 'the instance' do
          it 'should respond to #title' do
            expect(roll.title).to be_an_instance_of String
          end

          it 'should respond to #dependencies' do
            expect(roll.dependencies).to be_an_instance_of Array
          end

          it 'should respond to #install' do
            expect(roll.install).to be_an_instance_of Proc
          end

          it 'should respond to #installed?' do
            expect(roll.installed?).to be_a Boolean
          end
        end
      end
    end
  end
end
