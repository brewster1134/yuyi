require 'ostruct'

describe Yuyi::Menu do
  before do
    @menu_path = root('spec', 'fixtures', 'Yuyifile')

    # stub the methods intialize calls so we can test them independently
    allow_any_instance_of(Yuyi::Menu).to receive(:get_menu_object_from_path)

    # initialize an empty menu object
    @menu = Yuyi::Menu.new @menu_path

    # test the stubbed methods to make sure they are called in order
    expect(@menu).to have_received(:get_menu_object_from_path).with(@menu_path).ordered

    # unstub the methods
    allow_any_instance_of(Yuyi::Menu).to receive(:get_menu_object_from_path).and_call_original
  end

  describe '#get_menu_object_from_path' do
    before do
      # make sure a cli instance is set globally so we can stub it
      Yuyi.cli ||= Yuyi::Cli.new

      @menu.get_menu_object_from_path @menu_path
    end

    after do
      allow(@menu).to receive(:validate_menu_path).and_call_original
      allow(Yuyi.cli).to receive(:init).and_call_original
    end

    context 'when passed path is valid' do
      before do
        allow(@menu).to receive(:validate_menu_path).and_return({
          sources: {},
          rolls: {}
        })

        @menu.get_menu_object_from_path 'valid/path'
      end

      it 'should only validate the valid path' do
        expect(@menu).to have_received(:validate_menu_path).once.with('valid/path')
      end

      it 'should set the yaml var to the valid menu file' do
        expect(@menu.yaml[:sources]).to be_a Hash
        expect(@menu.yaml[:rolls]).to be_a Hash
      end
    end

    context 'when all paths are invalid' do
      before do
        allow(@menu).to receive(:validate_menu_path).and_return false
        allow(Yuyi.cli).to receive(:init)

        @menu.get_menu_object_from_path 'invalid/path'
      end

      it 'should validate all possible paths' do
        expect(@menu).to have_received(:validate_menu_path).with('invalid/path')
        expect(@menu).to have_received(:validate_menu_path).with(File.join(Dir.pwd, Yuyi::DEFAULT_FILE_NAME))
        expect(@menu).to have_received(:validate_menu_path).with(File.join('~', Yuyi::DEFAULT_FILE_NAME))
      end

      it 'should run init' do
        expect(Yuyi.cli).to have_received(:init)
      end
    end
  end

  describe '#validate_menu_path' do
    it 'should return false if the path is not a file' do
      expect(@menu.validate_menu_path('spec')).to eq false
    end

    it 'should return false if the menu file doesnt contain the required keys' do
      expect(@menu.validate_menu_path(root('spec', 'fixtures', 'Yuyifile_invalid'))).to eq false
    end

    it 'should return the object if the menu file is valid' do
      menu = @menu.validate_menu_path(root('spec', 'fixtures', 'Yuyifile'))
      expect(menu[:sources]).not_to be_empty
      expect(menu[:rolls]).not_to be_empty
    end

    it 'should attempt to download a remote menu' do
      allow(Sourcerer).to receive(:new)
      expect(Sourcerer).to receive(:new)
      expect{@menu.validate_menu_path('remote/file')}.to raise_error
    end
  end
end







#   before do
#     # reset current menu instance
#     Yuyi::Menu.send :class_variable_set, :'@@menu', nil

#     allow_any_instance_of(Yuyi::Menu).to receive(:load_from_file)
#     allow_any_instance_of(Yuyi::Menu).to receive(:set_sources)
#     allow_any_instance_of(Yuyi::Menu).to receive(:set_rolls)

#     @menu = Yuyi::Menu.new 'spec/fixtures/menu.yaml'
#   end

#   # CLASS METHODS
#   #
#   describe 'class methods' do
#     describe '.add_roll' do
#       before do
#         class MenuAddRollRoll; end
#         Yuyi::Menu.add_roll :menu_add_roll_roll, MenuAddRollRoll
#       end

#       it 'should add a roll instance' do
#         expect(@menu.instance_var(:rolls)[:menu_add_roll_roll]).to be_a MenuAddRollRoll
#       end
#     end
#   end

#   # INSTANCE METHODS
#   #
#   describe 'instance methods' do
#     describe '#load_from_file' do
#       before do
#         # reset yaml var
#         @menu.send :instance_variable_set, :'@yaml', nil

#         allow(@menu).to receive(:load_from_file).and_call_original
#         allow(@menu).to receive(:get_user_menu_path)
#       end

#       after do
#         allow(@menu).to receive(:get_user_menu_path).and_call_original
#       end

#       context 'when the path is invalid' do
#         before do
#           @menu.send :load_from_file, 'foo'
#         end

#         it 'should not set the yaml variable' do
#           expect(@menu.instance_var(:yaml)).to be nil
#         end

#         it 'should not set the menu_path variable' do
#           expect(@menu.instance_var(:menu_path)).to be nil
#         end

#         it 'should call #get_user_menu_path' do
#           expect(@menu).to have_received(:get_user_menu_path)
#         end
#       end

#       context 'when the path is local' do
#         before do
#           @menu.send :load_from_file, 'spec/fixtures/menu.yaml'
#         end

#         it 'should set the yaml variable' do
#           expect(@menu.instance_var(:yaml)).to be_a Hash
#         end

#         it 'should set the yaml variable' do
#           expect(@menu.instance_var(:menu_path)).to be_a String
#         end
#       end

#       context 'when the path is remote' do
#         before do
#           @pwd = Dir.pwd
#           @tmp_dir = Dir.mktmpdir
#           FileUtils.chdir @tmp_dir
#           remote_file = 'file://' << File.join(File.dirname(__FILE__), '../../fixtures/menu.yaml')
#           @menu.send :load_from_file, remote_file
#         end

#         after do
#           FileUtils.rm File.join(@tmp_dir, 'Yuyifile_remote')
#           FileUtils.chdir @pwd
#         end

#         it 'should set the yaml variable' do
#           expect(@menu.instance_var(:yaml)).to be_a Hash
#         end

#         it 'should set the yaml variable' do
#           expect(@menu.instance_var(:menu_path)).to be_a String
#         end

#         it 'should create a _remote local menu file' do
#           expect(File.exist?(File.join(@tmp_dir, 'Yuyifile_remote'))).to be true
#         end
#       end
#     end

#     describe '#get_user_menu_path' do
#       before do
#         tmp_dir = Dir.mktmpdir
#         allow(Yuyi::Menu).to receive(:find_menu_file).and_return File.join(tmp_dir, Yuyi::DEFAULT_FILE_NAME)

#         FileUtils.cp File.join(File.dirname(__FILE__), '../../fixtures/menu.yaml'), tmp_dir
#         stub_const 'Yuyi::DEFAULT_MENU', File.join(tmp_dir, 'menu.yaml')
#         @menu.send :instance_variable_set, :'@yaml', nil


#         allow(Readline).to receive(:readline).and_return('foo', 'bar', '')
#         allow(@menu).to receive(:load_from_file).and_call_original
#       end

#       after do
#         allow(Readline).to receive(:readline).and_call_original
#       end

#       it 'should prompt the user to enter a menu path' do
#         expect(@menu).to receive(:load_from_file).exactly(3).times
#         @menu.send :get_user_menu_path
#       end
#     end

#     describe '#set_sources' do
#       before do
#         allow(Yuyi::Source).to receive(:new)
#         allow(@menu).to receive(:set_sources).and_call_original

#         @menu.send :instance_variable_set, :'@yaml', { :sources => { :foo => 'bar' }}
#         @menu.send :set_sources
#       end

#       after do
#         allow(Yuyi::Source).to receive(:new).and_call_original
#       end

#       it 'should create a source object from the menu' do
#         expect(Yuyi::Source).to have_received(:new).with :foo, 'bar'
#       end
#     end

#     describe '#set_rolls' do
#       before do
#         allow(@menu).to receive(:set_rolls).and_call_original
#         allow(@menu).to receive(:find_roll)

#         @menu.send :instance_variable_set, :'@yaml', { :rolls => { :foo_roll => {}}}
#         @menu.send :set_rolls
#       end

#       after do
#         allow(@menu).to receive(:find_roll).and_call_original
#       end

#       it 'should require rolls' do
#         expect(@menu).to have_received(:find_roll)
#       end
#     end

#     describe '#order' do
#       before do
#         class MenuOrderOne; end
#         class MenuOrderTwo; end
#         allow(MenuOrderOne).to receive :appetizers
#         allow(MenuOrderTwo).to receive :appetizers
#         allow(MenuOrderOne).to receive :entree
#         allow(MenuOrderTwo).to receive :entree
#         allow(MenuOrderOne).to receive :dessert
#         allow(MenuOrderTwo).to receive :dessert

#         allow(@menu).to receive(:sorted_rolls).and_return([:menu_order_one, :menu_order_two])
#         @menu.instance_var :rolls, { :menu_order_one => MenuOrderOne,  :menu_order_two => MenuOrderTwo }

#         @menu.send :order
#       end

#       after do
#         allow(@menu).to receive(:sorted_rolls).and_call_original
#       end

#       it 'should initialize a roll with the roll options' do
#         expect(MenuOrderOne).to have_received(:appetizers).ordered
#         expect(MenuOrderTwo).to have_received(:appetizers).ordered
#         expect(MenuOrderOne).to have_received(:entree).ordered
#         expect(MenuOrderTwo).to have_received(:entree).ordered
#         expect(MenuOrderOne).to have_received(:dessert).ordered
#         expect(MenuOrderTwo).to have_received(:dessert).ordered
#       end
#     end

#     describe '#sorted_rolls' do
#       before do
#         @menu.instance_var :rolls, {
#           :dependency_roll => OpenStruct.new({ :dependencies => ['foo', 'bar'] }),
#           :foo => OpenStruct.new({ :dependencies => [] }),
#           :bar => OpenStruct.new({ :dependencies => [] })
#         }
#       end

#       it 'should add the roll to the class var' do
#         expect(@menu.send(:sorted_rolls).sort_by { |sym| sym.to_s }).to eq([:bar, :dependency_roll, :foo])
#       end
#     end

#     describe '#find_roll' do
#       before do
#         allow(@menu).to receive :require_roll
#       end

#       context 'when a source is specified' do
#         before do
#           @menu.send :find_roll, :foo_roll, { :source => 'foo_source' }
#         end

#         it 'should require the specific roll' do
#           expect(@menu).to have_received(:require_roll).once.with(:foo_roll, 'foo_source/foo_roll')
#         end
#       end

#       context 'when no source is specified' do
#         before do
#           class TestSourceA; end
#           class TestSourceB; end
#           allow(TestSourceA).to receive(:rolls).and_return({ :foo_roll => 'foo_roll' })
#           allow(TestSourceB).to receive(:rolls).and_return({ :bar_roll => 'bar_roll' })

#           @menu.var :sources, [TestSourceA, TestSourceB]
#         end

#         it 'should require the first roll found' do
#           expect(@menu).to receive(:require_roll).once.with(:bar_roll, 'bar_roll')
#           @menu.send :find_roll, :bar_roll
#         end
#       end

#       context 'when no roll is found' do
#         before do
#           class TestSource; end
#           allow(TestSource).to receive(:rolls).and_return({})

#           @menu.var :sources, [TestSource]
#         end

#         it 'should not attempt to require a roll' do
#           expect(@menu).to_not receive(:require_roll)
#           @menu.send :find_roll, :no_roll
#         end
#       end
#     end

#     describe '#options' do
#       before do
#         @menu.instance_var :yaml, {
#           :rolls => {
#             :foo_roll => {
#               :foo => :bar
#             }
#           }
#         }
#       end

#       it 'should return roll options' do
#         expect(@menu.options(:foo_roll)[:foo]).to eq :bar
#       end
#     end
#   end
# end
