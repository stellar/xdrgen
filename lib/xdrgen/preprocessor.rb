module Xdrgen
  class Preprocessor
    IfdefCondition = Struct.new(:name, :negated)

    attr_reader :cleaned_source

    def initialize(source)
      @original_source = source
      @line_conditions = {}  # line_number => [IfdefCondition, ...]
      process
    end

    # Returns the ifdef conditions active at the given byte offset in the source.
    def conditions_at_offset(offset)
      line = offset_to_line(offset)
      @line_conditions[line] || []
    end

    # Annotates the AST with ifdef conditions.
    # Sets `ifdefs` on definitions and their sub-parts (struct members, enum members, union arms).
    def annotate_ast(ast)
      walk_definitions(ast)
    end

    private

    def process
      lines = @original_source.split("\n", -1)
      cleaned_lines = []
      ifdef_stack = []

      lines.each_with_index do |line, i|
        stripped = line.strip
        if stripped =~ /\A%?\s*#ifdef\s+(\w+)/
          ifdef_stack.push(IfdefCondition.new($1, false))
          cleaned_lines << (" " * line.length)
        elsif stripped =~ /\A%?\s*#else\b/
          if ifdef_stack.any?
            top = ifdef_stack.last
            ifdef_stack[-1] = IfdefCondition.new(top.name, !top.negated)
          end
          cleaned_lines << (" " * line.length)
        elsif stripped =~ /\A%?\s*#endif\b/
          ifdef_stack.pop if ifdef_stack.any?
          cleaned_lines << (" " * line.length)
        else
          @line_conditions[i] = ifdef_stack.map { |c| IfdefCondition.new(c.name, c.negated) } if ifdef_stack.any?
          cleaned_lines << line
        end
      end

      @cleaned_source = cleaned_lines.join("\n")
    end

    def offset_to_line(offset)
      @offset_cache ||= build_offset_cache
      # Binary search for the line containing offset
      idx = @offset_cache.bsearch_index { |line_start| line_start > offset }
      idx ? idx - 1 : @offset_cache.length - 1
    end

    def build_offset_cache
      cache = [0]
      @original_source.each_char.with_index do |c, i|
        cache << (i + 1) if c == "\n"
      end
      cache
    end

    def walk_definitions(node)
      node.definitions.each do |defn|
        annotate_definition(defn)
      end
      node.namespaces.each { |ns| walk_definitions(ns) }
    end

    def annotate_definition(defn)
      defn_conditions = conditions_at_offset(defn.interval.first)
      defn.ifdefs = defn_conditions

      # Annotate sub-parts with conditions relative to the definition
      case defn
      when AST::Definitions::Struct
        defn.members.each do |m|
          all_conds = conditions_at_offset(m.interval.first)
          m.ifdefs = all_conds.drop(defn_conditions.length)
        end
      when AST::Definitions::Enum
        defn.members.each do |m|
          all_conds = conditions_at_offset(m.interval.first)
          m.ifdefs = all_conds.drop(defn_conditions.length)
        end
      when AST::Definitions::Union
        defn.normal_arms.each do |a|
          all_conds = conditions_at_offset(a.interval.first)
          a.ifdefs = all_conds.drop(defn_conditions.length)
        end
      end

      # Annotate nested definitions (inline struct/enum/union within members)
      if defn.respond_to?(:nested_definitions)
        defn.nested_definitions.each do |ndefn|
          annotate_definition(ndefn)
        end
      end
    end
  end
end
