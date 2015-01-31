module Xdrgen::AST
  extend ActiveSupport::Autoload

  autoload :Constant
  autoload :DecimalConstant
  autoload :HeadecimalConstant
  autoload :OctalConstant

  autoload :Identifier

  autoload :Definition
  autoload :ConstDef
  autoload :EnumDef
  autoload :TypedefDef
  autoload :StructDef
  autoload :UnionDef
  autoload :NamespaceDef

  autoload :Declaration
  autoload :VoidDecl
  autoload :OpaqueDecl
  autoload :StringDecl
  autoload :ArrayDecl
  autoload :OptionalDecl
  autoload :SimpleDecl
end