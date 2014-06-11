require 'spec_helper'

describe Yuyi::Menu do
  before do
    @menu = Yuyi::Menu.new 'spec/fixtures/menu.yaml'
  end

  describe '.load_from_file' do
    before do
      Yuyi::Menu.load_from_file 'spec/fixtures/menu2.yaml'
    end

    it 'should update the menu object' do
      expect(@menu.object[:rolls][:foo_roll]).to eq({ :bar => 'foo' })
    end
  end

  describe '.add_roll' do
    before do
      class MenuAddRollRoll; end
      Yuyi::Menu.add_roll :menu_add_roll_roll, MenuAddRollRoll
    end

    it 'should add a roll instance' do
      expect(Yuyi::Menu.instance_var(:rolls)[:menu_add_roll_roll]).to be_a MenuAddRollRoll
    end
  end

  describe '#initialize' do
    it 'should set the path var' do
      expect(@menu.var(:path)).to eq 'spec/fixtures/menu.yaml'
    end

    it 'should set the instance on the menu class' do
      expect(Yuyi::Menu.instance).to eq @menu
    end

    it 'should set the object var' do
      expect(Yuyi::Menu.instance_var(:object)[:sources][0]).to eq({ :local => 'spec/fixtures/roll_dir' })
      expect(Yuyi::Menu.instance_var(:object)[:sources][1]).to eq({ :yuyi => 'spec/fixtures/roll_zip.zip' })
      expect(Yuyi::Menu.instance_var(:object)[:rolls][:foo_roll]).to eq({ :foo => 'bar' })
    end

    context 'with an invalid path' do
      before do
        @menu = Yuyi::Menu.new 'foo'
      end

      it 'should not update menu state' do
        expect(Yuyi::Menu).to_not eq @menu
      end

      it 'should have a nil object' do
        expect(Yuyi::Menu.instance_var(:object)).to be_nil
      end
    end
  end

  describe '#set_sources' do
    before do
      Yuyi::Menu.instance_var :object, { :sources => [{ :foo_source => 'foo/path' }]}

      class FooSource; end
      allow(Yuyi::Source).to receive(:new).and_return FooSource

      @menu.send :set_sources
    end

    it 'should set the sources var' do
      expect(@menu.var(:sources).size).to eq(1)
      expect(@menu.var(:sources)[0]).to eq FooSource
    end
  end

  describe '#find_roll' do
    before do
      allow(@menu).to receive :require_roll
    end

    context 'when a source is specified' do
      before do
        @menu.send :find_roll, :foo_roll, { :source => 'foo_source' }
      end

      it 'should require the specific roll' do
        expect(@menu).to have_received(:require_roll).once.with(:foo_roll, 'foo_source/foo_roll')
      end
    end

    context 'when no source is specified' do
      before do
        class TestSourceA; end
        class TestSourceB; end
        allow(TestSourceA).to receive(:available_rolls).and_return({ :foo_roll => 'foo_roll' })
        allow(TestSourceB).to receive(:available_rolls).and_return({ :bar_roll => 'bar_roll' })

        @menu.var :sources, [TestSourceA, TestSourceB]
      end

      it 'should require the first roll found' do
        expect(@menu).to receive(:require_roll).once.with(:bar_roll, 'bar_roll')
        @menu.send :find_roll, :bar_roll
      end
    end

    context 'when no roll is found' do
      before do
        class TestSource; end
        allow(TestSource).to receive(:available_rolls).and_return({})

        @menu.var :sources, [TestSource]
      end

      it 'should not attempt to require a roll' do
        expect(@menu).to_not receive(:require_roll)
        @menu.send :find_roll, :no_roll
      end
    end
  end

  describe '#on_the_menu?' do
    before do
      allow(@menu).to receive(:object).and_return({ :rolls => { :foo => nil }})
    end

    it 'should return true if on the menu' do
      expect(@menu.on_the_menu?(:foo)).to be true
    end
  end

  describe '#sorted_rolls' do
    before do
      class DependencyRoll
        def dependencies; ['foo', 'bar']; end
      end
      class EmptyDependencyRoll
        def dependencies; []; end
      end
      allow(@menu).to receive(:rolls).and_return({ :dependency_roll => DependencyRoll.new, :foo => EmptyDependencyRoll.new, :bar => EmptyDependencyRoll.new })
    end

    it 'should add the roll to the class var' do
      expect(@menu.send(:sorted_rolls).sort_by { |sym| sym.to_s }).to eq([:bar, :dependency_roll, :foo])
    end
  end

  describe '#order_rolls' do
    before do
      class OrderRollsRoll; end
      allow(OrderRollsRoll).to receive :order

      allow(@menu).to receive(:sorted_rolls).and_return([:order_rolls_roll])
      allow(@menu).to receive(:rolls).and_return({ :order_rolls_roll => OrderRollsRoll })
    end

    after do
      @menu.send :order_rolls
    end

    it 'should initialize a roll with the roll options' do
      expect(OrderRollsRoll).to receive :order
    end
  end
end
