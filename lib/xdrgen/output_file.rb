require 'fileutils'
module Xdrgen
  class OutputFile
    SPACES_PER_INDENT = 2

    def initialize(path)
      @path           = path
      @current_indent = 0

      FileUtils.mkdir_p File.dirname(@path)
      @io = File.open(@path, 'w')
    end

    def close
      @io.close
    end

    def puts(s="")
      write_break_if_needed
      @io.puts indented(s)
    end

    def puts_if(s=nil)
      self.puts(s) if s
    end

    def indent(step=1)
      @current_indent += step
      yield
    ensure
      @current_indent -= step
    end

    def break
      @break_needed = true
    end

    def unbreak
      @break_needed = false
    end

    def balance_after(balance_regex, include_space=false)
      @old_io = @io
      @io = StringIO.new
      yield
      raw = @io.string
      @old_io.puts balance_string(raw, balance_regex, include_space)
    ensure
      @io = @old_io
      @old_io = nil
    end

    private
    def indented(s)
      s.indent(@current_indent * SPACES_PER_INDENT)
    end

    def write_break_if_needed
      return unless @break_needed
      @io.puts ""
    ensure
      @break_needed = false
    end

    def balance_string(raw, balance_regex, include_space)
      lines            = raw.split("\n")
      splits           = lines.map{|l| split_line_at(l, balance_regex)}

      max_split_length = splits.map{|s| s.first.length }.compact.max || -1
      max_split_length += 1 if include_space

      splits.map do |first, rest|
        next first if rest.blank?

        (first || "").ljust(max_split_length) + rest
      end.join("\n")
    end

    def split_line_at(line, regex)
      match = regex.match(line)

      if match.blank?
        [line.rstrip, nil]
      else
        split_point = match.end(0)
        [line[0...split_point], line[split_point..-1]]
      end
    end

  end
end
