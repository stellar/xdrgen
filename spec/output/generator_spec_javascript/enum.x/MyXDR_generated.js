// Automatically generated on 2022-06-01T16:13:23+00:00
// DO NOT EDIT or your changes may be overwritten

/* jshint maxstatements:2147483647  */
/* jshint esnext:true  */

import * as XDR from 'js-xdr';


var types = XDR.config(xdr => {
// === xdr source ============================================================
//
//   enum MessageType
//   {
//       ERROR_MSG,    
//       HELLO,
//       DONT_HAVE,
//   
//       GET_PEERS,   // gets a list of peers this guy knows about        
//       PEERS,
//   
//       GET_TX_SET,  // gets a particular txset by hash        
//       TX_SET,    
//   
//       GET_VALIDATIONS, // gets validations for a given ledger hash        
//       VALIDATIONS,    
//   
//       TRANSACTION, //pass on a tx you have heard about        
//       JSON_TRANSACTION,
//   
//       // FBA        
//       GET_FBA_QUORUMSET,        
//       FBA_QUORUMSET,    
//       FBA_MESSAGE
//   };
//
// ===========================================================================
xdr.enum("MessageType", {
  errorMsg: 0,
  hello: 1,
  dontHave: 2,
  getPeers: 3,
  peers: 4,
  getTxSet: 5,
  txSet: 6,
  getValidations: 7,
  validations: 8,
  transaction: 9,
  jsonTransaction: 10,
  getFbaQuorumset: 11,
  fbaQuorumset: 12,
  fbaMessage: 13,
});

// === xdr source ============================================================
//
//   enum Color {
//       RED=0,  
//       GREEN=1,  
//       BLUE=2  
//   };
//
// ===========================================================================
xdr.enum("Color", {
  red: 0,
  green: 1,
  blue: 2,
});

// === xdr source ============================================================
//
//   enum Color2 {
//       RED2=RED,  
//       GREEN2=1,  
//       BLUE2=2  
//   };
//
// ===========================================================================
xdr.enum("Color2", {
  red2: 0,
  green2: 1,
  blue2: 2,
});

});
export default types;
