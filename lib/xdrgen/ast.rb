module Xdrgen::AST
  extend ActiveSupport::Autoload

  autoload :Constant
  autoload :DecimalConstant
  autoload :HexadecimalConstant
  autoload :OctalConstant

  autoload :Top
  autoload :Identifier
  autoload :Whitespace

  autoload :FixedSize
  autoload :VarSize

  module Concerns
    extend ActiveSupport::Autoload

    autoload :Named
    autoload :Namespace
    autoload :Contained
    autoload :HasChildren
    autoload :HasDefinitions
    autoload :NestedDefinition
  end

  module Definitions
    extend ActiveSupport::Autoload

    autoload :Base
    autoload :Const
    autoload :Enum
    autoload :NestedEnum
    autoload :EnumMember
    autoload :Typedef
    autoload :Struct
    autoload :NestedStruct
    autoload :StructBody
    autoload :StructMember
    autoload :Union
    autoload :NestedUnion
    autoload :UnionBody
    autoload :UnionArm
    autoload :UnionArmCase
    autoload :UnionDefaultArm
    autoload :Namespace

  end

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
    autoload :UnsignedInt
    autoload :Hyper
    autoload :UnsignedHyper
    autoload :Float
    autoload :Double
    autoload :Quadruple
    autoload :Bool
    autoload :Opaque
    autoload :String
    autoload :Enum
    autoload :Struct
    autoload :Union
    autoload :Simple
  end
end
