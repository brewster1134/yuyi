require 'spec_helper'

describe Yuyi::Menu do
  describe '.initialize' do
    context 'when no path is specified' do
      let(:menu) { Yuyi::Menu.new }

      before do
        Yuyi::Menu.stub(:load).and_return({:foo => 'bar'})
        Yuyi::Menu.any_instance.stub(:load).and_return({:foo => 'bar'})
      end

      after do
        Yuyi::Menu.unstub(:load)
        Yuyi::Menu.any_instance.unstub(:load)
      end

      it 'should set the path' do
        # expect(menu.path).to eq '~/Documents/menu.yml'
        expect(menu.class.path).to eq '~/Documents/menu.yml'
      end

      it 'should set the object' do
        # expect(menu.object).to eq({:foo => 'bar'})
        expect(menu.class.object).to eq({:foo => 'bar'})
      end
    end

    context 'when a path is specified' do
      let(:menu) { Yuyi::Menu.new 'spec/fixtures/menu_load_path.yml' }

      it 'should set the path' do
        # expect(menu.path).to eq 'spec/fixtures/menu_load_path.yml'
        expect(menu.class.path).to eq 'spec/fixtures/menu_load_path.yml'
      end

      it 'should set the object' do
        # expect(menu.object).to eq({"menu_load_path"=>{"foo"=>"bar"}})
        expect(menu.class.object).to eq({"menu_load_path"=>{"foo"=>"bar"}})
      end
    end
  end
end
