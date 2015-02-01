module Xdrgen::AST
  extend ActiveSupport::Autoload

  autoload :Constant
  autoload :DecimalConstant
  autoload :HeadecimalConstant
  autoload :OctalConstant

  autoload :Top
  autoload :Identifier

  autoload :FixedSize
  autoload :VarSize

  module Concerns
    extend ActiveSupport::Autoload
    
    autoload :Named
    autoload :HasChildren
    autoload :HasDefinitions
  end

  module Definitions
    extend ActiveSupport::Autoload

    autoload :Base
    autoload :Const
    autoload :Enum
    autoload :Typedef
    autoload :Struct
    autoload :StructBody
    autoload :StructMember
    autoload :Union
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
    autoload :Float
    autoload :Bool
    autoload :Opaque
    autoload :String
    autoload :Enum
    autoload :Struct
    autoload :Union
    autoload :Simple
  end
end