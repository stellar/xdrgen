require 'fileutils'

module Xdrgen
  class Output

    attr_reader :source_path
    attr_reader :output_dir

    def initialize(source_path, output_dir)
      @source_path = source_path
      @output_dir = output_dir
      @files      = {}
    end

    def open(child_path)
      if @files.has_key?(child_path)
        raise Xdrgen::DuplicateFileError, "Cannot open #{child_path} twice"
      end 

      path = File.join @output_dir, child_path
      result = @files[child_path] = OutputFile.new(self, path)

      yield result if block_given?

      result
    end

    def close
      @files.values.each(&:close)
    end

  end
end