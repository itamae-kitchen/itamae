require 'tracer'

Tracer.add_filter {|event, file, line, id, binding, klass|
  file.include?(File.expand_path('../..', __FILE__))
}
Tracer.on

require "itamae/version"
require "itamae/runner"
require "itamae/cli"
require "itamae/recipe"
require "itamae/resource"
require "itamae/recipe_children"
require "itamae/logger"
require "itamae/node"
require "itamae/backend"
require "itamae/notification"
require "itamae/definition"
require "itamae/config"
require "itamae/ext"

module Itamae
  # Your code goes here...
end

