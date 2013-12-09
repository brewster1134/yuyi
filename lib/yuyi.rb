class Yuyi; end

require 'yuyi/cli'
require 'yuyi/config'
require 'yuyi/menu'
require 'yuyi/objects'
require 'yuyi/roll'

class Yuyi
  extend Yuyi::Cli
  include Yuyi::Config
end
