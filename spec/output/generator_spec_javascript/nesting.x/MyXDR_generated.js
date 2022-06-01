// Automatically generated on 2022-06-01T16:13:23+00:00
// DO NOT EDIT or your changes may be overwritten

/* jshint maxstatements:2147483647  */
/* jshint esnext:true  */

import * as XDR from 'js-xdr';


var types = XDR.config(xdr => {
// === xdr source ============================================================
//
//   enum UnionKey {
//     ONE = 1,
//     TWO = 2,
//     OFFER = 3
//   };
//
// ===========================================================================
xdr.enum("UnionKey", {
  one: 1,
  two: 2,
  offer: 3,
});

// === xdr source ============================================================
//
//   typedef int Foo;
//
// ===========================================================================
xdr.typedef("Foo", xdr.int());

// === xdr source ============================================================
//
//   struct {
//               int someInt;
//           }
//
// ===========================================================================
xdr.struct("MyUnionOne", [
  ["someInt", xdr.int()],
]);

// === xdr source ============================================================
//
//   struct {
//               int someInt;
//               Foo foo;
//           }
//
// ===========================================================================
xdr.struct("MyUnionTwo", [
  ["someInt", xdr.int()],
  ["foo", xdr.lookup("Foo")],
]);

// === xdr source ============================================================
//
//   union MyUnion switch (UnionKey type)
//   {
//       case ONE:
//           struct {
//               int someInt;
//           } one;
//   
//       case TWO:
//           struct {
//               int someInt;
//               Foo foo;
//           } two;
//   
//       case OFFER:
//           void;
//   };
//
// ===========================================================================
xdr.union("MyUnion", {
  switchOn: xdr.lookup("UnionKey"),
  switchName: "type",
  switches: [
    ["one", "one"],
    ["two", "two"],
    ["offer", xdr.void()],
  ],
  arms: {
    one: xdr.lookup("MyUnionOne"),
    two: xdr.lookup("MyUnionTwo"),
  },
});

});
export default types;
