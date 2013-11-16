require 'readline'
require 'yaml'

module Yuyi::Cli
  OPTIONS = {
    :help => 'Shows these options.',
    :list => 'List all rolls available to be included in your menu.',
    :version => 'Shows the current version of Yuyi.'
  }

  def start args
    command, *rest = *args

    catch :found do
      # Call options method if valid argument is passed
      # This checks for the full name or the first letter, proceeded by '--' or '-' respectively
      OPTIONS.keys.each do |option|
        if command == "--#{option.to_s}" || command == "-#{option.to_s.chars.first.downcase}"
          send(option)
          throw :found
        end
      end
      # Show a warning if an invalid argument is passed and then show the help menu
      if command
        say 'INVALID ARGUMENT', :type => :warn
        send :help
      else
        header
        get_menu
        Yuyi::Rolls.load
      end
    end
  end

  def header
    line_length = 50
    say
    say '-' * line_length, :color => 4
    say
    say '____    ____  __    __  ____    ____  __  ', :color => 31, :center => line_length
    say '\   \  /   / |  |  |  | \   \  /   / |  | ', :color => 32, :center => line_length
    say ' \   \/   /  |  |  |  |  \   \/   /  |  | ', :color => 33, :center => line_length
    say '  \_    _/   |  |  |  |   \_    _/   |  | ', :color => 34, :center => line_length
    say '    |  |     |  `--\'  |     |  |     |  | ', :color => 35, :center => line_length
    say '    |__|      \______/      |__|     |__| ', :color => 36, :center => line_length
    say
    say "VERSION #{Yuyi::VERSION}", :center => line_length
    say
    say '-' * line_length, :color => 4
    say
  end

  def say text = '', args = {}
    # Justify options
    if args[:center] && args[:center].is_a?(Integer)
      text = text.center args[:center]
    end

    # Type options
    # process last due to the addition of special color codes
    text = case args[:type]
    when :fail
      colorize text, 31
    when :success
      colorize text, 32
    when :warn
      colorize text, 33
    else
      colorize text, args[:color]
    end

    puts text
  end

private

  # Reference for color codes
  # https://github.com/flori/term-ansicolor/blob/master/lib/term/ansicolor.rb
  #
  def colorize text, color_code
    return text unless color_code
    "\e[#{color_code}m#{text}\e[0m"
  end

  def get_menu
    until menu = load_menu(menu)
      say 'Navigate to the menu you want to order from...', :type => :success
      say '* Just press enter to look for `menu.yml` in your Documents folder. *'
      menu = Readline.readline('> ').rstrip
      menu = Yuyi::DEFAULT_ROLL_PATH if menu.empty?
    end
    Yuyi::Rolls.menu = menu
  end

  def load_menu menu
    YAML.load(File.open(File.expand_path(menu)))
  rescue
    return false
  end

  # METHODS FOR FLAGS
  #
  def help
    longest_option = OPTIONS.keys.map(&:to_s).max.length

    say
    OPTIONS.each do |option, description|
      string = ''
      string << "-#{option.to_s.chars.first.downcase}"
      string << ', '
      string << "--#{option.to_s.ljust(longest_option)}"
      string << '   '
      string << description
      say string
    end
    say
  end

  def list
    say
    say 'Available Rolls', :type => :success
    say '---------------', :type => :success
    Dir.glob(File.join Yuyi::ROLLS_DIR, '*.rb').each do |roll|
      say File.basename(roll, '.rb')
    end
    say
  end

  def version
    say "#{Yuyi::NAME} #{Yuyi::VERSION}"
  end
end
