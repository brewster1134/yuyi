# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
$: << File.expand_path('../../lib', __FILE__)
$: << File.expand_path('../../rolls', __FILE__)
$: << File.expand_path('../fixtures', __FILE__)

require 'yuyi'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = 'random'

  config.before do
    Yuyi.stub(:say)
  end
end

module Boolean; end
class TrueClass; include Boolean; end
class FalseClass; include Boolean; end

class Object
  def class_var class_var, value = nil
    if value
      self.send(:class_variable_set, :"@@#{class_var}", value)
    else
      self.send(:class_variable_get, :"@@#{class_var}")
    end
  end
end
