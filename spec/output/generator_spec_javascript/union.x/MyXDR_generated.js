// Automatically generated on 2022-06-01T16:13:23+00:00
// DO NOT EDIT or your changes may be overwritten

/* jshint maxstatements:2147483647  */
/* jshint esnext:true  */

import * as XDR from 'js-xdr';


var types = XDR.config(xdr => {
// === xdr source ============================================================
//
//   typedef int Error;
//
// ===========================================================================
xdr.typedef("Error", xdr.int());

// === xdr source ============================================================
//
//   typedef int Multi;
//
// ===========================================================================
xdr.typedef("Multi", xdr.int());

// === xdr source ============================================================
//
//   enum UnionKey {
//     ERROR,
//     MULTI
//   };
//
// ===========================================================================
xdr.enum("UnionKey", {
  error: 0,
  multi: 1,
});

// === xdr source ============================================================
//
//   union MyUnion switch (UnionKey type)
//   {
//       case ERROR:
//           Error error;
//       case MULTI:
//           Multi things<>;
//   
//   
//   };
//
// ===========================================================================
xdr.union("MyUnion", {
  switchOn: xdr.lookup("UnionKey"),
  switchName: "type",
  switches: [
    ["error", "error"],
    ["multi", "things"],
  ],
  arms: {
    error: xdr.lookup("Error"),
    things: xdr.varArray(xdr.lookup("Multi"), 2147483647),
  },
});

// === xdr source ============================================================
//
//   union IntUnion switch (int type)
//   {
//       case 0:
//           Error error;
//       case 1:
//           Multi things<>;
//   
//   };
//
// ===========================================================================
xdr.union("IntUnion", {
  switchOn: xdr.int(),
  switchName: "type",
  switches: [
    [0, "error"],
    [1, "things"],
  ],
  arms: {
    error: xdr.lookup("Error"),
    things: xdr.varArray(xdr.lookup("Multi"), 2147483647),
  },
});

// === xdr source ============================================================
//
//   typedef IntUnion IntUnion2;
//
// ===========================================================================
xdr.typedef("IntUnion2", xdr.lookup("IntUnion"));

});
export default types;
