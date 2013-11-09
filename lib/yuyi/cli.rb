module Yuyi::Cli
  def start args
    command, *rest = *args
    case command
    when '-v'
      version
    else
      header
      Yuyi::Rolls.load
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

  def version
    say "#{Yuyi::NAME} #{Yuyi::VERSION}"
  end
end
