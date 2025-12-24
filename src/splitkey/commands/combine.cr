require "option_parser"

module Splitkey::Commands
  module Combine
    def self.run(args : Array(String))
      share_files = [] of String

      parser = OptionParser.new do |opts|
        opts.on("-h", "--help", "Show help") do
          print_help
          exit 0
        end
        opts.unknown_args do |unknown_args|
          share_files = unknown_args
        end
      end

      begin
        parser.parse(args)
      rescue ex
        STDERR.puts "Error parsing options: #{ex.message}"
        exit 1
      end

      if share_files.empty?
        STDERR.puts "Error: No share files provided"
        STDERR.puts "Usage: splitkey combine <share-files...>"
        exit 1
      end

      begin
        # Read and parse shares from files
        shares = [] of Shamir::Share
        share_files.each do |file|
          unless File.exists?(file)
            STDERR.puts "Error: File not found: #{file}"
            exit 1
          end

          hex_data = File.read(file).strip
          shares << Shamir::Share.from_hex(hex_data)
        end

        # Combine shares to recover secret
        secret = Shamir.combine(shares)

        # Output the secret to stdout as a string
        puts String.new(secret)
      rescue ex : ArgumentError
        STDERR.puts "Error: #{ex.message}"
        exit 1
      rescue ex
        STDERR.puts "Unexpected error: #{ex.message}"
        exit 1
      end
    end

    private def self.print_help
      puts <<-HELP
      splitkey combine - Combine shares to recover secret

      USAGE:
        splitkey combine <share-files...>

      OPTIONS:
        -h, --help                  Show this help

      EXAMPLE:
        splitkey combine share-1.txt share-2.txt share-3.txt

      HELP
    end
  end
end
