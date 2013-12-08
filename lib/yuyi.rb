class Yuyi; end

require 'yuyi/cli'
require 'yuyi/config'
require 'yuyi/objects'
require 'yuyi/roll'
require 'yuyi/rolls'

class Yuyi
  extend Yuyi::Cli
  include Yuyi::Config
end
