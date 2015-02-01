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

  autoload :FixedSize
  autoload :VarSize

  module Declarations
    extend ActiveSupport::Autoload

    autoload :Base
    autoload :Opaque
    autoload :Array
    autoload :String
    autoload :Optional
    autoload :Void
    autoload :Simple
  end

  module Typespecs
    extend ActiveSupport::Autoload

    autoload :Base
    autoload :Int
    autoload :Opaque
    autoload :String
    autoload :Enum
    autoload :Struct
    autoload :Union
    autoload :Simple
  end
end