# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   enum MessageType
#   {
#       ERROR_MSG,    
#       HELLO,
#       DONT_HAVE,
#   
#       GET_PEERS,   // gets a list of peers this guy knows about        
#       PEERS,
#   
#       GET_TX_SET,  // gets a particular txset by hash        
#       TX_SET,    
#   
#       GET_VALIDATIONS, // gets validations for a given ledger hash        
#       VALIDATIONS,    
#   
#       TRANSACTION, //pass on a tx you have heard about        
#       JSON_TRANSACTION,
#   
#       // FBA        
#       GET_FBA_QUORUMSET,        
#       FBA_QUORUMSET,    
#       FBA_MESSAGE
#   };
#
# ===========================================================================
class MessageType < XDR::Enum
  member :error_msg,         0
  member :hello,             1
  member :dont_have,         2
  member :get_peers,         3
  member :peers,             4
  member :get_tx_set,        5
  member :tx_set,            6
  member :get_validations,   7
  member :validations,       8
  member :transaction,       9
  member :json_transaction,  10
  member :get_fba_quorumset, 11
  member :fba_quorumset,     12
  member :fba_message,       13

  seal
end
