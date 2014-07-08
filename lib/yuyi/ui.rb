module Yuyi::Ui
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
      say 'Your menu is being loaded from: ', :type => :warn, :newline => false
      say Yuyi::Menu.menu_path
      ask 'Make any changes you need to it, save it, and then press enter to continue.', :type => :warn do
        Yuyi::Menu.load_from_file
      end
    end
  end

  def authenticate
    say 'Yuyi does not need your admin password, but some installations do.', :type => :warn
    say 'You may be asked to enter your password several times.', :type => :warn
    say

    # keep the sudo timestamp fresh just in case
    Thread::new do
      loop do
        sleep 1.minute
        `sudo -v`
      end
    end
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
      if v[:default]
        say 'default: ', :color => 36, :newline => false
        say v[:default]
      end
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
      say examples_hash.deep_stringify_keys!.to_yaml.sub('---', '').gsub(/\n(\s*)/, "\n\\1#{' ' * example_indent}")
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
end
