#
# Yuyi Core
# monkey patches, opening ruby classes, vendored library configurations, etc.
#
require 'cli_miami'
require 'tsort'

# cli_miami presets
CliMiami.set_preset :error, :color => :red
# CliMiami.set_preset :fine_print, :color => :cyan
CliMiami.set_preset :header, :color => :green
# CliMiami.set_preset :highlight_key, :indent => 2, :newline => false, :padding => 30, :justify => :rjust
# CliMiami.set_preset :highlight_value, :color => :blue, :style => :bright, :indent => 1
# CliMiami.set_preset :instruction, :color => :yellow, :indent => 2
# CliMiami.set_preset :list_item, :indent => 2
# CliMiami.set_preset :prompt, :color => :yellow, :style => :bold

# write nicer yaml when calling .to_yaml
#
class Array
  def to_yaml_style; :inline; end
end

# exposes .tsort on Hash instances
#
class Hash
  include TSort
  alias tsort_each_node each_key
  def tsort_each_child node, &block
    fetch(node).each(&block)
  end
end
