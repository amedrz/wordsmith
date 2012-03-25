require 'rubygems'
require 'nokogiri'
require 'kindlegen'
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
  
  attr_accessor :subcommand, :args, :options, :name, :files, :stylesheet
  attr_reader :info
  
  OUTPUT_TYPES = ['html', 'epub', 'mobi', 'pdf']
  WORDSMITH_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  
  def initialize
    @subcommand = nil
    @args = []
    @options = {}
    @config = YAML::parse(File.open(local('.wordsmith'))).transform rescue {}
    @name = File.basename(local('.'))
  end

  def info(message)
    @info ||= []
    @info << message
  end
  
  def local(file)
    File.expand_path(File.join(Dir.pwd, file))
  end

  def base(file)
    File.join(WORDSMITH_ROOT, file)
  end
end
