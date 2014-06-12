require 'open3'
require 'readline'
require 'yaml'

module Yuyi::Cli
  # Configure readline
  Readline.completion_append_character = '/'

  # Define available command line options
  # Each key must start with a unique letter
  # Flags are automatically created based on the first letter (eg. -h, --help)
  #
  CLI_OPTIONS = {
    :help => 'Shows these options.',
    :list => 'List all rolls available to be included in your menu.',
    :version => 'Shows the current version of Yuyi.',
    :VERBOSE => 'Shows the output of all commands being run'
  }

  # Called by the install script
  #
  def init args
    # get the first argument as the command
    command, *rest = *args

    # Call options method if valid argument is passed
    # This checks for the full name or the first letter, proceeded by '--' or '-' respectively
    CLI_OPTIONS.keys.each do |option|
      if command == "--#{option}" || command == "-#{option.to_s.chars.first}"
        begin
          send option.to_s.downcase, rest
        rescue
          send option.to_s.downcase
        end
        return
      end
    end

    # Show a warning if an invalid argument is passed and then show the help menu
    if command
      say 'INVALID ARGUMENT', :type => :fail
      send :help
    else
      start
    end
  end

  # Replacement for `puts` that accepts various stylistic arguments
  # type:     => [symbol]             Preset colors for [:fail, :success, :warn]
  # color:    => [integer]            See docs for #colorize for color codes
  # justify:  => [center|ljust|rjust] The type of justification to use
  # padding:  => [integer]            The maximum string size to justify text in
  # indent:   => [integer]            The maximum string size to justify text in
  # newline:  => [boolean]            True if you want a newline after the output
  #
  def say text = '', args = {}
    # defaults
    args = {
      :newline => true
    }.merge args

    # Justify options
    if args[:justify] && args[:padding]
      text = text.send args[:justify], args[:padding]
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

    if args[:indent]
      text = (' ' * args[:indent]) + text
    end

    if args[:newline]
      STDOUT.puts text
    else
      STDOUT.print text
    end
  end

  # Accepts the same arguments as #say
  #
  def ask question, options = {}, &block
    prompt = '>>> '
    options = {
      :readline => false,
      :color => 1
    }.merge(options)

    say question, options

    output = if options[:readline]
      Readline.readline(prompt).chomp('/')
    else
      say prompt, :color => 1, :newline => false
      STDIN.gets
    end.rstrip

    say
    yield output
  end

  # Run a command and output formatting success/errors
  #
  def run command, args = {}
    # check if in verbose mode
    verbose = args[:verbose] || @verbose
    output = `echo | #{command} 2>&1`
    success = $?.success?

    if verbose
      say "RUNNING: #{command}", :type => (success ? :success : :fail)
      say output
    end

    args[:boolean] ? success : output
  end

  def command? command
    run command, :verbose => false, :boolean => true
  end

  # Write several lines to to an existing file
  #
  def write_to_file file, *text
    File.open(File.expand_path(file), 'a') do |file|
      file.write text * "\n"
      file.write "\n"
    end
  end

  # Delete specific lines from an existing file
  #
  def delete_from_file file, *text
    # get file text
    new_text = File.read(File.expand_path(file))

    # iterate through text and remove it
    text.each do |t|
      regex = /^.*#{Regexp.escape(t)}.*\n/
      new_text.gsub!(regex, '')
    end

    # write new text back to file
    File.open(File.expand_path(file), 'w') { |f| f.write(new_text) }
  end

  def osx_version
    run '/usr/bin/sw_vers -productVersion'.chomp[/10\.\d+/].to_f
  end

private

  def start
    header
    get_menu
    confirm_upgrade
    confirm_options
    authenticate
    Yuyi::Menu.instance.order_rolls
  end

  def header
    line_length = 50
    say
    say '-' * line_length, :color => 4
    say
    say '____    ____  __    __  ____    ____  __  ', :color => 31, :justify => :center, :padding => line_length
    say '\   \  /   / |  |  |  | \   \  /   / |  | ', :color => 32, :justify => :center, :padding => line_length
    say ' \   \/   /  |  |  |  |  \   \/   /  |  | ', :color => 33, :justify => :center, :padding => line_length
    say '  \_    _/   |  |  |  |   \_    _/   |  | ', :color => 34, :justify => :center, :padding => line_length
    say '    |  |     |  `--\'  |     |  |     |  | ', :color => 35, :justify => :center, :padding => line_length
    say '    |__|      \______/      |__|     |__| ', :color => 36, :justify => :center, :padding => line_length
    say
    say "VERSION #{Yuyi::VERSION}", :justify => :center, :padding => line_length
    say
    say '-' * line_length, :color => 4
    say
  end

  # Ask the user for a menu file to load
  #
  def get_menu
    menu = nil

    until menu
      say 'Navigate to a menu file...', :type => :success
      menu = ask "...or just press enter to load `#{Yuyi::DEFAULT_MENU}`", :readline => true, :color => 36 do |path|
        path = path.empty? ? Yuyi::DEFAULT_MENU : path

        if Yuyi::Menu.load_from_file path
          say 'Downloading Sources... Please Wait', :type => :warn
          say

          Yuyi::Menu.new path
        else
          say 'Invalid Path... Please check the location of your menu file', :type => :fail
          say

          nil
        end
      end
    end
  end

  # Ask to check for upgrades
  #
  def confirm_upgrade
    ask 'Do you want to check for upgrades for already installed rolls? (Yn)', :type => :warn do |upgrade|
      Yuyi::Menu.upgrade? upgrade == 'Y'
    end
  end

  # If any rolls on the menu have options, confirm the options before continuing
  #
  def confirm_options
    confirm = false
    Yuyi::Menu.rolls.each do |name, roll|

      unless roll.class.options.empty?
        present_options roll
        confirm = true
      end
    end

    if confirm
      ask 'Hit any key when you have your options set correctly in your menu file', :type => :warn do
        Yuyi::Menu.load_from_file
      end
    end
  end

  def authenticate
    say 'Please enter the admin password', :type => :warn
    say 'NOTE: This is passed directly to sudo and is not saved.'
    say '      This will ensure all your installs run unsupervised.'

    # clear sudo timestamp & run any command as admin to force a password prompt
    system 'sudo -k; sudo echo >> /dev/null 2>&1'
    say
  end

  # Show formatted options
  #
  def present_options roll, examples = true
    indent = 2
    longest_option = roll.options.keys.map(&:to_s).max_by(&:length).length + indent

    say "Available options for #{roll.title}...", :color => 32

    roll.option_defs.each do |k, v|
      option_color = v[:required] ? 31 : 36

      say "#{k.to_s.rjust(longest_option)}: ", :color => option_color, :newline => false
      say v[:description]
      say (' ' * (longest_option + indent)), :newline => false
      say 'default: ', :color => 36, :newline => false
      say v[:default]
    end

    if examples
      examples_hash = {}
      example_indent = longest_option + indent
      options = roll.options.dup

      # merge examples from roll source in
      options.each do |option, value|
        if example = roll.option_defs[option][:example]
          options[option] = example
        end
      end

      examples_hash[roll.file_name.to_s] = options


      say
      say 'Example', :color => 33, :indent => example_indent, :newline => false
      say examples_hash.deep_stringify_keys!.to_yaml.sub("--- ", '').gsub(/\n(\s*)/, "\n\\1#{' ' * example_indent}")
    end
  end

  # Output text with a certain color (or style)
  # Reference for color codes
  # https://github.com/flori/term-ansicolor/blob/master/lib/term/ansicolor.rb
  #
  def colorize text, color_code
    return text unless color_code
    "\e[#{color_code}m#{text}\e[0m"
  end

  # METHODS FOR FLAGS
  #
  def help
    longest_option = CLI_OPTIONS.keys.map(&:to_s).max.length

    say
    CLI_OPTIONS.each do |option, description|
      string = ''
      string << "-#{option.to_s.chars.first}"
      string << ', '
      string << "--#{option.to_s.ljust(longest_option)}"
      string << '   '
      string << description
      say string
    end
    say
  end

  # List all available rolls
  #
  def list
    get_menu
    Yuyi::Menu.set_sources

    # Collect all rolls from all sources
    #
    rolls = []
    Yuyi::Menu.sources.each do |source|
      rolls |= source.available_rolls.keys
    end

    # alphabatize rolls
    rolls = rolls.map(&:to_s).sort.map(&:to_sym)

    say 'Available Rolls', :type => :success
    say '---------------', :type => :success
    rolls.each do |roll|
      say roll.to_s
    end
    say
  end

  # Return current version
  #
  def version
    say "#{Yuyi::NAME} #{Yuyi::VERSION}"
  end

  # Return current version
  #
  def verbose
    @verbose = true
    start
  end
end
