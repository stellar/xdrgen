# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   enum MyEnum {
#       MEMBER_A = 0,
#       MEMBER_B = 1,
#                   
#       MEMBER_C = 2,
#         
#       MEMBER_D = 3
#   };
#
# ===========================================================================
class MyEnum < XDR::Enum
  member :member_a, 0
  member :member_b, 1
  member :member_c, 2
  member :member_d, 3

  seal
end
