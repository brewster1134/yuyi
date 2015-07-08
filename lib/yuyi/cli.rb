require 'thor'

class Yuyi::Cli < Thor
  desc 'version', 'Show the installed version of Yuyi'
  def version
    display_header
  end

  desc 'init', 'Create a Yuyi menu file in the current directory'
  def init
    display_header
  end

  desc 'list', 'Show all rolls available based on the sources defined in your menu.'
  option :menu_paths, :type => :array, :aliases => '-m', :desc => 'Path to yuyi menu files'
  def list
    display_header

    Yuyi::Menu.new options[:menu_paths]

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
  option :upgrade, :default => false, :aliases => '-u', :type => :boolean, :desc => 'Attempt to upgrade rolls that are already installed'
  option :menu_paths, :type => :array, :aliases => '-m', :desc => 'Path to yuyi menu files'
  def start
    display_header

    # run Yuyi
    Yuyi.start options[:menu_paths], :verbose => options[:verbose], :upgrade => options[:upgrade]
  end

  default_task :start

  no_commands do
    def display_header
      line_length = 80
      S.ay '                               /$$', :justify => :center, :padding => line_length, :color => :red
      S.ay '                              |__/', :justify => :center, :padding => line_length, :color => :white
      S.ay ' /$$   /$$ /$$   /$$ /$$   /$$ /$$', :justify => :center, :padding => line_length, :color => :cyan
      S.ay '| $$  | $$| $$  | $$| $$  | $$| $$', :justify => :center, :padding => line_length, :color => :red
      S.ay '| $$  | $$| $$  | $$| $$  | $$| $$', :justify => :center, :padding => line_length, :color => :white
      S.ay '| $$  | $$| $$  | $$| $$  | $$| $$', :justify => :center, :padding => line_length, :color => :cyan
      S.ay '|  $$$$$$$|  $$$$$$/|  $$$$$$$| $$', :justify => :center, :padding => line_length, :color => :red
      S.ay ' \____  $$ \______/  \____  $$|__/', :justify => :center, :padding => line_length, :color => :white
      S.ay ' /$$  | $$           /$$  | $$    ', :justify => :center, :padding => line_length, :color => :cyan
      S.ay '|  $$$$$$/          |  $$$$$$/    ', :justify => :center, :padding => line_length, :color => :red
      S.ay ' \______/            \______/     ', :justify => :center, :padding => line_length, :color => :white
      S.ay
      S.ay '=' * line_length, :color => :cyan
      S.ay "VERSION #{Yuyi::VERSION}", :justify => :center, :padding => line_length, :color => :red
      S.ay '=' * line_length, :color => :cyan
    end
  end
end
