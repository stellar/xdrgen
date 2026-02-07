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
  "errors"
  "io"
  "fmt"

  "github.com/stellar/go-xdr/xdr3"
)

// XdrFilesSHA256 is the SHA256 hashes of source files.
var XdrFilesSHA256 = map[string]string{
  "spec/fixtures/generator/block_comments.x": "e13131bc4134f38da17b9d5e9f67d2695a69ef98e3ef272833f4c18d0cc88a30",
}

type xdrType interface {
  xdrType()
}

// ErrMaxDecodingDepthReached is returned when the maximum decoding depth is
// exceeded. This prevents stack overflow from deeply nested structures.
var ErrMaxDecodingDepthReached = errors.New("maximum decoding depth reached")

// Unmarshal reads an xdr element from `data` into `v`.
func Unmarshal(data []byte, v interface{}) (int, error) {
  if decodable, ok := v.(xdr.DecoderFrom); ok {
    d := xdr.NewDecoder(data)
    return decodable.DecodeFrom(d, d.MaxDepth())
  }
  // delegate to xdr package's Unmarshal
  return xdr.Unmarshal(data, v)
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
const (
  _AccountFlags_Min int32 = 1
  _AccountFlags_Max int32 = 1
)
var accountFlagsMap = map[int32]string{
  1: "AccountFlagsAuthRequiredFlag",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for AccountFlags
func (e AccountFlags) ValidEnum(v int32) bool {
  return v >= _AccountFlags_Min && v <= _AccountFlags_Max
}
// String returns the name of `e`
func (e AccountFlags) String() string {
  name, _ := accountFlagsMap[int32(e)]
  return name
}

// EncodeTo encodes this value using the Encoder.
func (e AccountFlags) EncodeTo(enc *xdr.Encoder) error {
  if int32(e) < _AccountFlags_Min || int32(e) > _AccountFlags_Max {
    return fmt.Errorf("'%d' is not a valid AccountFlags enum value", e)
  }
  _, err := enc.EncodeInt(int32(e))
  return err
}
var _ xdr.DecoderFrom = (*AccountFlags)(nil)
// DecodeFrom decodes this value from the given decoder.
func (e *AccountFlags) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding AccountFlags: %w", ErrMaxDecodingDepthReached)
  }
  v, n, err := d.DecodeInt()
  if err != nil {
    return n, fmt.Errorf("decoding AccountFlags: %w", err)
  }
  if v < _AccountFlags_Min || v > _AccountFlags_Max {
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
  d := xdr.NewDecoder(inp)
  _, err := s.DecodeFrom(d, d.MaxDepth())
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*AccountFlags)(nil)
  _ encoding.BinaryUnmarshaler = (*AccountFlags)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s AccountFlags) xdrType() {}

var _ xdrType = (*AccountFlags)(nil)

var fmtTest = fmt.Sprint("this is a dummy usage of fmt")
