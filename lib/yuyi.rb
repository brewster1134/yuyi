class Yuyi; end

require 'yuyi/cli'
require 'yuyi/core'
require 'yuyi/menu'
require 'yuyi/roll'
require 'yuyi/source'

class Yuyi
  require 'yaml'
  extend Yuyi::Cli

  NAME = 'Yuyi'
  VERSION = YAML.load(File.read(File.dirname(__FILE__) + '/../.new'))['version']
  DEFAULT_MENU = File.expand_path('~/yuyi_menu')
end
