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

    def write(s)
      @io.write indented(s)
    end

    def write_top_matter
      puts <<-EOS.strip_heredoc
        # Automatically generated from #{@output.source_path}
        # DO NOT EDIT or your changes may be overwritten
      
      EOS
    end

    def puts(s)
      @io.puts indented(s)
    end

    def indent
      @current_indent += 1
      yield
    ensure
      @current_indent -= 1
    end

    private
    def indented(s)
      s.indent(@current_indent * SPACES_PER_INDENT)
    end

  end
end