// Automatically generated on 2022-06-01T16:25:17+00:00
// DO NOT EDIT or your changes may be overwritten

/* jshint maxstatements:2147483647  */
/* jshint esnext:true  */

import * as XDR from 'js-xdr';


var types = XDR.config(xdr => {

// === xdr source ============================================================
//
//   typedef opaque uint512[64];
//
// ===========================================================================
xdr.typedef("Uint512", xdr.opaque(64));

// === xdr source ============================================================
//
//   typedef opaque uint513<64>;
//
// ===========================================================================
xdr.typedef("Uint513", xdr.varOpaque(64));

// === xdr source ============================================================
//
//   typedef opaque uint514<>;
//
// ===========================================================================
xdr.typedef("Uint514", xdr.varOpaque());

// === xdr source ============================================================
//
//   typedef string str<64>;
//
// ===========================================================================
xdr.typedef("Str", xdr.string(64));

// === xdr source ============================================================
//
//   typedef string str2<>;
//
// ===========================================================================
xdr.typedef("Str2", xdr.string());

// === xdr source ============================================================
//
//   typedef opaque Hash[32];
//
// ===========================================================================
xdr.typedef("Hash", xdr.opaque(32));

// === xdr source ============================================================
//
//   typedef Hash Hashes1[12];
//
// ===========================================================================
xdr.typedef("Hashes1", xdr.array(xdr.lookup("Hash"), 12));

// === xdr source ============================================================
//
//   typedef Hash Hashes2<12>;
//
// ===========================================================================
xdr.typedef("Hashes2", xdr.varArray(xdr.lookup("Hash"), 12));

// === xdr source ============================================================
//
//   typedef Hash Hashes3<>;
//
// ===========================================================================
xdr.typedef("Hashes3", xdr.varArray(xdr.lookup("Hash"), 2147483647));

// === xdr source ============================================================
//
//   typedef Hash *optHash1;
//
// ===========================================================================
xdr.typedef("OptHash1", xdr.option(xdr.lookup("Hash")));

// === xdr source ============================================================
//
//   typedef Hash* optHash2;
//
// ===========================================================================
xdr.typedef("OptHash2", xdr.option(xdr.lookup("Hash")));

// === xdr source ============================================================
//
//   typedef int             int1;
//
// ===========================================================================
xdr.typedef("Int1", xdr.int());

// === xdr source ============================================================
//
//   typedef hyper           int2;
//
// ===========================================================================
xdr.typedef("Int2", xdr.hyper());

// === xdr source ============================================================
//
//   typedef unsigned int    int3;
//
// ===========================================================================
xdr.typedef("Int3", xdr.uint());

// === xdr source ============================================================
//
//   typedef unsigned hyper  int4;
//
// ===========================================================================
xdr.typedef("Int4", xdr.uhyper());

// === xdr source ============================================================
//
//   struct MyStruct
//   {
//       uint512 field1;
//       optHash1 field2;
//       int1 field3;
//       unsigned int field4;
//       float field5;
//       double field6;
//       bool field7;
//   };
//
// ===========================================================================
xdr.struct("MyStruct", [
  ["field1", xdr.lookup("Uint512")],
  ["field2", xdr.lookup("OptHash1")],
  ["field3", xdr.lookup("Int1")],
  ["field4", xdr.uint()],
  ["field5", xdr.float()],
  ["field6", xdr.double()],
  ["field7", xdr.bool()],
]);

// === xdr source ============================================================
//
//   struct LotsOfMyStructs
//   {
//       MyStruct members<>;
//   };
//
// ===========================================================================
xdr.struct("LotsOfMyStructs", [
  ["members", xdr.varArray(xdr.lookup("MyStruct"), 2147483647)],
]);

// === xdr source ============================================================
//
//   struct HasStuff
//   {
//     LotsOfMyStructs data;
//   };
//
// ===========================================================================
xdr.struct("HasStuff", [
  ["data", xdr.lookup("LotsOfMyStructs")],
]);

// === xdr source ============================================================
//
//   enum Color {
//     RED,
//     BLUE = 5,
//     GREEN
//   };
//
// ===========================================================================
xdr.enum("Color", {
  red: 0,
  blue: 5,
  green: 6,
});

// === xdr source ============================================================
//
//   const FOO = 1244;
//
// ===========================================================================
xdr.const("FOO", 1244);

// === xdr source ============================================================
//
//   const BAR = FOO;
//
// ===========================================================================
xdr.const("BAR", FOO);

// === xdr source ============================================================
//
//   enum {
//       BLAH_1,
//       BLAH_2
//     }
//
// ===========================================================================
xdr.enum("NesterNestedEnum", {
  blah1: 0,
  blah2: 1,
});

// === xdr source ============================================================
//
//   struct {
//       int blah;
//     }
//
// ===========================================================================
xdr.struct("NesterNestedStruct", [
  ["blah", xdr.int()],
]);

// === xdr source ============================================================
//
//   union switch (Color color) {
//       case RED:
//         void;
//       default:
//         int blah2;
//     }
//
// ===========================================================================
xdr.union("NesterNestedUnion", {
  switchOn: xdr.lookup("Color"),
  switchName: "color",
  switches: [
    ["red", xdr.void()],
  ],
  arms: {
    blah2: xdr.int(),
  },
  defaultArm: blah2,
});

// === xdr source ============================================================
//
//   struct Nester
//   {
//     enum {
//       BLAH_1,
//       BLAH_2
//     } nestedEnum;
//   
//     struct {
//       int blah;
//     } nestedStruct;
//   
//     union switch (Color color) {
//       case RED:
//         void;
//       default:
//         int blah2;
//     } nestedUnion;
//   
//   
//   };
//
// ===========================================================================
xdr.struct("Nester", [
  ["nestedEnum", xdr.lookup("NesterNestedEnum")],
  ["nestedStruct", xdr.lookup("NesterNestedStruct")],
  ["nestedUnion", xdr.lookup("NesterNestedUnion")],
]);

});
export default types;
