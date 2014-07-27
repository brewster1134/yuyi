module Yuyi::Ui
  def header
    line_length = 50
    say
    say '-' * line_length, :color => :light_blue
    say
    say '____    ____  __    __  ____    ____  __  ',  :justify => :center, :padding => line_length, :color => :red
    say '\   \  /   / |  |  |  | \   \  /   / |  | ',  :justify => :center, :padding => line_length, :color => :light_white
    say ' \   \/   /  |  |  |  |  \   \/   /  |  | ',  :justify => :center, :padding => line_length, :color => :light_blue
    say '  \_    _/   |  |  |  |   \_    _/   |  | ',  :justify => :center, :padding => line_length, :color => :red
    say '    |  |     |  `--\'  |     |  |     |  | ', :justify => :center, :padding => line_length, :color => :light_white
    say '    |__|      \______/      |__|     |__| ',  :justify => :center, :padding => line_length, :color => :light_blue
    say
    say "VERSION #{Yuyi::VERSION}", :justify => :center, :padding => line_length
    say
    say '-' * line_length, :color => :light_blue
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
    say 'Yuyi will prompt you for a password and attempt to keep your admin timestamp alive.', :type => :warn
    say 'You may be asked to enter your password several times.', :type => :warn
    say

    # keep the sudo timestamp fresh just in case
    `sudo -v`
    Thread.new do
      loop do
        sleep 60
        `sudo -v`
      end
    end
  end

  # Show formatted options
  #
  def present_options roll, examples = true
    indent = 2
    longest_option = roll.options.keys.map(&:to_s).max_by(&:length).length + indent

    say "#{roll.title} options", :color => :green

    roll.option_defs.each do |k, v|
      option_color = v[:required] ? :red : :default

      # show option and description
      say "#{k.to_s.rjust(longest_option)}: ", :color => option_color, :newline => false
      say v[:description]

      # show default
      if v[:default] && (!v[:default].respond_to?(:empty?) || (v[:default].respond_to?(:empty?) && !v[:default].empty?))
        say 'default: ', :indent => (longest_option + indent), :newline => false, :color => :yellow
        say v[:default]
      end
    end

    if examples
      examples_hash = {}
      options = roll.options.dup

      # merge examples from roll source in
      options.each do |option, value|
        if example = roll.option_defs[option][:example]
          options[option] = example
        end
      end

      examples_hash[roll.file_name.to_s] = options

      say
      say 'Example', :color => :green, :indent => indent, :newline => false
      say examples_hash.deep_stringify_keys!.to_yaml.sub('---', '').gsub(/\n(\s*)/, "\n\\1#{' ' * (indent + indent)}")
    end
  end
end
