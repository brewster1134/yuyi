$: << '../lib'
require 'spec_helper'
require 'yuyi'

Yuyi::Menu.new Yuyi.instance_variable_get('@path')

describe 'Roll Validator' do
  Yuyi::Menu.sources.each do |source|

    # require roll models first
    source.roll_models.each do |roll_model_name, roll_model_path|
      require roll_model_path
    end

    source_title = source.instance_variable_get('@name')

    describe source_title do
      source.rolls.each do |roll_name, roll_path|
        describe roll_name do
          before do
            # require roll_path
            load "#{roll_path}.rb", true
            @roll_class = Yuyi::Menu.rolls[roll_name].class
          end

          after do
            # unload class to test other sources of the same roll
            klass = @roll_class.to_s.scan(/[^:]+$/).first.to_sym
            Yuyi.send :remove_const, klass
          end

          it 'should define install' do
            expect(@roll_class.install).to be_a Proc
          end

          it 'should define uninstall' do
            expect(@roll_class.uninstall).to be_a Proc
          end

          it 'should define upgrade' do
            expect(@roll_class.upgrade).to be_a Proc
          end

          it 'should define installed?' do
            expect(@roll_class.installed?).to be_a Proc
          end
        end
      end
    end
  end
end
