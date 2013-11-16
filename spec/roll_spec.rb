require 'spec_helper'

require_all_rolls

describe Yuyi::Roll do
  Yuyi::Rolls.class_var(:all_on_menu).each do |file_name, roll_class|
    describe roll_class do
      describe 'the class' do
        after :each do
          load "#{file_name}.rb"
        end

        it 'should call the title method' do
          expect(Yuyi::Roll).to receive(:title)
        end

        it 'should call the install method' do
          expect(Yuyi::Roll).to receive(:install)
        end
      end

      describe 'the instance' do
        let(:roll) { roll_class.new }

        before do
          # Prevent installs from actually running
          roll_class.any_instance.stub(:install).and_return(Proc.new {})
        end

        before :each do
          load "#{file_name}.rb"
        end

        it 'should have a title' do
          expect(roll.title).to be_an_instance_of String
        end

        it 'should have dependencies' do
          expect(roll.dependencies).to be_an_instance_of Array
        end

        it 'should have an install block' do
          expect(roll.install).to be_an_instance_of Proc
        end

        it 'should have an installed? block' do
          expect(roll.installed?).to be_a Boolean
        end
      end
    end
  end
end
