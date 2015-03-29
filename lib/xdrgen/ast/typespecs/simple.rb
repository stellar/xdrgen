module Xdrgen::AST::Typespecs
  module Simple
    include Base

    def resolved_type
      name = self.text_value.split("::").last
      root.find_definition name
    end

  end
end