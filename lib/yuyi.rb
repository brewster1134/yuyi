class Yuyi; end

require 'yuyi/cli'
require 'yuyi/config'
require 'yuyi/dsl'
require 'yuyi/hash'
require 'yuyi/roll'
require 'yuyi/rolls'

class Yuyi
  extend Yuyi::Cli
  include Config
end
