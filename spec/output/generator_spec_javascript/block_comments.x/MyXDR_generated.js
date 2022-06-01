// Automatically generated on 2022-06-01T16:13:22+00:00
// DO NOT EDIT or your changes may be overwritten

/* jshint maxstatements:2147483647  */
/* jshint esnext:true  */

import * as XDR from 'js-xdr';


var types = XDR.config(xdr => {
// === xdr source ============================================================
//
//   enum AccountFlags
//   { // masks for each flag
//       AUTH_REQUIRED_FLAG = 0x1
//   };
//
// ===========================================================================
xdr.enum("AccountFlags", {
  authRequiredFlag: 1,
});

});
export default types;
