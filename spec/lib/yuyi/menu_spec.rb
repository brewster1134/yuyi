require 'spec_helper'

describe Yuyi::Menu do
  before do
    Yuyi::Menu.send :class_variable_set, :'@@instance', nil
    Yuyi::Menu.send :instance_variable_set, :'@object', nil
  end

  describe '#initialize' do
    context 'with a valid path' do
      before do
        Yuyi::Menu.new 'spec/fixtures/menu.yaml'
      end

      it 'should set the path var' do
        expect(Yuyi::Menu.path).to eq 'spec/fixtures/menu.yaml'
      end

      it 'should set the instance on the menu class' do
        expect(Yuyi::Menu.instance).to eq Yuyi::Menu.instance
      end

      it 'should set the object var' do
        expect(Yuyi::Menu.object[:sources][0]).to eq({ :local => 'spec/fixtures/roll_dir' })
        expect(Yuyi::Menu.object[:sources][1]).to eq({ :yuyi => 'spec/fixtures/roll_zip.zip' })
        expect(Yuyi::Menu.object[:rolls][:foo_roll]).to eq({ :foo => 'bar' })
      end
    end

    context 'with an invalid path' do
      before do
        Yuyi::Menu.new 'foo'
      end

      it 'should have a nil instance' do
        expect(Yuyi::Menu.instance).to be_nil
      end

      it 'should have a nil object' do
        expect(Yuyi::Menu.object).to be_nil
      end
    end
  end

  context 'when valid menu already initialized' do
    before do
      Yuyi::Menu.new 'spec/fixtures/menu.yaml'
    end

    describe '.load_from_file' do
      context 'with a local file' do
        before do
          Yuyi::Menu.load_from_file 'spec/fixtures/menu2.yaml'
        end

        it 'should update the menu object' do
          expect(Yuyi::Menu.instance.object[:rolls][:foo_roll]).to eq({ :bar => 'foo' })
        end
      end

      context 'with a remote file' do
        before do
          allow(Yuyi).to receive(:run).and_return({ :foo => 'bar' }.to_yaml)
          Yuyi::Menu.load_from_file 'file://menu.yaml'
        end

        after do
          allow(Yuyi).to receive(:run).and_call_original
        end

        it 'should update the menu object' do
          expect(Yuyi::Menu.instance.object[:foo]).to eq 'bar'
        end
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

    describe '#set_sources' do
      before do
        Yuyi::Menu.instance_var :object, { :sources => [{ :foo_source => 'foo/path' }]}

        class FooSource; end
        allow(Yuyi::Source).to receive(:new).and_return FooSource

        Yuyi::Menu.instance.send :set_sources
      end

      it 'should set the sources var' do
        expect(Yuyi::Menu.instance.var(:sources).size).to eq(1)
        expect(Yuyi::Menu.instance.var(:sources)[0]).to eq FooSource
      end
    end

    describe '#find_roll' do
      before do
        allow(Yuyi::Menu.instance).to receive :require_roll
      end

      context 'when a source is specified' do
        before do
          Yuyi::Menu.instance.send :find_roll, :foo_roll, { :source => 'foo_source' }
        end

        it 'should require the specific roll' do
          expect(Yuyi::Menu.instance).to have_received(:require_roll).once.with(:foo_roll, 'foo_source/foo_roll')
        end
      end

      context 'when no source is specified' do
        before do
          class TestSourceA; end
          class TestSourceB; end
          allow(TestSourceA).to receive(:available_rolls).and_return({ :foo_roll => 'foo_roll' })
          allow(TestSourceB).to receive(:available_rolls).and_return({ :bar_roll => 'bar_roll' })

          Yuyi::Menu.instance.var :sources, [TestSourceA, TestSourceB]
        end

        it 'should require the first roll found' do
          expect(Yuyi::Menu.instance).to receive(:require_roll).once.with(:bar_roll, 'bar_roll')
          Yuyi::Menu.instance.send :find_roll, :bar_roll
        end
      end

      context 'when no roll is found' do
        before do
          class TestSource; end
          allow(TestSource).to receive(:available_rolls).and_return({})

          Yuyi::Menu.instance.var :sources, [TestSource]
        end

        it 'should not attempt to require a roll' do
          expect(Yuyi::Menu.instance).to_not receive(:require_roll)
          Yuyi::Menu.instance.send :find_roll, :no_roll
        end
      end
    end

    describe '#on_the_menu?' do
      before do
        allow(Yuyi::Menu.instance).to receive(:object).and_return({ :rolls => { :foo => nil }})
      end

      it 'should return true if on the menu' do
        expect(Yuyi::Menu.instance.on_the_menu?(:foo)).to be true
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
        allow(Yuyi::Menu.instance).to receive(:rolls).and_return({ :dependency_roll => DependencyRoll.new, :foo => EmptyDependencyRoll.new, :bar => EmptyDependencyRoll.new })
      end

      it 'should add the roll to the class var' do
        expect(Yuyi::Menu.instance.send(:sorted_rolls).sort_by { |sym| sym.to_s }).to eq([:bar, :dependency_roll, :foo])
      end
    end

    describe '#order_rolls' do
      before do
        class MenuOrderRollsOne; end
        class MenuOrderRollsTwo; end
        allow(MenuOrderRollsOne).to receive :appetizers
        allow(MenuOrderRollsTwo).to receive :appetizers
        allow(MenuOrderRollsOne).to receive :entree
        allow(MenuOrderRollsTwo).to receive :entree
        allow(MenuOrderRollsOne).to receive :dessert
        allow(MenuOrderRollsTwo).to receive :dessert

        allow(Yuyi::Menu.instance).to receive(:sorted_rolls).and_return([:menu_order_rolls_one, :menu_order_rolls_two])
        allow(Yuyi::Menu.instance).to receive(:rolls).and_return({ :menu_order_rolls_one => MenuOrderRollsOne,  :menu_order_rolls_two => MenuOrderRollsTwo })

        Yuyi::Menu.instance.send :order_rolls
      end

      after do
        allow(Yuyi::Menu.instance).to receive(:sorted_rolls).and_call_original
        allow(Yuyi::Menu.instance).to receive(:rolls).and_call_original
      end

      it 'should initialize a roll with the roll options' do
        expect(MenuOrderRollsOne).to have_received(:appetizers).ordered
        expect(MenuOrderRollsTwo).to have_received(:appetizers).ordered
        expect(MenuOrderRollsOne).to have_received(:entree).ordered
        expect(MenuOrderRollsTwo).to have_received(:entree).ordered
        expect(MenuOrderRollsOne).to have_received(:dessert).ordered
        expect(MenuOrderRollsTwo).to have_received(:dessert).ordered
      end
    end
  end
end
