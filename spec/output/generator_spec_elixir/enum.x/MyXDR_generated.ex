defmodule MyXDR do
  @moduledoc """
  Automatically generated on 2022-06-01T16:13:23+00:00
  DO NOT EDIT or your changes may be overwritten

  Target implementation: exdr at https://hex.pm/packages/exdr
  """

  use XDR.Base

  comment ~S"""
  === xdr source ============================================================

      enum MessageType
      {
          ERROR_MSG,    
          HELLO,
          DONT_HAVE,
      
          GET_PEERS,   // gets a list of peers this guy knows about        
          PEERS,
      
          GET_TX_SET,  // gets a particular txset by hash        
          TX_SET,    
      
          GET_VALIDATIONS, // gets validations for a given ledger hash        
          VALIDATIONS,    
      
          TRANSACTION, //pass on a tx you have heard about        
          JSON_TRANSACTION,
      
          // FBA        
          GET_FBA_QUORUMSET,        
          FBA_QUORUMSET,    
          FBA_MESSAGE
      };

  ===========================================================================
  """
  define_type("MessageType", Enum,
    error_msg: 0,
    hello: 1,
    dont_have: 2,
    get_peers: 3,
    peers: 4,
    get_tx_set: 5,
    tx_set: 6,
    get_validations: 7,
    validations: 8,
    transaction: 9,
    json_transaction: 10,
    get_fba_quorumset: 11,
    fba_quorumset: 12,
    fba_message: 13
  )

  comment ~S"""
  === xdr source ============================================================

      enum Color {
          RED=0,  
          GREEN=1,  
          BLUE=2  
      };

  ===========================================================================
  """
  define_type("Color", Enum,
    red: 0,
    green: 1,
    blue: 2
  )

  comment ~S"""
  === xdr source ============================================================

      enum Color2 {
          RED2=RED,  
          GREEN2=1,  
          BLUE2=2  
      };

  ===========================================================================
  """
  define_type("Color2", Enum,
    red2: 0,
    green2: 1,
    blue2: 2
  )

end
