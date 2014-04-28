require File.expand_path(File.dirname(__FILE__) + '/easy_diff')

# This library implements a mechanism for loading hashes of attributes into Chef's
# normal_attributes hash for the duration of a chef run, but without the side effect of
# saving those attributes to the node at the completion of a chef run.

# To use, first generate a hash of attributes:
#   * parse a flat JSON file
#   * query a key/value store
#   * run your own Ohai-type process
#   * etc.
#
# Then, in a recipe somewhere in your run_list, do:
# load_secrets(my_generated_hash)
#
# If my_generated_hash = { :attr1 => "value1", :attr2 => "value2" }, then you
# may freely reference these attributes as node[:attr1] or node[:attr2] in your recipes,
# and those sensitive attributes will not be saved to the node when the chef run completes.

require 'singleton'

class Classified
  include Singleton

  attr_accessor :secrets

  def initialize()
    @secrets = {}
  end

  def load_attributes(node_data, attrs)
    secrets.easy_merge! attrs
    node_data.easy_merge secrets
  end

  # given an attribute hash, returns hash minus secrets
  def redact(data)
    raise ArgumentError.new("argument to Classified#redact must be a Hash!") unless data.kind_of?(Hash)
    data.easy_unmerge(secrets).reject { |k,v| v.kind_of?(Hash) && v.empty? }
  end

end

# Constant referring to singleton instance
CLASSIFIED = Classified.instance

class Chef
  class Recipe
    def load_secrets(attrs)
      node.override.merge! CLASSIFIED.load_attributes(node.override.to_hash, attrs)
      Chef::Log.debug "loaded classified attributes: " + CLASSIFIED.secrets.inspect
    end
  end
end


# patch default node.save behavior to redact classified attributes
class Chef
  class Node
    alias_method :non_classified_save, :save

    def save
      if CLASSIFIED.secrets.empty?
          Chef::Log.debug("No classified attributes to redact.")
          non_classified_save
      else
          Chef::Log.debug("Redacting classified node attributes")
          self.override_attrs = CLASSIFIED.redact(self.override_attrs)
          non_classified_save
      end
    end
  end
end
