require 'specinfra/version'
require 'specinfra/backend'
require 'specinfra/command'
require 'specinfra/command_result'
require 'specinfra/configuration'
require 'specinfra/runner'
 
require 'specinfra/helper/detect_os'
require 'specinfra/helper/os'
require 'specinfra/helper/backend'
require 'specinfra/helper/docker'
require 'specinfra/helper/lxc'
require 'specinfra/helper/configuration'
require 'specinfra/helper/properties'
require 'specinfra/helper/set'
 
 
module Lightchef
  def self.backend=(backend)
    @backend = backend
  end

  def self.backend
    @backend
  end

  def self.create_backend(type)
    type = type.to_s.capitalize

    obj = Object.new
    obj.extend(::Specinfra::Helper.const_get(type))
    obj.backend.tap do |b|
      Lightchef.backend = b
    end
  end

  module SpecinfraHelpers
    module RunCommand
      def backend
        Lightchef.backend
      end
 
      def run_command(cmd)
        backend.run_command(cmd)
      end
    end
  end
end
 
Specinfra::Helper::Os.class_eval { remove_method(:run_command) }
 
module Specinfra
  class << self
    def configuration
      Specinfra::Configuration
    end
 
    def command
      Specinfra::Command::Base.new
    end
  end
 
  module Helper
    class DetectOs
      extend Specinfra::Helper::Os
      extend Lightchef::SpecinfraHelpers::RunCommand
    end
  end
 
  module Backend
    class Base
      include Specinfra::Helper::Os
      include Specinfra::Helper::Properties
      include Specinfra::Helper::Configuration
    end
  end
  module Command
    class Base
      include Specinfra::Helper::Os
      include Specinfra::Helper::Properties
      include Lightchef::SpecinfraHelpers::RunCommand
    end
 
    class Processor
      def self.backend
        $backend
      end
    end
  end
end
 
class Class
  def subclasses
    result = []
    ObjectSpace.each_object(Class) do |k|
      result << k if k < self
    end
    result
  end
end
 
class String
  def to_snake_case
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
 
  def to_camel_case
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end
end
 
class Runner
  def backend
    obj = Object.new
    obj.extend(Specinfra::Helper::Exec)
    obj.backend.tap do |b|
      Lightchef::Specinfra.backend = b
    end
  end
end
