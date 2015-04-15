# require 'readline'
# require 'ruby-progressbar'
require 'sourcerer'
require 'yaml'

class Yuyi::Menu
  attr_accessor :yaml

  # Create a new menu that stores the raw yaml file
  # along with sources, rolls, and roll model instances
  #
  def initialize path
    @rolls = {}
    @sources = []

    get_menu_object_from_path path
    # # load a yaml file
    # load_from_file path

    # # create objects from the menu
    # set_sources
    # set_roll_models
    # set_rolls

    # # set menu to global object
    # Yuyi.menu = self
  end

  # searches for, and validates, a possible menu file
  # @param path [String] a path to a potentially valid menu
  # @return [String] a valid menu path
  #
  def get_menu_object_from_path path = ''
    user_path = path
    pwd_path  = File.join(Dir.pwd, Yuyi::DEFAULT_FILE_NAME)
    home_path = File.join('~', Yuyi::DEFAULT_FILE_NAME)

    # return the first valid menu object
    @yaml =
      validate_menu_path(user_path) ||
      validate_menu_path(pwd_path)  ||
      validate_menu_path(home_path) ||
      Yuyi.cli.init
  end

  # validates a menu path is a valid yuyi menu file
  # @param path [String] a potential menu file path
  # @return [Hash] yaml file converted to valid ruby menu hash
  #
  def validate_menu_path path
    # check that menu file exists locally
    path = if File.exists? File.expand_path path
      path

    # attempt to get remote file
    elsif
      path_array = path.split('::')
      file_name = File.basename(path_array[0]) rescue Yuyi::DEFAULT_FILE_NAME
      source = Sourcerer.new path_array[0], :subdirectory => path_array[1]
      source.files(file_name).first
    end

    # check that the path is a file
    return false unless File.file? path

    # check that menu contains required keys
    yaml = YAML.load(File.read(path)).deep_symbolize_keys! rescue {}
    return false unless yaml[:sources].is_a?(Hash) && !yaml[:sources].empty?
    return false unless yaml[:rolls].is_a?(Hash) && !yaml[:rolls].empty?

    # return yaml object
    yaml
  end

#   def options roll
#     @yaml[:rolls][roll] || {}
#   end

#   # DSL METHODS
#   #
#   def self.sources
#     menu.send :sources
#   end

#   # Add rolls to hash in format of {file_name: RollInstance}
#   # Called from Yuyi::Roll when a roll is inherited
#   #
#   def self.add_roll file_name, klass
#     unless klass.to_s.include? 'RollModel'
#       rolls[file_name] = klass.new
#     end
#   end

#   def self.on_the_menu? roll
#     menu.send :on_the_menu?, roll
#   end

#   def self.find_roll name, options = {}
#     menu.send :find_roll, name, options
#   end

#   # def self.load_from_file
#   #   menu.send :load_from_file
#   # end

#   # Find the best roll match from the sources and require it
#   #
#   def find_roll name, options = {}
#     return if on_the_menu? name

#     # return specific source roll if specified in the menu
#     #
#     if source = options[:source]
#       require_roll name, File.join(source, name.to_s)
#       return

#     # look through the sources for the first roll that matches.
#     # sources are listed in the menu in order of priority
#     else
#       @sources.each do |source|
#         if path = source.rolls[name]
#           require_roll name, path
#           return
#         end
#       end
#     end

#     # no roll was found
#     Yuyi.say "You ordered the '#{name}' roll off the menu, but we are fresh out...", :type => :fail
#     Yuyi.say 'Check your menu to make sure a source with your roll is listed.', :type => :warn
#     Yuyi.say
#   end

# private

#     # CLASS METHODS
#     #
#     def self.menu; @@menu; end
#     def self.menu_path; @@menu.send :menu_path; end
#     def self.order; @@menu.send :order; end
#     def self.rolls; @@menu.send :rolls; end
#     def self.sources; @@menu.send :sources; end

#     def self.options roll
#       @@menu.options roll
#     end

#     # INSTANCE METHODS
#     #
#     def menu_path; @menu_path; end
#     def rolls; @rolls; end
#     def sources; @sources; end

#     # Attempt to load a menu from a file path
#     #
#     def load_from_file path
#       path ||
#       if !path || path.empty?
#         get_path
#         return
#       end

#       unless @path
#         # check if path is local first
#         begin
#           File.open(File.expand_path(path))

#           @path = File.expand_path(path)

#         # otherwise assume it is remote and try to download it
#         rescue
#           # try to download the menu path
#           response = Yuyi.run "curl -sS #{path}"

#           # save a local copy of the remote menu
#           if $?.success?
#             # if a menu was downloaded, save the response to a local file
#             local_file_name = File.join Dir.pwd, "#{Yuyi::DEFAULT_FILE_NAME}_remote"

#             File.open local_file_name, 'w+' do |f|
#               f.write response
#             end

#             @path = local_file_name
#           end
#         end
#       end

#       begin
#         @yaml = YAML.load(File.open(@path)).deep_symbolize_keys!
#       rescue
#         Yuyi.say "No menu could be loaded from `#{path}`", :type => :fail
#         get_user_menu_path
#       end
#     end

#     # search the pwd or the home directory for a menufile
#     #
#     def set_menu_file_path
#       project_menu_file = File.expand_path File.join(Dir.pwd, Yuyi::DEFAULT_FILE_NAME)
#       home_menu_file = File.expand_path File.join('~', Yuyi::DEFAULT_FILE_NAME)

#       @menu_path = if File.exists? project_menu_file
#         project_menu_file
#       elsif File.exists? home_menu_file
#         home_menu_file
#       end
#     end

#     # prompt the user to enter a path to menu file
#     # keep prompting until path is valid
#     #
#     def get_user_menu_path
#       until @yaml
#         Yuyi.say 'Navigate to a menu file...', :type => :success
#         Yuyi.ask "...or just press ENTER to load `#{set_menu_file_path}`", :readline => true do |user_path|
#           menu_path = user_path.empty? ? set_menu_file_path : user_path
#           load_from_file menu_path
#         end
#       end
#     end

#     # Initialize sources from menu
#     #
#     def set_sources
#       @yaml[:sources].each do |name, path|
#         @sources << Yuyi::Source.new(name, path)
#       end
#     end

#     # Loop through the roll models in the yaml file and find a matching roll
#     def set_roll_models
#       @sources.each do |source|
#         source.roll_models.values.each do |roll_model_path|
#           require roll_model_path
#         end
#       end
#     end

#     # Loop through the rolls in the yaml file and find a matching roll
#     #
#     def set_rolls
#       @yaml[:rolls].each do |roll_name, roll_options|
#         find_roll roll_name, roll_options || {}
#       end
#     end

#     # Add a single roll to the menu
#     #
#     def require_roll name, path
#       # check if already on the roll for when requiring dependencies
#       return if on_the_menu? name

#       begin
#         require path
#       rescue LoadError
#         Yuyi.say "There was a problem loading the `#{name}` roll from `#{path}`", :type => :fail
#         Yuyi.say 'If this problem continues, please log an issue on the Yuyi github page.', :type => :warn
#         Yuyi.say
#       end
#     end

#     # Check if roll has already been added
#     #
#     def on_the_menu? roll
#       @rolls.keys.include? roll
#     end

#     # Initialize all the rolls in order
#     #
#     def order
#       header_length = 80
#       all_rolls = sorted_rolls
#       progressbar = ProgressBar.create(:progress_mark => '=', :length => header_length, :total => all_rolls.length)

#       # pre installs
#       #
#       # Yuyi.say '=' * header_length, :color => :green
#       Yuyi.say 'APPETIZERS', :justify => :center, :padding => header_length

#       progressbar.reset
#       all_rolls.each do |file_name|
#         @rolls[file_name].appetizers
#         progressbar.increment
#       end
#       Yuyi.say


#       # main installs
#       #
#       # Yuyi.say '=' * header_length, :color => :green
#       Yuyi.say 'ENTREES', :justify => :center, :padding => header_length

#       progressbar.reset
#       all_rolls.each do |file_name|
#         @rolls[file_name].entree
#         progressbar.increment
#       end
#       Yuyi.say


#       # post installs
#       #
#       # Yuyi.say '=' * header_length, :color => :green
#       Yuyi.say 'DESSERT', :justify => :center, :padding => header_length

#       progressbar.reset
#       all_rolls.each do |file_name|
#         @rolls[file_name].dessert
#         progressbar.increment
#       end
#       Yuyi.say


#       Yuyi.say 'YUYI COMPLETED', :color => :light_blue, :justify => :center, :padding => header_length
#       Yuyi.say '=' * header_length, :color => :light_blue
#       Yuyi.say
#     end

#     # Return an array of the topologically sorted rolls from the menu
#     #
#     def sorted_rolls
#       tsort_hash = {}
#       @rolls.each do |file_name, roll|
#         tsort_hash[file_name.to_s] = roll.dependencies.map(&:to_s)
#       end

#       tsort_hash.tsort.map(&:to_sym)
#     end
end
