module Xdrgen::AST
  class FixedSize < Treetop::Runtime::SyntaxNode
    def size
      size_t.text_value
    end

    def resolved_size
      return size unless named?

      resolved = root.find_definition(size)

      if resolved.blank?
        raise "Could not resolve constant: #{size}"
      end

      resolved.value
    end

    def named?
      size_t.is_a?(Xdrgen::AST::Identifier)
    end
  end
end
