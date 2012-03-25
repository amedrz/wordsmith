require 'subcommand'

class Wordsmith
  include Subcommands

  def info(message)
    puts message
  end

  module CLI

    def run
      parse_options
      if @subcommand && self.respond_to?(@subcommand)
        begin
          self.send @subcommand, @args
        rescue Object => e
          error e
        end
      else
        help
      end
    end

    def error(e)
      puts 'Error: ' + e.to_s
    end

    def help
      puts print_actions
    end

    def parse_options
      @options = {}
      global_options do |opts|
        opts.banner = "Usage: #{$0} [options] [subcommand [options]]"
        opts.description = "wordsmith helps you write books collectively with Git"
        opts.separator ""
        opts.separator "Global options are:"
        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          @options[:verbose] = v
        end
      end

      command :init, :new, :n do |opts|
        opts.banner = "Usage: wordsmith new (directory)"
        opts.description = "initialize a new book layout"
      end

      command :generate, :g do |opts|
        opts.banner = "Usage: wordsmith generate [options]"
        opts.description = "generate digital formats"
      end

      command :publish do |opts|
        opts.banner = "Usage: wordsmith publish"
        opts.description = "publish your book to github project page"
      end

      @subcommand = opt_parse
      @args = ARGV
    end

    # DISPLAY HELPER FUNCTIONS #

    def l(info, size)
      clean(info)[0, size].ljust(size)
    end

    def r(info, size)
      clean(info)[0, size].rjust(size)
    end

    def clean(info)
      info.to_s.gsub("\n", ' ')
    end

  end

  include CLI
end
