require 'ostruct'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
$: << File.expand_path('../../lib', __FILE__)
$: << File.expand_path('../../rolls', __FILE__)
$: << File.expand_path('../fixtures', __FILE__)

require 'yuyi'

RSpec.configure do |config|
  config.alias_example_to :the

  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = 'random'

  config.before do
    allow(Yuyi).to receive(:say)
  end
end

# Allow true/false to respond to Boolean class
module Boolean; end
class TrueClass; include Boolean; end
class FalseClass; include Boolean; end

class Object
  def var var, value = nil
    if self.instance_of? Class
      class_var var, value
    else
      instance_var var, value
    end
  end

  def class_var var, value = nil
    if value
      self.send(:class_variable_set, :"@@#{var}", value)
    else
      self.send(:class_variable_get, :"@@#{var}")
    end
  end

  def instance_var var, value = nil
    if value
      self.send(:instance_variable_set, :"@#{var}", value)
    else
      self.send(:instance_variable_get, :"@#{var}")
    end
  end
end
