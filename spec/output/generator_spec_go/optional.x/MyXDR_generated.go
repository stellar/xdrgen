//lint:file-ignore S1005 The issue should be fixed in xdrgen. Unfortunately, there's no way to ignore a single file in staticcheck.
//lint:file-ignore U1000 fmtTest is not needed anywhere, should be removed in xdrgen.

// Package MyXDR is generated from:
//
//  spec/fixtures/generator/optional.x
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
  "spec/fixtures/generator/optional.x": "3241e832fcf00bca4315ecb6c259621dafb0e302a63a993f5504b0b5cebb6bd7",
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

// Arr is an XDR Typedef defines as:
//
//   typedef int Arr[2];
//
type Arr [2]int32
// EncodeTo encodes this value using the Encoder.
func (s *Arr) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeInt(int32(s)); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*Arr)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Arr) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Arr: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  var v [2]int32
  v, nTmp, err = d.DecodeInt()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
  *s = Arr(v)
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Arr) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Arr) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Arr)(nil)
  _ encoding.BinaryUnmarshaler = (*Arr)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Arr) xdrType() {}

var _ xdrType = (*Arr)(nil)

// HasOptions is an XDR Struct defines as:
//
//   struct HasOptions
//    {
//      int* firstOption;
//      int *secondOption;
//      Arr *thirdOption;
//    };
//
type HasOptions struct {
  FirstOption *int32 
  SecondOption *int32 
  ThirdOption *Arr 
}

// EncodeTo encodes this value using the Encoder.
func (s *HasOptions) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeBool(s.FirstOption != nil); err != nil {
    return err
  }
  if s.FirstOption != nil {
  if _, err = e.EncodeInt(int32((*s.FirstOption))); err != nil {
    return err
  }
  }
  if _, err = e.EncodeBool(s.SecondOption != nil); err != nil {
    return err
  }
  if s.SecondOption != nil {
  if _, err = e.EncodeInt(int32((*s.SecondOption))); err != nil {
    return err
  }
  }
  if _, err = e.EncodeBool(s.ThirdOption != nil); err != nil {
    return err
  }
  if s.ThirdOption != nil {
  if   err = (*s.ThirdOption).EncodeTo(e); err != nil {
    return err
  }
  }
  return nil
}

var _ decoderFrom = (*HasOptions)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *HasOptions) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding HasOptions: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  var b bool
  b, nTmp, err = d.DecodeBool()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
  s.FirstOption = nil
  if b {
     s.FirstOption = new(Int)
  s.FirstOption, nTmp, err = d.DecodeInt()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
  }
  b, nTmp, err = d.DecodeBool()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
  s.SecondOption = nil
  if b {
     s.SecondOption = new(Int)
  s.SecondOption, nTmp, err = d.DecodeInt()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
  }
  b, nTmp, err = d.DecodeBool()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Arr: %w", err)
  }
  s.ThirdOption = nil
  if b {
     s.ThirdOption = new(Arr)
  nTmp, err = s.ThirdOption.DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Arr: %w", err)
  }
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s HasOptions) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *HasOptions) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*HasOptions)(nil)
  _ encoding.BinaryUnmarshaler = (*HasOptions)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s HasOptions) xdrType() {}

var _ xdrType = (*HasOptions)(nil)

var fmtTest = fmt.Sprint("this is a dummy usage of fmt")
