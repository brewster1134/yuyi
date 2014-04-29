class Yuyi; end

require 'yuyi/cli'
require 'yuyi/core'
require 'yuyi/menu'
require 'yuyi/roll'
require 'yuyi/source'

class Yuyi
  extend Yuyi::Cli

  NAME = 'Yuyi'
  VERSION = '0.1.1'
  DEFAULT_MENU = File.expand_path('~/.yuyi_menu')
end
