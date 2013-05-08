require 'rubygems'
require 'bundler/setup'

require 'nokogiri'
require 'kindlegen'
require 'yaml'
require 'git'

require 'fileutils'
require 'pp'

require 'wordsmith/init'
require 'wordsmith/generate'
require 'wordsmith/publish'

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
