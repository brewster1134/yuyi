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
    :version => 'Shows the current version of Yuyi.'
  }

  def start args
    command, *rest = *args

    catch :found do
      # Call options method if valid argument is passed
      # This checks for the full name or the first letter, proceeded by '--' or '-' respectively
      OPTIONS.keys.each do |option|
        if command == "--#{option.to_s}" || command == "-#{option.to_s.chars.first.downcase}"
          if rest.empty?
            send(option)
          else
            send(option, rest)
          end
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
        Yuyi::Menu.load
      end
    end
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


  # Replacement for `puts` that accepts various stylistic arguments
  # type:  =>  [symbol] Preset colors for [:fail, :success, :warn]
  # color:  => [integer] See docs for #colorize for color codes
  # justify: => [center|ljust|rjust] The type of justification to use
  # padding: => [integer] The maximum string size to justify text in
  #
  def say text = '', args = {}
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

    puts text
  end

  # Accepts the same arguments as #say
  #
  def ask question = nil, options = {}, &block
    prompt = '>>> '
    options = {
      :readline => false,
      :color => 1
    }.merge(options)

    say question, options if question

    output = if options[:readline]
      Readline.readline(prompt).chomp('/')
    else
      say prompt, :color => 1
      gets
    end.rstrip

    say
    yield output
  end

  def present_options roll
    optionHash = {
      :descriptions => [],
      :examples => []
    }

    indent = 2
    longest_option = roll.available_options.keys.map(&:to_s).max_by(&:length).length + indent

    exampleHash = {}
    exampleHash[roll.file_name.to_s] = {}

    roll.available_options.each do |k, v|
      key_color = v[:required] ? 31 : 36
      descriptionString = "\e[#{key_color}m#{k.to_s.rjust(longest_option)}\e[0m: "
      descriptionString << "#{v[:description]}"
      descriptionString << "\n#{' ' * (longest_option + indent)}\e[33mdefault #{v[:default]}\e[0m" if v[:default]
      optionHash[:descriptions] << descriptionString

      exampleHash[roll.file_name.to_s][k.to_s] = v[:example]
    end

    optionHash[:examples] << exampleHash.to_yaml.sub("--- \n", ' ' * indent)

    say "Available options for the #{roll.title} roll...", :type => :success
    say optionHash[:descriptions].join("\n")
    say
    say "Example", :type => :success, :indent => indent
    say optionHash[:examples].join("\n").gsub("\n", "\n#{' ' * indent}")
  end

  def write_to_file file, *text
    File.open(File.expand_path(file), File::WRONLY|File::CREAT|File::APPEND) do |file|
      file.write text * "\n"
      file.write "\n"
    end
  end

  def command? command
    `which #{command}`
    $?.success?
  end

  def run command, args = {}
    Open3.popen3 command do |stdin, stdout, stderr|
      err = stderr.read.chomp
      out = stdout.read.chomp

      if args[:verbose]
        say(err, args.merge({:type => :fail})) unless err.empty?
        say(out, args.merge({:type => :success})) unless out.empty?
      end
    end
  end

private

  # Output text with a certain color (or style)
  # Reference for color codes
  # https://github.com/flori/term-ansicolor/blob/master/lib/term/ansicolor.rb
  #
  def colorize text, color_code
    return text unless color_code
    "\e[#{color_code}m#{text}\e[0m"
  end

  # Ask the user for a menu file to load
  #
  def get_menu
    menu = nil
    until menu
      say 'Navigate to the menu you want to order from...', :type => :success
      menu = ask '...or just press enter to look for `.yuyi_menu.yml` in your home folder.', :readline => true, :color => 36 do |path|
        Yuyi::Menu.new(path.empty? ? Yuyi::DEFAULT_ROLL_PATH : path)
        Yuyi::Menu.object
      end
    end
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
