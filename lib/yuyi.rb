class Yuyi
  NAME = 'Yuyi'
  VERSION = '0.1.0'
  DEFAULT_MENU = File.expand_path('~/.yuyi_menu')
end

require 'yuyi/cli'
require 'yuyi/core'
require 'yuyi/menu'
require 'yuyi/roll'
require 'yuyi/source'

class Yuyi
  extend Yuyi::Cli
end
