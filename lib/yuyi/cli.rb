require 'thor'

class Yuyi::Cli < Thor
  desc 'list', 'Show all rolls available based on the sources defined in your menu.'
  option :menu, :aliases => '-m', :desc => 'Path to your menu file'
  def list
    Yuyi::Menu.new options[:menu]

    # Collect all rolls from all sources
    #
    rolls = []
    Yuyi::Menu.sources.each do |source|
      rolls |= source.rolls.keys
    end

    # alphabatize rolls
    rolls = rolls.map(&:to_s).sort

    Yuyi.say 'Available Rolls', :type => :success
    Yuyi.say '---------------', :type => :success
    rolls.each do |roll|
      Yuyi.say roll
    end
    Yuyi.say
  end

  desc 'version', 'Show the currently running version of yuyi'
  def version
    say "#{Yuyi::NAME} #{Yuyi::VERSION}"
  end

  desc 'start', 'Run Yuyi'
  option :verbose, :default => false, :aliases => '-v', :type => :boolean, :desc => 'Run in verbose mode'
  option :upgrade, :default => false, :aliases => '-u', :type => :boolean, :desc => 'Check for upgrades for rolls on the menu that are already installed'
  option :menu, :aliases => '-m', :desc => 'Path to your menu file'
  def start
    # enable verbose mode if flag is passed
    Yuyi.verbose = options[:verbose]
    Yuyi.upgrade = options[:upgrade]
    Yuyi.menu_path = options[:menu]

    Yuyi.start
  end

  default_task :start
end
