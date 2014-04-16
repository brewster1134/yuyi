require 'spec_helper'

describe Yuyi::Menu do
  before do

    # stub requring a roll
    # we need to initialize multiple menus, but the roll will only be required once (and therefore the inherited method will once run once)
    Yuyi::Menu.any_instance.stub(:require_roll)
    @menu = Yuyi::Menu.new 'spec/fixtures/menu.yaml'

    # mock the rolls variable since we arent requiring any rolls
    @menu.var :rolls, { :foo_roll => 'FooRoll' }
  end

  after do
    Yuyi::Menu.any_instance.unstub(:require_roll)
  end

  describe '#initialize' do
    it 'should set the instance class var' do
      expect(Yuyi::Menu.var(:instance)).to eq @menu
    end

    it 'should set the path var' do
      expect(@menu.var(:path)).to eq 'spec/fixtures/menu.yaml'
    end

    it 'should set the object var' do
      expect(@menu.var(:object)[:sources][:yuyi]).to eq 'spec/fixtures/roll_zip.zip'
      expect(@menu.var(:object)[:rolls][:foo_roll]).to eq({ :foo => 'bar' })
    end

    it 'should set the sources var' do
      expect(@menu.var(:sources)[:yuyi]).to be_a Yuyi::Source
    end
  end

  describe '#load_from_file' do
    before do
      @menu.var :path, 'spec/fixtures/menu2.yaml'
      @menu.send :load_from_file
    end

    it 'should reload the menu' do
      expect(@menu.var(:object)[:rolls][:foo_roll]).to eq({ :bar => 'foo' })
    end
  end

  describe '#find_roll' do
    context 'when a source is specified' do
      before do
        @menu.var :object, { :rolls => { :foo_roll => { :source => 'foo_source' }}}
        @menu.send :find_roll, :foo_roll
      end

      it 'should require the specific roll' do
        expect(@menu).to have_received(:require_roll).once.with(:foo_roll, 'foo_source/foo_roll')
      end
    end

    context 'when no source is specified' do
      before do
        class TestSourceA; end
        class TestSourceB; end
        TestSourceA.stub(:available_rolls).and_return({ :foo_roll => { :require_path => 'foo_roll' }})
        TestSourceB.stub(:available_rolls).and_return({ :bar_roll => { :require_path => 'bar_roll' }})

        @menu.var :object, {
          :rolls => { :bar_roll => nil },
          :sources => {
            :foo_source => nil,
            :bar_source => nil
          }
        }

        @menu.var :sources, {
          :foo_source => TestSourceA,
          :bar_source => TestSourceB
        }
      end

      it 'should require the first roll found' do
        expect(@menu).to receive(:require_roll).once.with(:bar_roll, 'bar_roll')
        @menu.send :find_roll, :bar_roll
      end
    end

    context 'when no roll is found' do
      before do
        class TestSource; end
        TestSource.stub(:available_rolls).and_return []
        @menu.var :object, { :rolls => { :foo_roll => nil }, :sources => { :foo_source => nil }}
        @menu.var :sources, { :foo_source => TestSource }
      end

      it 'should not attempt to require a roll' do
        expect(@menu).to_not receive(:require_roll)
        @menu.send :find_roll, :no_roll
      end
    end
  end

  describe '#on_the_menu?' do
    before do
      @menu.var :rolls, { :foo => nil }
    end

    it 'should return true if on the menu' do
      expect(@menu.send(:on_the_menu?, :foo)).to be_true
    end
  end

  describe '#add_roll' do
    before do
      class MenuAddRollRoll; end
      MenuAddRollRoll.stub(:options)

      @menu.var :object, { :rolls => { :menu_add_roll_roll => 'foo_option' }}

      @menu.send :add_roll, :menu_add_roll_roll, MenuAddRollRoll
    end

    it 'should add the roll to the class var' do
      expect(@menu.var(:rolls)[:menu_add_roll_roll]).to eq MenuAddRollRoll
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
      @menu.var :rolls, { :dependency_roll => DependencyRoll.new, :foo => EmptyDependencyRoll.new, :bar => EmptyDependencyRoll.new }
    end

    it 'should add the roll to the class var' do
      expect(@menu.send(:sorted_rolls).sort_by { |sym| sym.to_s }).to eq([:bar, :dependency_roll, :foo])
    end
  end

  describe '#order_rolls' do
    before do
      class OrderRollsRoll; end
      @menu.stub(:sorted_rolls).and_return([:foo_roll])
      @menu.var :rolls, { :foo_roll => OrderRollsRoll }
      @menu.var :object, {:rolls => { :foo_roll => { :foo => :bar }}}
    end

    after do
      @menu.send :order_rolls
      @menu.unstub :sorted_rolls
    end

    it 'should initialize a roll with the roll options' do
      expect(OrderRollsRoll).to receive :new
    end
  end
end
