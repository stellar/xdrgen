//lint:file-ignore S1005 The issue should be fixed in xdrgen. Unfortunately, there's no way to ignore a single file in staticcheck.
//lint:file-ignore U1000 fmtTest is not needed anywhere, should be removed in xdrgen.

// Package MyXDR is generated from:
//
//  spec/fixtures/generator/const.x
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
  "spec/fixtures/generator/const.x": "0bff3b37592fcc16cad2fe10b9a72f5d39d033a114917c24e86a9ebd9cda9c37",
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

// Foo is an XDR Const defines as:
//
//   const FOO = 1;
//
const Foo = 1

// TestArray is an XDR Typedef defines as:
//
//   typedef int TestArray[FOO];
//
type TestArray [Foo]int32
// EncodeTo encodes this value using the Encoder.
func (s *TestArray) EncodeTo(e *xdr.Encoder) error {
  var err error
  for i := 0; i < len(s); i++ {
  if   _, err = e.EncodeInt(int32(s[i])); err != nil {
    return err
  }
  }
  return nil
}

var _ xdr.DecoderFrom = (*TestArray)(nil)
// DecodeFrom decodes this value from the given decoder.
func (s *TestArray) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding TestArray: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  var v [Foo]int32
  for i := 0; i < len(v); i++ {
    v[i], nTmp, err = d.DecodeInt()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
  }
  *s = TestArray(v)
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s TestArray) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *TestArray) UnmarshalBinary(inp []byte) error {
  d := xdr.NewDecoder(inp)
  _, err := s.DecodeFrom(d, d.MaxDepth())
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*TestArray)(nil)
  _ encoding.BinaryUnmarshaler = (*TestArray)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s TestArray) xdrType() {}

var _ xdrType = (*TestArray)(nil)

// TestArray2 is an XDR Typedef defines as:
//
//   typedef int TestArray2<FOO>;
//
type TestArray2 []int32
// XDRMaxSize implements the Sized interface for TestArray2
func (e TestArray2) XDRMaxSize() int {
  return 1
}
// EncodeTo encodes this value using the Encoder.
func (s TestArray2) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeUint(uint32(len(s))); err != nil {
    return err
  }
  for i := 0; i < len(s); i++ {
  if   _, err = e.EncodeInt(int32(s[i])); err != nil {
    return err
  }
  }
  return nil
}

var _ xdr.DecoderFrom = (*TestArray2)(nil)
// DecodeFrom decodes this value from the given decoder.
func (s *TestArray2) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding TestArray2: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  var v []int32
  var l uint32
  l, nTmp, err = d.DecodeUint()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
  if l > 1 {
    return n, fmt.Errorf("decoding int32: data size (%d) exceeds size limit (1)", l)
  }
  if l == 0 {
    v = v[:0]
  } else {
    if uint(d.Remaining()) < uint(l) {
        return n, fmt.Errorf("decoding int32: length (%d) exceeds remaining input length (%d)", l, d.Remaining())
    }
    if cap(v) >= int(l) {
      v = v[:l]
    } else {
      v = make([]int32, l)
    }
    for i := uint32(0); i < l; i++ {
      v[i], nTmp, err = d.DecodeInt()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
    }
  }
  *s = TestArray2(v)
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s TestArray2) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *TestArray2) UnmarshalBinary(inp []byte) error {
  d := xdr.NewDecoder(inp)
  _, err := s.DecodeFrom(d, d.MaxDepth())
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*TestArray2)(nil)
  _ encoding.BinaryUnmarshaler = (*TestArray2)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s TestArray2) xdrType() {}

var _ xdrType = (*TestArray2)(nil)

var fmtTest = fmt.Sprint("this is a dummy usage of fmt")
