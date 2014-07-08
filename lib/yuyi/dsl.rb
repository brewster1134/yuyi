require 'open3'
require 'readline'
require 'yaml'

module Yuyi::Dsl
  # Configure readline
  Readline.completion_append_character = '/'

  attr_accessor :verbose, :upgrade, :menu_path

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
      Yuyi.colorize text, 31
    when :success
      Yuyi.colorize text, 32
    when :warn
      Yuyi.colorize text, 33
    else
      Yuyi.colorize text, args[:color]
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
    yield output if block
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
    text.flatten!

    File.open(File.expand_path(file), 'a+') do |file|
      full_text = (text * "\n") + "\n"

      unless file.read.include? full_text
        file.write full_text
      end
    end
  end

  # Delete specific lines from an existing file
  #
  def delete_from_file file, *text
    text.flatten!

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
    run('/usr/bin/sw_vers -productVersion').chomp[/10\.\d+/].to_f
  end
end
