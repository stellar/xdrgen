//lint:file-ignore S1005 The issue should be fixed in xdrgen. Unfortunately, there's no way to ignore a single file in staticcheck.
//lint:file-ignore U1000 fmtTest is not needed anywhere, should be removed in xdrgen.

// Package MyXDR is generated from:
//
//  spec/fixtures/generator/union.x
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
  "spec/fixtures/generator/union.x": "c251258d967223b341ebcf2d5bb0718e9a039b46232cb743865d9acd0c4bbe41",
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

// Error is an XDR Typedef defines as:
//
//   typedef int Error;
//
type Error int32

// EncodeTo encodes this value using the Encoder.
func (s Error) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeInt(int32(s)); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*Error)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Error) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Error: %w", ErrMaxDecodingDepthReached)
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
  *s = Error(v)
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Error) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Error) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Error)(nil)
  _ encoding.BinaryUnmarshaler = (*Error)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Error) xdrType() {}

var _ xdrType = (*Error)(nil)

// Multi is an XDR Typedef defines as:
//
//   typedef int Multi;
//
type Multi int32

// EncodeTo encodes this value using the Encoder.
func (s Multi) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeInt(int32(s)); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*Multi)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *Multi) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding Multi: %w", ErrMaxDecodingDepthReached)
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
  *s = Multi(v)
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s Multi) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Multi) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Multi)(nil)
  _ encoding.BinaryUnmarshaler = (*Multi)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s Multi) xdrType() {}

var _ xdrType = (*Multi)(nil)

// UnionKey is an XDR Enum defines as:
//
//   enum UnionKey {
//      ERROR,
//      MULTI
//    };
//
type UnionKey int32
const (
  UnionKeyError UnionKey = 0
  UnionKeyMulti UnionKey = 1
)
var unionKeyMap = map[int32]string{
  0: "UnionKeyError",
  1: "UnionKeyMulti",
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

// MyUnion is an XDR Union defines as:
//
//   union MyUnion switch (UnionKey type)
//    {
//        case ERROR:
//            Error error;
//        case MULTI:
//            Multi things<>;
//    
//    
//    };
//
type MyUnion struct{
  Type UnionKey
  Error *Error 
  Things *[]Multi 
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
    case UnionKeyError:
      return "Error", true
    case UnionKeyMulti:
      return "Things", true
}
return "-", false
}

// NewMyUnion creates a new  MyUnion.
func NewMyUnion(aType UnionKey, value interface{}) (result MyUnion, err error) {
  result.Type = aType
switch UnionKey(aType) {
    case UnionKeyError:
                  tv, ok := value.(Error)
            if !ok {
              err = errors.New("invalid value, must be Error")
              return
            }
            result.Error = &tv
    case UnionKeyMulti:
                  tv, ok := value.([]Multi)
            if !ok {
              err = errors.New("invalid value, must be []Multi")
              return
            }
            result.Things = &tv
}
  return
}
// MustError retrieves the Error value from the union,
// panicing if the value is not set.
func (u MyUnion) MustError() Error {
  val, ok := u.GetError()

  if !ok {
    panic("arm Error is not set")
  }

  return val
}

// GetError retrieves the Error value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u MyUnion) GetError() (result Error, ok bool) {
  armName, _ := u.ArmForSwitch(int32(u.Type))

  if armName == "Error" {
    result = *u.Error
    ok = true
  }

  return
}
// MustThings retrieves the Things value from the union,
// panicing if the value is not set.
func (u MyUnion) MustThings() []Multi {
  val, ok := u.GetThings()

  if !ok {
    panic("arm Things is not set")
  }

  return val
}

// GetThings retrieves the Things value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u MyUnion) GetThings() (result []Multi, ok bool) {
  armName, _ := u.ArmForSwitch(int32(u.Type))

  if armName == "Things" {
    result = *u.Things
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
    case UnionKeyError:
        if   err = (*u.Error).EncodeTo(e); err != nil {
    return err
  }
return nil
    case UnionKeyMulti:
        if _, err = e.EncodeUint(uint32(len((*u.Things)))); err != nil {
    return err
  }
  for i := 0; i < len((*u.Things)); i++ {
  if err = (*u.Things)[i].EncodeTo(e); err != nil {
    return err
  }
  }
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
    case UnionKeyError:
        u.Error = new(Error)
  nTmp, err = (*u.Error).DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Error: %w", err)
  }
  return n, nil
    case UnionKeyMulti:
        u.Things = new([]Multi)
  var l uint32
  l, nTmp, err = d.DecodeUint()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Multi: %w", err)
  }
  (*u.Things) = nil
  if l > 0 {
    if il, ok := d.InputLen(); ok && uint(il) < uint(l) {
        return n, fmt.Errorf("decoding Multi: length (%d) exceeds remaining input length (%d)", l, il)
    }
    (*u.Things) = make([]Multi, l)
    for i := uint32(0); i < l; i++ {
      nTmp, err = (*u.Things)[i].DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Multi: %w", err)
  }
    }
  }
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

// IntUnion is an XDR Union defines as:
//
//   union IntUnion switch (int type)
//    {
//        case 0:
//            Error error;
//        case 1:
//            Multi things<>;
//    
//    };
//
type IntUnion struct{
  Type int32
  Error *Error 
  Things *[]Multi 
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u IntUnion) SwitchFieldName() string {
  return "Type"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of IntUnion
func (u IntUnion) ArmForSwitch(sw int32) (string, bool) {
switch int32(sw) {
    case 0:
      return "Error", true
    case 1:
      return "Things", true
}
return "-", false
}

// NewIntUnion creates a new  IntUnion.
func NewIntUnion(aType int32, value interface{}) (result IntUnion, err error) {
  result.Type = aType
switch int32(aType) {
    case 0:
                  tv, ok := value.(Error)
            if !ok {
              err = errors.New("invalid value, must be Error")
              return
            }
            result.Error = &tv
    case 1:
                  tv, ok := value.([]Multi)
            if !ok {
              err = errors.New("invalid value, must be []Multi")
              return
            }
            result.Things = &tv
}
  return
}
// MustError retrieves the Error value from the union,
// panicing if the value is not set.
func (u IntUnion) MustError() Error {
  val, ok := u.GetError()

  if !ok {
    panic("arm Error is not set")
  }

  return val
}

// GetError retrieves the Error value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u IntUnion) GetError() (result Error, ok bool) {
  armName, _ := u.ArmForSwitch(int32(u.Type))

  if armName == "Error" {
    result = *u.Error
    ok = true
  }

  return
}
// MustThings retrieves the Things value from the union,
// panicing if the value is not set.
func (u IntUnion) MustThings() []Multi {
  val, ok := u.GetThings()

  if !ok {
    panic("arm Things is not set")
  }

  return val
}

// GetThings retrieves the Things value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u IntUnion) GetThings() (result []Multi, ok bool) {
  armName, _ := u.ArmForSwitch(int32(u.Type))

  if armName == "Things" {
    result = *u.Things
    ok = true
  }

  return
}

// EncodeTo encodes this value using the Encoder.
func (u IntUnion) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeInt(int32(u.Type)); err != nil {
    return err
  }
switch int32(u.Type) {
    case 0:
        if   err = (*u.Error).EncodeTo(e); err != nil {
    return err
  }
return nil
    case 1:
        if _, err = e.EncodeUint(uint32(len((*u.Things)))); err != nil {
    return err
  }
  for i := 0; i < len((*u.Things)); i++ {
  if err = (*u.Things)[i].EncodeTo(e); err != nil {
    return err
  }
  }
return nil
}
  return fmt.Errorf("Type (int32) switch value '%d' is not valid for union IntUnion", u.Type)
}

var _ decoderFrom = (*IntUnion)(nil)
// DecodeFrom decodes this value using the Decoder.
func (u *IntUnion) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding IntUnion: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  u.Type, nTmp, err = d.DecodeInt()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
switch int32(u.Type) {
    case 0:
        u.Error = new(Error)
  nTmp, err = (*u.Error).DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Error: %w", err)
  }
  return n, nil
    case 1:
        u.Things = new([]Multi)
  var l uint32
  l, nTmp, err = d.DecodeUint()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Multi: %w", err)
  }
  (*u.Things) = nil
  if l > 0 {
    if il, ok := d.InputLen(); ok && uint(il) < uint(l) {
        return n, fmt.Errorf("decoding Multi: length (%d) exceeds remaining input length (%d)", l, il)
    }
    (*u.Things) = make([]Multi, l)
    for i := uint32(0); i < l; i++ {
      nTmp, err = (*u.Things)[i].DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Multi: %w", err)
  }
    }
  }
  return n, nil
}
  return n, fmt.Errorf("union IntUnion has invalid Type (int32) switch value '%d'", u.Type)
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s IntUnion) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *IntUnion) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*IntUnion)(nil)
  _ encoding.BinaryUnmarshaler = (*IntUnion)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s IntUnion) xdrType() {}

var _ xdrType = (*IntUnion)(nil)

// IntUnion2 is an XDR Typedef defines as:
//
//   typedef IntUnion IntUnion2;
//
type IntUnion2 IntUnion
// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u IntUnion2) SwitchFieldName() string {
  return IntUnion(u).SwitchFieldName()
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of IntUnion
func (u IntUnion2) ArmForSwitch(sw int32) (string, bool) {
  return IntUnion(u).ArmForSwitch(sw)
}

// NewIntUnion2 creates a new  IntUnion2.
func NewIntUnion2(aType int32, value interface{}) (result IntUnion2, err error) {
  u, err := NewIntUnion(aType, value)
  result = IntUnion2(u)
  return
}

// MustError retrieves the Error value from the union,
// panicing if the value is not set.
func (u IntUnion2) MustError() Error {
  return IntUnion(u).MustError()
}

// GetError retrieves the Error value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u IntUnion2) GetError() (result Error, ok bool) {
  return IntUnion(u).GetError()
}
// MustThings retrieves the Things value from the union,
// panicing if the value is not set.
func (u IntUnion2) MustThings() []Multi {
  return IntUnion(u).MustThings()
}

// GetThings retrieves the Things value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u IntUnion2) GetThings() (result []Multi, ok bool) {
  return IntUnion(u).GetThings()
}

// EncodeTo encodes this value using the Encoder.
func (s IntUnion2) EncodeTo(e *xdr.Encoder) error {
  var err error
  if   err = IntUnion(s).EncodeTo(e); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*IntUnion2)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *IntUnion2) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding IntUnion2: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  nTmp, err = (*IntUnion)(s).DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding IntUnion: %w", err)
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s IntUnion2) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *IntUnion2) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*IntUnion2)(nil)
  _ encoding.BinaryUnmarshaler = (*IntUnion2)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s IntUnion2) xdrType() {}

var _ xdrType = (*IntUnion2)(nil)

var fmtTest = fmt.Sprint("this is a dummy usage of fmt")
