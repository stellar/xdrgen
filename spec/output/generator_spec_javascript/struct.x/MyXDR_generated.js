// Automatically generated on 2022-06-01T16:13:23+00:00
// DO NOT EDIT or your changes may be overwritten

/* jshint maxstatements:2147483647  */
/* jshint esnext:true  */

import * as XDR from 'js-xdr';


var types = XDR.config(xdr => {
// === xdr source ============================================================
//
//   typedef hyper int64;
//
// ===========================================================================
xdr.typedef("Int64", xdr.hyper());

// === xdr source ============================================================
//
//   struct MyStruct
//   {
//       int    someInt;
//       int64  aBigInt;
//       opaque someOpaque[10];
//       string someString<>;
//       string maxString<100>;
//   };
//
// ===========================================================================
xdr.struct("MyStruct", [
  ["someInt", xdr.int()],
  ["aBigInt", xdr.lookup("Int64")],
  ["someOpaque", xdr.opaque(10)],
  ["someString", xdr.string()],
  ["maxString", xdr.string(100)],
]);

});
export default types;
