require "option_parser"
require "qr-code"
require "qr-code/export/png"
require "base64"

module Splitkey::Commands
  module Split
    def self.run(args : Array(String))
      secret : String? = nil
      n : Int32? = nil
      k : Int32? = nil
      output_prefix = "share"
      format = "text"
      html_title = "Secret"

      parser = OptionParser.new do |opts|
        opts.on("-s SECRET", "--secret=SECRET", "Secret to split") { |s| secret = s }
        opts.on("-n N", "--num-shares=N", "Total number of shares") { |num| n = num.to_i }
        opts.on("-k K", "--threshold=K", "Minimum shares needed") { |num| k = num.to_i }
        opts.on("-o PREFIX", "--output=PREFIX", "Output file prefix") { |prefix| output_prefix = prefix }
        opts.on("-f FORMAT", "--format=FORMAT", "Output format: text, qr, html (default: text)") { |f| format = f.downcase }
        opts.on("--html-title TITLE", "Title for HTML output (default: Secret)") { |title| html_title = title }
        opts.on("-h", "--help", "Show help") do
          print_help
          exit 0
        end
      end

      begin
        parser.parse(args)
      rescue ex
        STDERR.puts "Error parsing options: #{ex.message}"
        exit 1
      end

      if secret.nil?
        STDERR.puts "Error: --secret is required"
        exit 1
      end
      if n.nil?
        STDERR.puts "Error: --num-shares is required"
        exit 1
      end
      if k.nil?
        STDERR.puts "Error: --threshold is required"
        exit 1
      end

      unless ["text", "qr", "html"].includes?(format)
        STDERR.puts "Error: Invalid format '#{format}'. Must be 'text', 'qr', or 'html'"
        exit 1
      end

      # Create output directory if prefix contains a path
      dir = File.dirname(output_prefix)
      if dir != "."
        Dir.mkdir_p(dir)
      end

      begin
        shares = Shamir.split(secret.not_nil!, n.not_nil!, k.not_nil!)

        # Save each share to a file
        shares.each do |share|
          case format
          when "text"
            filename = "#{output_prefix}-#{share.x}.txt"
            File.write(filename, share.to_hex)
            puts "Created #{filename}"
          when "qr"
            filename = "#{output_prefix}-#{share.x}.png"
            generate_qr_code(share.to_hex, filename)
            puts "Created #{filename}"
          when "html"
            filename = "#{output_prefix}-#{share.x}.html"
            generate_html(share.to_hex, filename, html_title)
            puts "Created #{filename}"
          end
        end

        puts "\nSuccessfully split secret into #{n} shares (threshold: #{k})"
      rescue ex : ArgumentError
        STDERR.puts "Error: #{ex.message}"
        exit 1
      rescue ex
        STDERR.puts "Unexpected error: #{ex.message}"
        exit 1
      end
    end

    private def self.generate_qr_code(data : String, filename : String)
      png_bytes = QRCode.new(data).as_png(size: 256)
      File.write(filename, png_bytes)
    end

    private def self.generate_html(data : String, filename : String, title : String)
      png_bytes = QRCode.new(data).as_png(size: 256)
      base64_png = Base64.strict_encode(png_bytes)

      html = <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>#{title}</title>
        <style>
          body { font-family: monospace; text-align: center; margin: 50px; }
          h1 { font-size: 24px; }
          img { margin: 20px 0; }
          .value { font-size: 10px; color: #333; word-wrap: break-word; max-width: 500px; margin: 0 auto; }
        </style>
      </head>
      <body>
        <h1>#{title}</h1>
        <img src="data:image/png;base64,#{base64_png}" alt="QR Code">
        <div class="value">#{data}</div>
      </body>
      </html>
      HTML

      File.write(filename, html)
    end

    private def self.print_help
      puts <<-HELP
      splitkey split - Split a secret into shares

      USAGE:
        splitkey split [options]

      OPTIONS:
        -s, --secret SECRET         Secret to split
        -n, --num-shares N       Total number of shares to create
        -k, --threshold K           Minimum shares needed to reconstruct
        -o, --output PREFIX         Output file prefix (default: share)
        -f, --format FORMAT         Output format: text, qr, html (default: text)
            --html-title TITLE      Title for HTML output (default: Secret)
        -h, --help                  Show this help

      EXAMPLES:
        splitkey split -s "my password" -n 5 -k 3
        splitkey split -s "my password" -n 5 -k 3 -f qr -o backup/secret

      HELP
    end
  end
end
