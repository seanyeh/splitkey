require "option_parser"
require "shamir"
require "./splitkey/commands/split"
require "./splitkey/commands/combine"

VERSION = "0.1.2"

def print_help
  puts <<-HELP
  splitkey v#{VERSION} - Split and combine secrets using Shamir's Secret Sharing

  USAGE:
    splitkey split [options]    Split a secret into shares
    splitkey combine [options]  Combine shares to recover secret

  SPLIT OPTIONS:
    -s, --secret SECRET         Secret to split (or use stdin)
    -n, --num-shares N          Total number of shares to create
    -k, --threshold K           Minimum shares needed to reconstruct
    -o, --output PREFIX         Output file prefix (default: share-)

  COMBINE OPTIONS:
    -i, --input FILES           Share files to combine (space-separated)
    -o, --output FILE           Output file for secret (default: stdout)

  GLOBAL OPTIONS:
    -h, --help                  Show this help
    -v, --version               Show version

  EXAMPLES:
    # Split a secret into 5 shares, requiring 3 to reconstruct
    splitkey split -s "my password" -n 5 -k 3

    # Combine shares to recover secret
    splitkey combine share-1.txt share-2.txt share-3.txt

  HELP
end

def print_version
  puts "splitkey v#{VERSION}"
end

if ARGV.empty?
  print_help
  exit 0
end

command = ARGV[0]

case command
when "-h", "--help"
  print_help
  exit 0
when "-v", "--version"
  print_version
  exit 0
when "split"
  Splitkey::Commands::Split.run(ARGV[1..])
when "combine"
  Splitkey::Commands::Combine.run(ARGV[1..])
else
  STDERR.puts "Unknown command: #{command}"
  STDERR.puts "Run 'splitkey --help' for usage"
  exit 1
end
