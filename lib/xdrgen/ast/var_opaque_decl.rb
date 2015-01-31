module Xdrgen::AST
  class VarOpaqueDecl < Declaration 
    
    def max_size
      var_size_spec.
      size.
      text_value.
      to_i
    end

  end
end