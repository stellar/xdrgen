module Xdrgen::AST::Typespecs
  module Simple
    include Base

    def resolved_type
      name = self.text_value.split("::").last
      result = root.find_definition name

      raise Xdrgen::TypeResolutionError, "Cannot resolve type `#{name}`" if result.blank?
      result
    end

  end
end
