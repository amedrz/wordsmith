require 'rubygems'
require 'yaml'

require 'wordsmith/init'
require 'wordsmith/generate'
require 'wordsmith/publish'

require 'fileutils'
require 'pp'

class Wordsmith  
  include Init
  include Generate
  include Publish
  
  attr_accessor :subcommand, :args, :options
  attr_reader :info
  
  WORDSMITH_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  
  def initialize
    @subcommand = nil
    @args = []
    @options = {}
    @config = YAML::parse(File.open(local('.wordsmith'))).transform rescue {}
  end

  def info(message)
    @info ||= []
    @info << message
  end
end
