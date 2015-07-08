module Xdrgen::AST::Typespecs
  module Base
    include Xdrgen::AST::Concerns::Contained

    def decl
      find_ancestors(Xdrgen::AST::Declarations::Base).last
    end

    def sub_type
      case decl
      when Xdrgen::AST::Declarations::Optional
        :optional
      when Xdrgen::AST::Declarations::Array
        decl.fixed? ? :array : :var_array
      else
        :simple
      end
    end

    def array_size
      raise "Called array_size on a non-array!" unless decl.is_a?(Xdrgen::AST::Declarations::Array)

      [decl.size_spec.named?, decl.size]
    end

  end
end
