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
  OPTIONS = {
    :help => 'Shows these options.',
    :list => 'List all rolls available to be included in your menu.',
    :version => 'Shows the current version of Yuyi.',
    :VERBOSE => 'Shows the output of all commands being run'
  }

  def init args
    command, *rest = *args

    catch :found do
      # Call options method if valid argument is passed
      # This checks for the full name or the first letter, proceeded by '--' or '-' respectively
      OPTIONS.keys.each do |option|
        if command == "--#{option}" || command == "-#{option.to_s.chars.first}"
          if rest.empty?
            send(option.to_s.downcase)
          else
            send(option.to_s.downcase, args)
          end
          throw :found
        end
      end

      # Show a warning if an invalid argument is passed and then show the help menu
      if command
        say 'INVALID ARGUMENT', :type => :warn
        send :help
      else
        start
      end
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

  # Show formatted options
  #
  def present_options roll
    optionHash = {
      :descriptions => [],
      :examples => []
    }

    indent = 2
    longest_option = roll.options.keys.map(&:to_s).max_by(&:length).length + indent

    exampleHash = {}
    exampleHash[roll.file_name.to_s] = {}

    roll.options.each do |k, v|
      key_color = v[:required] ? 31 : 36
      descriptionString = "\e[#{key_color}m#{k.to_s.rjust(longest_option)}\e[0m: "
      descriptionString << "#{v[:description]}"
      descriptionString << "\n#{' ' * (longest_option + indent)}\e[33mdefault #{v[:default]}\e[0m" if v[:default]
      optionHash[:descriptions] << descriptionString

      exampleHash[roll.file_name.to_s][k.to_s] = v[:example]
    end

    optionHash[:examples] << exampleHash.to_yaml.sub("--- \n", ' ' * indent)

    say "Available options for #{roll.title}...", :type => :success
    say optionHash[:descriptions].join("\n")
    say
    say "Example", :type => :success, :indent => indent
    say optionHash[:examples].join("\n").gsub("\n", "\n#{' ' * indent}")
  end

  # Run a command and output formatting success/errors
  #
  def run command, args = {}
    Open3.popen3 command do |stdin, stdout, stderr|
      err = stderr.read.chomp
      out = stdout.read.chomp

      verbose = if args[:verbose].nil?
        @verbose
      else
        args[:verbose]
      end

      if verbose
        say(err, args.merge({:type => :fail})) unless err.empty?
        say(out, args.merge({:type => :success})) unless out.empty?
      end

      # return false is there are errors
      if args[:boolean]
        err.empty?
      else
        err.empty? ? out : err
      end
    end
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

private

  def start
    header
    menu = get_menu
    menu.confirm_upgrade
    menu.confirm_options
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
        say 'Downloading Sources... Please Wait', :type => :warn
        say

        Yuyi::Menu.new(path.empty? ? Yuyi::DEFAULT_MENU : path)
      end
    end

    return menu
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
    longest_option = OPTIONS.keys.map(&:to_s).max.length

    say
    OPTIONS.each do |option, description|
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
    menu = get_menu

    # Collect all rolls from all sources
    #
    rolls = []
    menu.sources.each do |name, source|
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
