# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   enum AccountFlags
#   { // masks for each flag
#       AUTH_REQUIRED_FLAG = 0x1
#   };
#
# ===========================================================================
class AccountFlags < XDR::Enum
  member :auth_required_flag, 1

  seal
end
