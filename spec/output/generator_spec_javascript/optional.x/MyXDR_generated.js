// Automatically generated on 2022-06-01T16:13:23+00:00
// DO NOT EDIT or your changes may be overwritten

/* jshint maxstatements:2147483647  */
/* jshint esnext:true  */

import * as XDR from 'js-xdr';


var types = XDR.config(xdr => {
// === xdr source ============================================================
//
//   typedef int Arr[2];
//
// ===========================================================================
xdr.typedef("Arr", xdr.array(xdr.int(), 2));

// === xdr source ============================================================
//
//   struct HasOptions
//   {
//     int* firstOption;
//     int *secondOption;
//     Arr *thirdOption;
//   };
//
// ===========================================================================
xdr.struct("HasOptions", [
  ["firstOption", xdr.option(xdr.int())],
  ["secondOption", xdr.option(xdr.int())],
  ["thirdOption", xdr.option(xdr.lookup("Arr"))],
]);

});
export default types;
