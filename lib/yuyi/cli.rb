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
    S.ay
  end

  desc 'version', 'Show the currently running version of yuyi'
  def version
    S.ay "#{Yuyi::NAME} #{Yuyi::VERSION}"
  end

  desc 'start', 'Run Yuyi'
  option :verbose, :default => false, :aliases => '-v', :type => :boolean, :desc => 'Run in verbose mode'
  option :upgrade, :default => false, :aliases => '-u', :type => :boolean, :desc => 'Check for upgrades for rolls on the menu that are already installed'
  option :menu, :aliases => '-m', :desc => 'Path to your menu file'
  def start
    # set flags
    Yuyi.verbose = options[:verbose]
    Yuyi.upgrade = options[:upgrade]

    # set menu path
    Yuyi.menu_path = options[:menu]

    Yuyi.start
  end

  default_task :start
end
