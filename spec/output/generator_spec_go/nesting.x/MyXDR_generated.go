//lint:file-ignore S1005 The issue should be fixed in xdrgen. Unfortunately, there's no way to ignore a single file in staticcheck.
//lint:file-ignore U1000 fmtTest is not needed anywhere, should be removed in xdrgen.

// Package MyXDR is generated from:
//
//  spec/fixtures/generator/nesting.x
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
  "spec/fixtures/generator/nesting.x": "5537949272c11f1bd09cf613a3751668b5018d686a1c2aaa3baa91183ca18f6a",
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

// UnionKey is an XDR Enum defines as:
//
//   enum UnionKey {
//      ONE = 1,
//      TWO = 2,
//      OFFER = 3
//    };
//
type UnionKey int32
const (
  UnionKeyOne UnionKey = 1
  UnionKeyTwo UnionKey = 2
  UnionKeyOffer UnionKey = 3
)
var unionKeyMap = map[int32]string{
  1: "UnionKeyOne",
  2: "UnionKeyTwo",
  3: "UnionKeyOffer",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for UnionKey
func (e UnionKey) ValidEnum(v int32) bool {
  _, ok := unionKeyMap[v]
  return ok
}
// String returns the name of `e`
func (e UnionKey) String() string {
  name, _ := unionKeyMap[int32(e)]
  return name
}

// EncodeTo encodes this value using the Encoder.
func (e UnionKey) EncodeTo(enc *xdr.Encoder) error {
  if _, ok := unionKeyMap[int32(e)]; !ok {
    return fmt.Errorf("'%d' is not a valid UnionKey enum value", e)
  }
  _, err := enc.EncodeInt(int32(e))
  return err
}
var _ decoderFrom = (*UnionKey)(nil)
// DecodeFrom decodes this value using the Decoder.
func (e *UnionKey) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding UnionKey: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  v, n, err := d.DecodeInt()
  if err != nil {
    return n, fmt.Errorf("decoding UnionKey: %w", err)
  }
  if _, ok := unionKeyMap[v]; !ok {
    return n, fmt.Errorf("'%d' is not a valid UnionKey enum value", v)
  }
  *e = UnionKey(v)
  return n, nil
}
// MarshalBinary implements encoding.BinaryMarshaler.
func (s UnionKey) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *UnionKey) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*UnionKey)(nil)
  _ encoding.BinaryUnmarshaler = (*UnionKey)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s UnionKey) xdrType() {}

var _ xdrType = (*UnionKey)(nil)

// Foo is an XDR Typedef defines as:
//
//   typedef int Foo;
//
type Foo int32

// EncodeTo encodes this value using the Encoder.
func (s Foo) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeInt(int32(s)); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*Foo)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Foo) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Foo: %w", ErrMaxDecodingDepthReached)
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
  *s = Foo(v)
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Foo) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Foo) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Foo)(nil)
  _ encoding.BinaryUnmarshaler = (*Foo)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Foo) xdrType() {}

var _ xdrType = (*Foo)(nil)

// MyUnionOne is an XDR NestedStruct defines as:
//
//   struct {
//                int someInt;
//            }
//
type MyUnionOne struct {
  SomeInt int32 
}

// EncodeTo encodes this value using the Encoder.
func (s *MyUnionOne) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeInt(int32(s.SomeInt)); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*MyUnionOne)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *MyUnionOne) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding MyUnionOne: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  s.SomeInt, nTmp, err = d.DecodeInt()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s MyUnionOne) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *MyUnionOne) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*MyUnionOne)(nil)
  _ encoding.BinaryUnmarshaler = (*MyUnionOne)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s MyUnionOne) xdrType() {}

var _ xdrType = (*MyUnionOne)(nil)

// MyUnionTwo is an XDR NestedStruct defines as:
//
//   struct {
//                int someInt;
//                Foo foo;
//            }
//
type MyUnionTwo struct {
  SomeInt int32 
  Foo Foo 
}

// EncodeTo encodes this value using the Encoder.
func (s *MyUnionTwo) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeInt(int32(s.SomeInt)); err != nil {
    return err
  }
  if   err = s.Foo.EncodeTo(e); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*MyUnionTwo)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *MyUnionTwo) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding MyUnionTwo: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  s.SomeInt, nTmp, err = d.DecodeInt()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
  nTmp, err = s.Foo.DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Foo: %w", err)
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s MyUnionTwo) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *MyUnionTwo) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*MyUnionTwo)(nil)
  _ encoding.BinaryUnmarshaler = (*MyUnionTwo)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s MyUnionTwo) xdrType() {}

var _ xdrType = (*MyUnionTwo)(nil)

// MyUnion is an XDR Union defines as:
//
//   union MyUnion switch (UnionKey type)
//    {
//        case ONE:
//            struct {
//                int someInt;
//            } one;
//    
//        case TWO:
//            struct {
//                int someInt;
//                Foo foo;
//            } two;
//    
//        case OFFER:
//            void;
//    };
//
type MyUnion struct{
  Type UnionKey
  One *MyUnionOne 
  Two *MyUnionTwo 
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u MyUnion) SwitchFieldName() string {
  return "Type"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of MyUnion
func (u MyUnion) ArmForSwitch(sw int32) (string, bool) {
switch UnionKey(sw) {
    case UnionKeyOne:
      return "One", true
    case UnionKeyTwo:
      return "Two", true
    case UnionKeyOffer:
      return "", true
}
return "-", false
}

// NewMyUnion creates a new  MyUnion.
func NewMyUnion(aType UnionKey, value interface{}) (result MyUnion, err error) {
  result.Type = aType
switch UnionKey(aType) {
    case UnionKeyOne:
                  tv, ok := value.(MyUnionOne)
            if !ok {
              err = errors.New("invalid value, must be MyUnionOne")
              return
            }
            result.One = &tv
    case UnionKeyTwo:
                  tv, ok := value.(MyUnionTwo)
            if !ok {
              err = errors.New("invalid value, must be MyUnionTwo")
              return
            }
            result.Two = &tv
    case UnionKeyOffer:
      // void
}
  return
}
// MustOne retrieves the One value from the union,
// panicing if the value is not set.
func (u MyUnion) MustOne() MyUnionOne {
  val, ok := u.GetOne()

  if !ok {
    panic("arm One is not set")
  }

  return val
}

// GetOne retrieves the One value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u MyUnion) GetOne() (result MyUnionOne, ok bool) {
  armName, _ := u.ArmForSwitch(int32(u.Type))

  if armName == "One" {
    result = *u.One
    ok = true
  }

  return
}
// MustTwo retrieves the Two value from the union,
// panicing if the value is not set.
func (u MyUnion) MustTwo() MyUnionTwo {
  val, ok := u.GetTwo()

  if !ok {
    panic("arm Two is not set")
  }

  return val
}

// GetTwo retrieves the Two value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u MyUnion) GetTwo() (result MyUnionTwo, ok bool) {
  armName, _ := u.ArmForSwitch(int32(u.Type))

  if armName == "Two" {
    result = *u.Two
    ok = true
  }

  return
}

// EncodeTo encodes this value using the Encoder.
func (u MyUnion) EncodeTo(e *xdr.Encoder) error {
  var err error
  if   err = u.Type.EncodeTo(e); err != nil {
    return err
  }
switch UnionKey(u.Type) {
    case UnionKeyOne:
        if err = (*u.One).EncodeTo(e); err != nil {
    return err
  }
return nil
    case UnionKeyTwo:
        if err = (*u.Two).EncodeTo(e); err != nil {
    return err
  }
return nil
    case UnionKeyOffer:
      // Void
return nil
}
  return fmt.Errorf("Type (UnionKey) switch value '%d' is not valid for union MyUnion", u.Type)
}

var _ decoderFrom = (*MyUnion)(nil)
// DecodeFrom decodes this value using the Decoder.
func (u *MyUnion) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding MyUnion: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  nTmp, err = u.Type.DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding UnionKey: %w", err)
  }
switch UnionKey(u.Type) {
    case UnionKeyOne:
        u.One = new(MyUnionOne)
  nTmp, err = (*u.One).DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding MyUnionOne: %w", err)
  }
  return n, nil
    case UnionKeyTwo:
        u.Two = new(MyUnionTwo)
  nTmp, err = (*u.Two).DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding MyUnionTwo: %w", err)
  }
  return n, nil
    case UnionKeyOffer:
      // Void
  return n, nil
}
  return n, fmt.Errorf("union MyUnion has invalid Type (UnionKey) switch value '%d'", u.Type)
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s MyUnion) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *MyUnion) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*MyUnion)(nil)
  _ encoding.BinaryUnmarshaler = (*MyUnion)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s MyUnion) xdrType() {}

var _ xdrType = (*MyUnion)(nil)

var fmtTest = fmt.Sprint("this is a dummy usage of fmt")
