//lint:file-ignore S1005 The issue should be fixed in xdrgen. Unfortunately, there's no way to ignore a single file in staticcheck.
//lint:file-ignore U1000 fmtTest is not needed anywhere, should be removed in xdrgen.

// Package MyXDR is generated from:
//
//  spec/fixtures/generator/struct.x
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
  "spec/fixtures/generator/struct.x": "c6911a83390e3b499c078fd0c579132eacce88a4a0538d3b8b5e57747a58db4a",
}

var ErrMaxDecodingDepthReached = errors.New("maximum decoding depth reached")

type xdrType interface {
  xdrType()
}

type decoderFrom interface {
  DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error)
}

// Unmarshal reads an xdr element from `r` into `v`.
func Unmarshal(r io.Reader, v interface{}) (int, error) {
  return UnmarshalWithOptions(r, v, xdr.DefaultDecodeOptions)
}

// UnmarshalWithOptions works like Unmarshal but uses decoding options.
func UnmarshalWithOptions(r io.Reader, v interface{}, options xdr.DecodeOptions) (int, error) {
  if decodable, ok := v.(decoderFrom); ok {
    d := xdr.NewDecoderWithOptions(r, options)
    return decodable.DecodeFrom(d, options.MaxDepth)
  }
  // delegate to xdr package's Unmarshal
	return xdr.UnmarshalWithOptions(r, v, options)
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

// Int64 is an XDR Typedef defines as:
//
//   typedef hyper int64;
//
type Int64 int64

// EncodeTo encodes this value using the Encoder.
func (s Int64) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeHyper(int64(s)); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*Int64)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Int64) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Int64: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  var v int64
  v, nTmp, err = d.DecodeHyper()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Hyper: %w", err)
  }
  *s = Int64(v)
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Int64) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Int64) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Int64)(nil)
  _ encoding.BinaryUnmarshaler = (*Int64)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Int64) xdrType() {}

var _ xdrType = (*Int64)(nil)

// MyStruct is an XDR Struct defines as:
//
//   struct MyStruct
//    {
//        int    someInt;
//        int64  aBigInt;
//        opaque someOpaque[10];
//        string someString<>;
//        string maxString<100>;
//    };
//
type MyStruct struct {
  SomeInt int32 
  ABigInt Int64 
  SomeOpaque [10]byte `xdrmaxsize:"10"`
  SomeString string 
  MaxString string `xdrmaxsize:"100"`
}

// EncodeTo encodes this value using the Encoder.
func (s *MyStruct) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeInt(int32(s.SomeInt)); err != nil {
    return err
  }
  if   err = s.ABigInt.EncodeTo(e); err != nil {
    return err
  }
  if _, err = e.EncodeFixedOpaque(s.SomeOpaque[:]); err != nil {
    return err
  }
  if _, err = e.EncodeString(string(s.SomeString)); err != nil {
    return err
  }
  if _, err = e.EncodeString(string(s.MaxString)); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*MyStruct)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *MyStruct) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding MyStruct: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  s.SomeInt, nTmp, err = d.DecodeInt()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
  nTmp, err = s.ABigInt.DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int64: %w", err)
  }
  nTmp, err = d.DecodeFixedOpaqueInplace(s.SomeOpaque[:])
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding SomeOpaque: %w", err)
  }
  s.SomeString, nTmp, err = d.DecodeString(0)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding SomeString: %w", err)
  }
  s.MaxString, nTmp, err = d.DecodeString(100)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding MaxString: %w", err)
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s MyStruct) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *MyStruct) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*MyStruct)(nil)
  _ encoding.BinaryUnmarshaler = (*MyStruct)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s MyStruct) xdrType() {}

var _ xdrType = (*MyStruct)(nil)

var fmtTest = fmt.Sprint("this is a dummy usage of fmt")
