//lint:file-ignore S1005 The issue should be fixed in xdrgen. Unfortunately, there's no way to ignore a single file in staticcheck.
//lint:file-ignore U1000 fmtTest is not needed anywhere, should be removed in xdrgen.

// Package MyXDR is generated from:
//
//  spec/fixtures/generator/block_comments.x
//
// DO NOT EDIT or your changes may be overwritten
package MyXDR

import (
  "bytes"
  "encoding"
  "io"
  "fmt"

  "github.com/stellar/go-xdr/xdr3"
)

// XdrFilesSHA256 is the SHA256 hashes of source files.
var XdrFilesSHA256 = map[string]string{
  "spec/fixtures/generator/block_comments.x": "25a020c7235093dbb580251fab115afa41c47b0453b992d801d9d85e646ca927",
}

type xdrType interface {
  xdrType()
}

type decoderFrom interface {
  DecodeFrom(d *xdr.Decoder) (int, error)
}

// Unmarshal reads an xdr element from `r` into `v`.
func Unmarshal(r io.Reader, v interface{}) (int, error) {
  if decodable, ok := v.(decoderFrom); ok {
    d := xdr.NewDecoder(r)
    return decodable.DecodeFrom(d)
  }
  // delegate to xdr package's Unmarshal
	return xdr.Unmarshal(r, v)
}

// Marshal writes an xdr element `v` into `w`.
func Marshal(w io.Writer, v interface{}) (int, error) {
  if _, ok := v.(xdrType); ok {
    if bm, ok := v.(encoding.BinaryMarshaler); ok {
      b, err := bm.MarshalBinary()
      if err != nil {
        return 0, err
      }
      return w.Write(b)
    }
  }
  // delegate to xdr package's Marshal
  return xdr.Marshal(w, v)
}

// AccountFlags is an XDR Enum defines as:
//
//   enum AccountFlags
//    { // masks for each flag
//        AUTH_REQUIRED_FLAG = 0x1
//    };
//
type AccountFlags int32
const (
  AccountFlagsAuthRequiredFlag AccountFlags = 1
)
var accountFlagsMap = map[int32]string{
  1: "AccountFlagsAuthRequiredFlag",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for AccountFlags
func (e AccountFlags) ValidEnum(v int32) bool {
  _, ok := accountFlagsMap[v]
  return ok
}
// String returns the name of `e`
func (e AccountFlags) String() string {
  name, _ := accountFlagsMap[int32(e)]
  return name
}

// EncodeTo encodes this value using the Encoder.
func (e AccountFlags) EncodeTo(enc *xdr.Encoder) error {
  if _, ok := accountFlagsMap[int32(e)]; !ok {
    return fmt.Errorf("'%d' is not a valid AccountFlags enum value", e)
  }
  _, err := enc.EncodeInt(int32(e))
  return err
}
var _ decoderFrom = (*AccountFlags)(nil)
// DecodeFrom decodes this value using the Decoder.
func (e *AccountFlags) DecodeFrom(d *xdr.Decoder) (int, error) {
  v, n, err := d.DecodeInt()
  if err != nil {
    return n, fmt.Errorf("decoding AccountFlags: %s", err)
  }
  if _, ok := accountFlagsMap[v]; !ok {
    return n, fmt.Errorf("'%d' is not a valid AccountFlags enum value", v)
  }
  *e = AccountFlags(v)
  return n, nil
}
// MarshalBinary implements encoding.BinaryMarshaler.
func (s AccountFlags) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *AccountFlags) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  d := xdr.NewDecoder(r)
  _, err := s.DecodeFrom(d)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*AccountFlags)(nil)
  _ encoding.BinaryUnmarshaler = (*AccountFlags)(nil)
)

// xdrType signals that this type is an type representing
// representing XDR values defined by this package.
func (s AccountFlags) xdrType() {}

var _ xdrType = (*AccountFlags)(nil)

        var fmtTest = fmt.Sprint("this is a dummy usage of fmt")

