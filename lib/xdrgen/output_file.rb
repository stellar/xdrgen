require 'fileutils'
module Xdrgen
  class OutputFile
    SPACES_PER_INDENT = 2

    def initialize(output, path)
      @output         = output
      @path           = path
      @current_indent = 0

      FileUtils.mkdir_p File.dirname(@path)
      @io = File.open(@path, 'w')
      write_top_matter
    end

    def close
      @io.close
    end

    def write_top_matter
      puts <<-EOS.strip_heredoc
        # Automatically generated from #{@output.source_path}
        # DO NOT EDIT or your changes may be overwritten
      
        require 'xdr'
      EOS
    end

    def puts(s="")
      write_break_if_needed
      @io.puts indented(s)
    end

    def indent
      @current_indent += 1
      yield
    ensure
      @current_indent -= 1
    end

    def break
      @break_needed = true
    end

    def unbreak
      @break_needed = false
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

  end
end