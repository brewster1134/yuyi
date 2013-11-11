module Yuyi::Cli
  OPTIONS = {
    :help => 'Shows these options.',
    :list => 'List all rolls available to be included in your menu.',
    :version => 'Shows the current version of Yuyi.'
  }

  def start args
    command, *rest = *args

    catch :found do
      OPTIONS.keys.each do |option|
        if command == "--#{option.to_s}" || command == "-#{option.to_s.chars.first.downcase}"
          send(option)
          throw :found
        end
      end
      if command
        say 'INVALID ARGUMENT', :type => :warn
        send :help
      else
        header
        Yuyi::Rolls.load
      end
    end
  end

  def header
    say
    say '-----------------------------------------', :color => 4
    say
    say '____    ____  __    __  ____    ____  __  ', :color => 31
    say '\   \  /   / |  |  |  | \   \  /   / |  | ', :color => 32
    say ' \   \/   /  |  |  |  |  \   \/   /  |  | ', :color => 33
    say '  \_    _/   |  |  |  |   \_    _/   |  | ', :color => 34
    say '    |  |     |  `--\'  |     |  |     |  | ', :color => 35
    say '    |__|      \______/      |__|     |__| ', :color => 36
    say
    say '-----------------------------------------', :color => 4
    say
  end

  def say text = '', args = {}
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

  # Reference for color codes
  # https://github.com/flori/term-ansicolor/blob/master/lib/term/ansicolor.rb
  #
  def colorize text, color_code
    return text unless color_code
    "\e[#{color_code}m#{text}\e[0m"
  end

private

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
