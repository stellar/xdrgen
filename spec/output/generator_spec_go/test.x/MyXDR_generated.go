//lint:file-ignore S1005 The issue should be fixed in xdrgen. Unfortunately, there's no way to ignore a single file in staticcheck.
//lint:file-ignore U1000 fmtTest is not needed anywhere, should be removed in xdrgen.

// Package MyXDR is generated from:
//
//  spec/fixtures/generator/test.x
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
  "spec/fixtures/generator/test.x": "d29a98a6a3b9bf533a3e6712d928e0bed655e0f462ac4dae810c65d52ca9af41",
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

// Uint512 is an XDR Typedef defines as:
//
//   typedef opaque uint512[64];
//
type Uint512 [64]byte
// XDRMaxSize implements the Sized interface for Uint512
func (e Uint512) XDRMaxSize() int {
  return 64
}

// EncodeTo encodes this value using the Encoder.
func (s *Uint512) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeFixedOpaque(s[:]); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*Uint512)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Uint512) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Uint512: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  nTmp, err = d.DecodeFixedOpaqueInplace(s[:])
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Uint512: %w", err)
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Uint512) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Uint512) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Uint512)(nil)
  _ encoding.BinaryUnmarshaler = (*Uint512)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Uint512) xdrType() {}

var _ xdrType = (*Uint512)(nil)

// Uint513 is an XDR Typedef defines as:
//
//   typedef opaque uint513<64>;
//
type Uint513 []byte
// XDRMaxSize implements the Sized interface for Uint513
func (e Uint513) XDRMaxSize() int {
  return 64
}

// EncodeTo encodes this value using the Encoder.
func (s Uint513) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeOpaque(s[:]); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*Uint513)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Uint513) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Uint513: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  (*s), nTmp, err = d.DecodeOpaque(64)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Uint513: %w", err)
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Uint513) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Uint513) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Uint513)(nil)
  _ encoding.BinaryUnmarshaler = (*Uint513)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Uint513) xdrType() {}

var _ xdrType = (*Uint513)(nil)

// Uint514 is an XDR Typedef defines as:
//
//   typedef opaque uint514<>;
//
type Uint514 []byte

// EncodeTo encodes this value using the Encoder.
func (s Uint514) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeOpaque(s[:]); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*Uint514)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Uint514) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Uint514: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  (*s), nTmp, err = d.DecodeOpaque(0)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Uint514: %w", err)
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Uint514) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Uint514) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Uint514)(nil)
  _ encoding.BinaryUnmarshaler = (*Uint514)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Uint514) xdrType() {}

var _ xdrType = (*Uint514)(nil)

// Str is an XDR Typedef defines as:
//
//   typedef string str<64>;
//
type Str string
// XDRMaxSize implements the Sized interface for Str
func (e Str) XDRMaxSize() int {
  return 64
}

// EncodeTo encodes this value using the Encoder.
func (s Str) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeString(string(s)); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*Str)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Str) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Str: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  var v string
  v, nTmp, err = d.DecodeString(64)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Str: %w", err)
  }
  *s = Str(v)
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Str) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Str) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Str)(nil)
  _ encoding.BinaryUnmarshaler = (*Str)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Str) xdrType() {}

var _ xdrType = (*Str)(nil)

// Str2 is an XDR Typedef defines as:
//
//   typedef string str2<>;
//
type Str2 string

// EncodeTo encodes this value using the Encoder.
func (s Str2) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeString(string(s)); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*Str2)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Str2) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Str2: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  var v string
  v, nTmp, err = d.DecodeString(0)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Str2: %w", err)
  }
  *s = Str2(v)
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Str2) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Str2) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Str2)(nil)
  _ encoding.BinaryUnmarshaler = (*Str2)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Str2) xdrType() {}

var _ xdrType = (*Str2)(nil)

// Hash is an XDR Typedef defines as:
//
//   typedef opaque Hash[32];
//
type Hash [32]byte
// XDRMaxSize implements the Sized interface for Hash
func (e Hash) XDRMaxSize() int {
  return 32
}

// EncodeTo encodes this value using the Encoder.
func (s *Hash) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeFixedOpaque(s[:]); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*Hash)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Hash) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Hash: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  nTmp, err = d.DecodeFixedOpaqueInplace(s[:])
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Hash: %w", err)
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Hash) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Hash) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Hash)(nil)
  _ encoding.BinaryUnmarshaler = (*Hash)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Hash) xdrType() {}

var _ xdrType = (*Hash)(nil)

// Hashes1 is an XDR Typedef defines as:
//
//   typedef Hash Hashes1[12];
//
type Hashes1 [12]Hash
// EncodeTo encodes this value using the Encoder.
func (s *Hashes1) EncodeTo(e *xdr.Encoder) error {
  var err error
  for i := 0; i < len(s); i++ {
  if err = s[i].EncodeTo(e); err != nil {
    return err
  }
  }
  return nil
}

var _ decoderFrom = (*Hashes1)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Hashes1) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Hashes1: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  for i := 0; i < len(s); i++ {
      nTmp, err = s[i].DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Hash: %w", err)
  }
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Hashes1) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Hashes1) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Hashes1)(nil)
  _ encoding.BinaryUnmarshaler = (*Hashes1)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Hashes1) xdrType() {}

var _ xdrType = (*Hashes1)(nil)

// Hashes2 is an XDR Typedef defines as:
//
//   typedef Hash Hashes2<12>;
//
type Hashes2 []Hash
// XDRMaxSize implements the Sized interface for Hashes2
func (e Hashes2) XDRMaxSize() int {
  return 12
}
// EncodeTo encodes this value using the Encoder.
func (s Hashes2) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeUint(uint32(len(s))); err != nil {
    return err
  }
  for i := 0; i < len(s); i++ {
  if err = s[i].EncodeTo(e); err != nil {
    return err
  }
  }
  return nil
}

var _ decoderFrom = (*Hashes2)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Hashes2) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Hashes2: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  var l uint32
  l, nTmp, err = d.DecodeUint()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Hash: %w", err)
  }
  if l > 12 {
    return n, fmt.Errorf("decoding Hash: data size (%d) exceeds size limit (12)", l)
  }
  (*s) = nil
  if l > 0 {
    if il, ok := d.InputLen(); ok && uint(il) < uint(l) {
        return n, fmt.Errorf("decoding Hash: length (%d) exceeds remaining input length (%d)", l, il)
    }
    (*s) = make([]Hash, l)
    for i := uint32(0); i < l; i++ {
      nTmp, err = (*s)[i].DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Hash: %w", err)
  }
    }
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Hashes2) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Hashes2) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Hashes2)(nil)
  _ encoding.BinaryUnmarshaler = (*Hashes2)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Hashes2) xdrType() {}

var _ xdrType = (*Hashes2)(nil)

// Hashes3 is an XDR Typedef defines as:
//
//   typedef Hash Hashes3<>;
//
type Hashes3 []Hash
// EncodeTo encodes this value using the Encoder.
func (s Hashes3) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeUint(uint32(len(s))); err != nil {
    return err
  }
  for i := 0; i < len(s); i++ {
  if err = s[i].EncodeTo(e); err != nil {
    return err
  }
  }
  return nil
}

var _ decoderFrom = (*Hashes3)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Hashes3) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Hashes3: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  var l uint32
  l, nTmp, err = d.DecodeUint()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Hash: %w", err)
  }
  (*s) = nil
  if l > 0 {
    if il, ok := d.InputLen(); ok && uint(il) < uint(l) {
        return n, fmt.Errorf("decoding Hash: length (%d) exceeds remaining input length (%d)", l, il)
    }
    (*s) = make([]Hash, l)
    for i := uint32(0); i < l; i++ {
      nTmp, err = (*s)[i].DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Hash: %w", err)
  }
    }
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Hashes3) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Hashes3) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Hashes3)(nil)
  _ encoding.BinaryUnmarshaler = (*Hashes3)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Hashes3) xdrType() {}

var _ xdrType = (*Hashes3)(nil)

// OptHash1 is an XDR Typedef defines as:
//
//   typedef Hash *optHash1;
//
type OptHash1 = *Hash
// OptHash2 is an XDR Typedef defines as:
//
//   typedef Hash* optHash2;
//
type OptHash2 = *Hash
// Int1 is an XDR Typedef defines as:
//
//   typedef int             int1;
//
type Int1 int32

// EncodeTo encodes this value using the Encoder.
func (s Int1) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeInt(int32(s)); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*Int1)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Int1) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Int1: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  var v int32
  v, nTmp, err = d.DecodeInt()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
  *s = Int1(v)
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Int1) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Int1) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Int1)(nil)
  _ encoding.BinaryUnmarshaler = (*Int1)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Int1) xdrType() {}

var _ xdrType = (*Int1)(nil)

// Int2 is an XDR Typedef defines as:
//
//   typedef hyper           int2;
//
type Int2 int64

// EncodeTo encodes this value using the Encoder.
func (s Int2) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeHyper(int64(s)); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*Int2)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Int2) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Int2: %w", ErrMaxDecodingDepthReached)
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
  *s = Int2(v)
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Int2) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Int2) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Int2)(nil)
  _ encoding.BinaryUnmarshaler = (*Int2)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Int2) xdrType() {}

var _ xdrType = (*Int2)(nil)

// Int3 is an XDR Typedef defines as:
//
//   typedef unsigned int    int3;
//
type Int3 uint32

// EncodeTo encodes this value using the Encoder.
func (s Int3) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeUint(uint32(s)); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*Int3)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Int3) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Int3: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  var v uint32
  v, nTmp, err = d.DecodeUint()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Unsigned int: %w", err)
  }
  *s = Int3(v)
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Int3) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Int3) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Int3)(nil)
  _ encoding.BinaryUnmarshaler = (*Int3)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Int3) xdrType() {}

var _ xdrType = (*Int3)(nil)

// Int4 is an XDR Typedef defines as:
//
//   typedef unsigned hyper  int4;
//
type Int4 uint64

// EncodeTo encodes this value using the Encoder.
func (s Int4) EncodeTo(e *xdr.Encoder) error {
  var err error
  if   _, err = e.EncodeUhyper(uint64(s)); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*Int4)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Int4) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Int4: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  var v uint64
  v, nTmp, err = d.DecodeUhyper()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Unsigned hyper: %w", err)
  }
  *s = Int4(v)
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Int4) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Int4) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Int4)(nil)
  _ encoding.BinaryUnmarshaler = (*Int4)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Int4) xdrType() {}

var _ xdrType = (*Int4)(nil)

// MyStruct is an XDR Struct defines as:
//
//   struct MyStruct
//    {
//        uint512 field1;
//        optHash1 field2;
//        int1 field3;
//        unsigned int field4;
//        float field5;
//        double field6;
//        bool field7;
//    };
//
type MyStruct struct {
  Field1 Uint512 
  Field2 OptHash1 
  Field3 Int1 
  Field4 uint32 
  Field5 float32 
  Field6 float64 
  Field7 bool 
}

// EncodeTo encodes this value using the Encoder.
func (s *MyStruct) EncodeTo(e *xdr.Encoder) error {
  var err error
  if   err = s.Field1.EncodeTo(e); err != nil {
    return err
  }
  if _, err = e.EncodeBool(s.Field2 != nil); err != nil {
    return err
  }
  if s.Field2 != nil {
  if   err = (*s.Field2).EncodeTo(e); err != nil {
    return err
  }
  }
  if   err = s.Field3.EncodeTo(e); err != nil {
    return err
  }
  if _, err = e.EncodeUint(uint32(s.Field4)); err != nil {
    return err
  }
  if _, err = e.Encode(s.Field5); err != nil {
    return err
  }
  if _, err = e.Encode(s.Field6); err != nil {
    return err
  }
  if _, err = e.EncodeBool(bool(s.Field7)); err != nil {
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
  nTmp, err = s.Field1.DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Uint512: %w", err)
  }
  var b bool
  b, nTmp, err = d.DecodeBool()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding OptHash1: %w", err)
  }
  s.Field2 = nil
  if b {
     s.Field2 = new(Hash)
  nTmp, err = s.Field2.DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding OptHash1: %w", err)
  }
  }
  nTmp, err = s.Field3.DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int1: %w", err)
  }
  s.Field4, nTmp, err = d.DecodeUint()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Unsigned int: %w", err)
  }
  nTmp, err = d.DecodeWithMaxDepth(&s.Field5, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Float: %w", err)
  }
  nTmp, err = d.DecodeWithMaxDepth(&s.Field6, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Double: %w", err)
  }
  s.Field7, nTmp, err = d.DecodeBool()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Bool: %w", err)
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

// LotsOfMyStructs is an XDR Struct defines as:
//
//   struct LotsOfMyStructs
//    {
//        MyStruct members<>;
//    };
//
type LotsOfMyStructs struct {
  Members []MyStruct 
}

// EncodeTo encodes this value using the Encoder.
func (s *LotsOfMyStructs) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeUint(uint32(len(s.Members))); err != nil {
    return err
  }
  for i := 0; i < len(s.Members); i++ {
  if err = s.Members[i].EncodeTo(e); err != nil {
    return err
  }
  }
  return nil
}

var _ decoderFrom = (*LotsOfMyStructs)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *LotsOfMyStructs) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding LotsOfMyStructs: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  var l uint32
  l, nTmp, err = d.DecodeUint()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding MyStruct: %w", err)
  }
  s.Members = nil
  if l > 0 {
    if il, ok := d.InputLen(); ok && uint(il) < uint(l) {
        return n, fmt.Errorf("decoding MyStruct: length (%d) exceeds remaining input length (%d)", l, il)
    }
    s.Members = make([]MyStruct, l)
    for i := uint32(0); i < l; i++ {
      nTmp, err = s.Members[i].DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding MyStruct: %w", err)
  }
    }
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s LotsOfMyStructs) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *LotsOfMyStructs) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*LotsOfMyStructs)(nil)
  _ encoding.BinaryUnmarshaler = (*LotsOfMyStructs)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s LotsOfMyStructs) xdrType() {}

var _ xdrType = (*LotsOfMyStructs)(nil)

// HasStuff is an XDR Struct defines as:
//
//   struct HasStuff
//    {
//      LotsOfMyStructs data;
//    };
//
type HasStuff struct {
  Data LotsOfMyStructs 
}

// EncodeTo encodes this value using the Encoder.
func (s *HasStuff) EncodeTo(e *xdr.Encoder) error {
  var err error
  if   err = s.Data.EncodeTo(e); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*HasStuff)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *HasStuff) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding HasStuff: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  nTmp, err = s.Data.DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding LotsOfMyStructs: %w", err)
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s HasStuff) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *HasStuff) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*HasStuff)(nil)
  _ encoding.BinaryUnmarshaler = (*HasStuff)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s HasStuff) xdrType() {}

var _ xdrType = (*HasStuff)(nil)

// Color is an XDR Enum defines as:
//
//   enum Color {
//      RED,
//      BLUE = 5,
//      GREEN
//    };
//
type Color int32
const (
  ColorRed Color = 0
  ColorBlue Color = 5
  ColorGreen Color = 6
)
var colorMap = map[int32]string{
  0: "ColorRed",
  5: "ColorBlue",
  6: "ColorGreen",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for Color
func (e Color) ValidEnum(v int32) bool {
  _, ok := colorMap[v]
  return ok
}
// String returns the name of `e`
func (e Color) String() string {
  name, _ := colorMap[int32(e)]
  return name
}

// EncodeTo encodes this value using the Encoder.
func (e Color) EncodeTo(enc *xdr.Encoder) error {
  if _, ok := colorMap[int32(e)]; !ok {
    return fmt.Errorf("'%d' is not a valid Color enum value", e)
  }
  _, err := enc.EncodeInt(int32(e))
  return err
}
var _ decoderFrom = (*Color)(nil)
// DecodeFrom decodes this value using the Decoder.
func (e *Color) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Color: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  v, n, err := d.DecodeInt()
  if err != nil {
    return n, fmt.Errorf("decoding Color: %w", err)
  }
  if _, ok := colorMap[v]; !ok {
    return n, fmt.Errorf("'%d' is not a valid Color enum value", v)
  }
  *e = Color(v)
  return n, nil
}
// MarshalBinary implements encoding.BinaryMarshaler.
func (s Color) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Color) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Color)(nil)
  _ encoding.BinaryUnmarshaler = (*Color)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Color) xdrType() {}

var _ xdrType = (*Color)(nil)

// Foo is an XDR Const defines as:
//
//   const FOO = 1244;
//
const Foo = 1244

// Bar is an XDR Const defines as:
//
//   const BAR = FOO;
//
const Bar = FOO

// NesterNestedEnum is an XDR NestedEnum defines as:
//
//   enum {
//        BLAH_1,
//        BLAH_2
//      }
//
type NesterNestedEnum int32
const (
  NesterNestedEnumBlah1 NesterNestedEnum = 0
  NesterNestedEnumBlah2 NesterNestedEnum = 1
)
var nestedEnumMap = map[int32]string{
  0: "NesterNestedEnumBlah1",
  1: "NesterNestedEnumBlah2",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for NesterNestedEnum
func (e NesterNestedEnum) ValidEnum(v int32) bool {
  _, ok := nestedEnumMap[v]
  return ok
}
// String returns the name of `e`
func (e NesterNestedEnum) String() string {
  name, _ := nestedEnumMap[int32(e)]
  return name
}

// EncodeTo encodes this value using the Encoder.
func (e NesterNestedEnum) EncodeTo(enc *xdr.Encoder) error {
  if _, ok := nestedEnumMap[int32(e)]; !ok {
    return fmt.Errorf("'%d' is not a valid NesterNestedEnum enum value", e)
  }
  _, err := enc.EncodeInt(int32(e))
  return err
}
var _ decoderFrom = (*NesterNestedEnum)(nil)
// DecodeFrom decodes this value using the Decoder.
func (e *NesterNestedEnum) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding NesterNestedEnum: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  v, n, err := d.DecodeInt()
  if err != nil {
    return n, fmt.Errorf("decoding NesterNestedEnum: %w", err)
  }
  if _, ok := nestedEnumMap[v]; !ok {
    return n, fmt.Errorf("'%d' is not a valid NesterNestedEnum enum value", v)
  }
  *e = NesterNestedEnum(v)
  return n, nil
}
// MarshalBinary implements encoding.BinaryMarshaler.
func (s NesterNestedEnum) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *NesterNestedEnum) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*NesterNestedEnum)(nil)
  _ encoding.BinaryUnmarshaler = (*NesterNestedEnum)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s NesterNestedEnum) xdrType() {}

var _ xdrType = (*NesterNestedEnum)(nil)

// NesterNestedStruct is an XDR NestedStruct defines as:
//
//   struct {
//        int blah;
//      }
//
type NesterNestedStruct struct {
  Blah int32 
}

// EncodeTo encodes this value using the Encoder.
func (s *NesterNestedStruct) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeInt(int32(s.Blah)); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*NesterNestedStruct)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *NesterNestedStruct) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding NesterNestedStruct: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  s.Blah, nTmp, err = d.DecodeInt()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s NesterNestedStruct) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *NesterNestedStruct) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*NesterNestedStruct)(nil)
  _ encoding.BinaryUnmarshaler = (*NesterNestedStruct)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s NesterNestedStruct) xdrType() {}

var _ xdrType = (*NesterNestedStruct)(nil)

// NesterNestedUnion is an XDR NestedUnion defines as:
//
//   union switch (Color color) {
//        case RED:
//          void;
//        default:
//          int blah2;
//      }
//
type NesterNestedUnion struct{
  Color Color
  Blah2 *int32 
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u NesterNestedUnion) SwitchFieldName() string {
  return "Color"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of NesterNestedUnion
func (u NesterNestedUnion) ArmForSwitch(sw int32) (string, bool) {
switch Color(sw) {
    case ColorRed:
      return "", true
    default:
      return "Blah2", true
}
}

// NewNesterNestedUnion creates a new  NesterNestedUnion.
func NewNesterNestedUnion(color Color, value interface{}) (result NesterNestedUnion, err error) {
  result.Color = color
switch Color(color) {
    case ColorRed:
      // void
    default:
                  tv, ok := value.(int32)
            if !ok {
              err = errors.New("invalid value, must be int32")
              return
            }
            result.Blah2 = &tv
}
  return
}
// MustBlah2 retrieves the Blah2 value from the union,
// panicing if the value is not set.
func (u NesterNestedUnion) MustBlah2() int32 {
  val, ok := u.GetBlah2()

  if !ok {
    panic("arm Blah2 is not set")
  }

  return val
}

// GetBlah2 retrieves the Blah2 value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u NesterNestedUnion) GetBlah2() (result int32, ok bool) {
  armName, _ := u.ArmForSwitch(int32(u.Color))

  if armName == "Blah2" {
    result = *u.Blah2
    ok = true
  }

  return
}

// EncodeTo encodes this value using the Encoder.
func (u NesterNestedUnion) EncodeTo(e *xdr.Encoder) error {
  var err error
  if   err = u.Color.EncodeTo(e); err != nil {
    return err
  }
switch Color(u.Color) {
    case ColorRed:
      // Void
return nil
    default:
        if _, err = e.EncodeInt(int32((*u.Blah2))); err != nil {
    return err
  }
return nil
}
}

var _ decoderFrom = (*NesterNestedUnion)(nil)
// DecodeFrom decodes this value using the Decoder.
func (u *NesterNestedUnion) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding NesterNestedUnion: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  nTmp, err = u.Color.DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Color: %w", err)
  }
switch Color(u.Color) {
    case ColorRed:
      // Void
  return n, nil
    default:
        u.Blah2 = new(int32)
  (*u.Blah2), nTmp, err = d.DecodeInt()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
  return n, nil
}
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s NesterNestedUnion) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *NesterNestedUnion) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*NesterNestedUnion)(nil)
  _ encoding.BinaryUnmarshaler = (*NesterNestedUnion)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s NesterNestedUnion) xdrType() {}

var _ xdrType = (*NesterNestedUnion)(nil)

// Nester is an XDR Struct defines as:
//
//   struct Nester
//    {
//      enum {
//        BLAH_1,
//        BLAH_2
//      } nestedEnum;
//    
//      struct {
//        int blah;
//      } nestedStruct;
//    
//      union switch (Color color) {
//        case RED:
//          void;
//        default:
//          int blah2;
//      } nestedUnion;
//    
//    
//    };
//
type Nester struct {
  NestedEnum NesterNestedEnum 
  NestedStruct NesterNestedStruct 
  NestedUnion NesterNestedUnion 
}

// EncodeTo encodes this value using the Encoder.
func (s *Nester) EncodeTo(e *xdr.Encoder) error {
  var err error
  if err = s.NestedEnum.EncodeTo(e); err != nil {
    return err
  }
  if err = s.NestedStruct.EncodeTo(e); err != nil {
    return err
  }
  if err = s.NestedUnion.EncodeTo(e); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*Nester)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Nester) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Nester: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  nTmp, err = s.NestedEnum.DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding NesterNestedEnum: %w", err)
  }
  nTmp, err = s.NestedStruct.DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding NesterNestedStruct: %w", err)
  }
  nTmp, err = s.NestedUnion.DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding NesterNestedUnion: %w", err)
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Nester) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Nester) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Nester)(nil)
  _ encoding.BinaryUnmarshaler = (*Nester)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Nester) xdrType() {}

var _ xdrType = (*Nester)(nil)

var fmtTest = fmt.Sprint("this is a dummy usage of fmt")
