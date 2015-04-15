require 'cli_miami'
require 'thor'

# CliMiami.set_preset :error, :color => :red
# CliMiami.set_preset :fine_print, :color => :cyan
CliMiami.set_preset :header, :color => :green
# CliMiami.set_preset :highlight_key, :indent => 2, :newline => false, :padding => 30, :justify => :rjust
# CliMiami.set_preset :highlight_value, :color => :blue, :style => :bright, :indent => 1
# CliMiami.set_preset :instruction, :color => :yellow, :indent => 2
# CliMiami.set_preset :list_item, :indent => 2
# CliMiami.set_preset :prompt, :color => :yellow, :style => :bold

class Yuyi::Cli < Thor
  desc 'version', 'Show the installed version of Yuyi'
  def version
    S.ay Yuyi::VERSION
  end

  desc 'init', 'Create a Yuyi menu file in the current directory'
  def init
  end

  desc 'list', 'Show all rolls available based on the sources defined in your menu.'
  option :menu, :aliases => '-m', :desc => 'Path to your menu file'
  def list
    Yuyi::Menu.new options[:menu]

    # Collect all rolls from all sources
    rolls = []
    Yuyi::Menu.sources.each do |source|
      rolls |= source.rolls.keys
    end

    # alphabatize rolls
    rolls.map!(&:to_s).sort!

    S.ay 'Available Rolls', :header
    rolls.each do |roll|
      S.ay roll
    end
  end

  desc 'start', 'Run Yuyi'
  option :verbose, :default => false, :aliases => '-v', :type => :boolean, :desc => 'Run in verbose mode'
  option :upgrade, :default => false, :aliases => '-u', :type => :boolean, :desc => 'Check for upgrades for rolls on the menu that are already installed'
  option :menu_path, :aliases => '-m', :desc => 'Path to a yuyi menu file'
  def start
    display_header

    # set flags
    Yuyi.set_verbose if options[:verbose]
    Yuyi.set_upgrade if options[:upgrade]

    # make cli instance available globally
    Yuyi.cli = self

    # run Yuyi
    Yuyi.start options[:menu_path]
  end

  default_task :start

  no_commands do
    def display_header
      line_length = 50
      S.ay
      S.ay '-' * line_length, :color => :light_blue
      S.ay
      S.ay '____    ____  __    __  ____    ____  __  ',  :justify => :center, :padding => line_length, :color => :red
      S.ay '\   \  /   / |  |  |  | \   \  /   / |  | ',  :justify => :center, :padding => line_length, :color => :light_white
      S.ay ' \   \/   /  |  |  |  |  \   \/   /  |  | ',  :justify => :center, :padding => line_length, :color => :light_blue
      S.ay '  \_    _/   |  |  |  |   \_    _/   |  | ',  :justify => :center, :padding => line_length, :color => :red
      S.ay '    |  |     |  `--\'  |     |  |     |  | ', :justify => :center, :padding => line_length, :color => :light_white
      S.ay '    |__|      \______/      |__|     |__| ',  :justify => :center, :padding => line_length, :color => :light_blue
      S.ay
      S.ay "VERSION #{Yuyi::VERSION}", :justify => :center, :padding => line_length
      S.ay
      S.ay '-' * line_length, :color => :light_blue
      S.ay
    end
  end
end
