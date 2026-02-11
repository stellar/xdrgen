//go:build feature_a

//lint:file-ignore S1005 The issue should be fixed in xdrgen. Unfortunately, there's no way to ignore a single file in staticcheck.

// DO NOT EDIT or your changes may be overwritten
package MyXDR

import (
  "bytes"
  "encoding"
  "errors"
  "fmt"

  "github.com/stellar/go-xdr/xdr3"
)

// MyEnum is an XDR Enum defines as:
//
//   enum MyEnum {
//        MEMBER_A = 0,
//        MEMBER_B = 1,
//                    
//        MEMBER_C = 2,
//          
//        MEMBER_D = 3
//    };
//
type MyEnum int32
const (
  MyEnumMemberA MyEnum = 0
  MyEnumMemberB MyEnum = 1
  MyEnumMemberC MyEnum = 2
  MyEnumMemberD MyEnum = 3
)
var myEnumMap = map[int32]string{
  0: "MyEnumMemberA",
  1: "MyEnumMemberB",
  2: "MyEnumMemberC",
  3: "MyEnumMemberD",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for MyEnum
func (e MyEnum) ValidEnum(v int32) bool {
  _, ok := myEnumMap[v]
  return ok
}
// String returns the name of `e`
func (e MyEnum) String() string {
  name, _ := myEnumMap[int32(e)]
  return name
}

// EncodeTo encodes this value using the Encoder.
func (e MyEnum) EncodeTo(enc *xdr.Encoder) error {
  if _, ok := myEnumMap[int32(e)]; !ok {
    return fmt.Errorf("'%d' is not a valid MyEnum enum value", e)
  }
  _, err := enc.EncodeInt(int32(e))
  return err
}
var _ decoderFrom = (*MyEnum)(nil)
// DecodeFrom decodes this value using the Decoder.
func (e *MyEnum) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding MyEnum: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  v, n, err := d.DecodeInt()
  if err != nil {
    return n, fmt.Errorf("decoding MyEnum: %w", err)
  }
  if _, ok := myEnumMap[v]; !ok {
    return n, fmt.Errorf("'%d' is not a valid MyEnum enum value", v)
  }
  *e = MyEnum(v)
  return n, nil
}
// MarshalBinary implements encoding.BinaryMarshaler.
func (s MyEnum) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *MyEnum) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*MyEnum)(nil)
  _ encoding.BinaryUnmarshaler = (*MyEnum)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s MyEnum) xdrType() {}

var _ xdrType = (*MyEnum)(nil)

// MyStruct is an XDR Struct defines as:
//
//   struct MyStruct {
//        int field1;
//        MyEnum field2;
//                    
//        unsigned int field3;
//          
//    };
//
type MyStruct struct {
  Field1 int32 
  Field2 MyEnum 
  Field3 uint32 
}

// EncodeTo encodes this value using the Encoder.
func (s *MyStruct) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeInt(int32(s.Field1)); err != nil {
    return err
  }
  if   err = s.Field2.EncodeTo(e); err != nil {
    return err
  }
  if _, err = e.EncodeUint(uint32(s.Field3)); err != nil {
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
  s.Field1, nTmp, err = d.DecodeInt()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
  nTmp, err = s.Field2.DecodeFrom(d, maxDepth)
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding MyEnum: %w", err)
  }
  s.Field3, nTmp, err = d.DecodeUint()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Unsigned int: %w", err)
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

// ConditionalStruct is an XDR Struct defines as:
//
//   struct ConditionalStruct {
//        int data;
//    };
//
type ConditionalStruct struct {
  Data int32 
}

// EncodeTo encodes this value using the Encoder.
func (s *ConditionalStruct) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeInt(int32(s.Data)); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*ConditionalStruct)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *ConditionalStruct) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding ConditionalStruct: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  s.Data, nTmp, err = d.DecodeInt()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s ConditionalStruct) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *ConditionalStruct) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*ConditionalStruct)(nil)
  _ encoding.BinaryUnmarshaler = (*ConditionalStruct)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s ConditionalStruct) xdrType() {}

var _ xdrType = (*ConditionalStruct)(nil)

// VariantStruct is an XDR Struct defines as:
//
//   struct VariantStruct {
//        int newField;
//    };
//
type VariantStruct struct {
  NewField int32 
}

// EncodeTo encodes this value using the Encoder.
func (s *VariantStruct) EncodeTo(e *xdr.Encoder) error {
  var err error
  if _, err = e.EncodeInt(int32(s.NewField)); err != nil {
    return err
  }
  return nil
}

var _ decoderFrom = (*VariantStruct)(nil)
// DecodeFrom decodes this value using the Decoder.
func (s *VariantStruct) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding VariantStruct: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  var err error
  var n, nTmp int
  s.NewField, nTmp, err = d.DecodeInt()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
  return n, nil
}

// MarshalBinary implements encoding.BinaryMarshaler.
func (s VariantStruct) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *VariantStruct) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*VariantStruct)(nil)
  _ encoding.BinaryUnmarshaler = (*VariantStruct)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s VariantStruct) xdrType() {}

var _ xdrType = (*VariantStruct)(nil)

// UnionType is an XDR Enum defines as:
//
//   enum UnionType {
//        UNION_A = 0,
//        UNION_B = 1,
//                    
//        UNION_C = 2,
//          
//        UNION_D = 3
//    };
//
type UnionType int32
const (
  UnionTypeUnionA UnionType = 0
  UnionTypeUnionB UnionType = 1
  UnionTypeUnionC UnionType = 2
  UnionTypeUnionD UnionType = 3
)
var unionTypeMap = map[int32]string{
  0: "UnionTypeUnionA",
  1: "UnionTypeUnionB",
  2: "UnionTypeUnionC",
  3: "UnionTypeUnionD",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for UnionType
func (e UnionType) ValidEnum(v int32) bool {
  _, ok := unionTypeMap[v]
  return ok
}
// String returns the name of `e`
func (e UnionType) String() string {
  name, _ := unionTypeMap[int32(e)]
  return name
}

// EncodeTo encodes this value using the Encoder.
func (e UnionType) EncodeTo(enc *xdr.Encoder) error {
  if _, ok := unionTypeMap[int32(e)]; !ok {
    return fmt.Errorf("'%d' is not a valid UnionType enum value", e)
  }
  _, err := enc.EncodeInt(int32(e))
  return err
}
var _ decoderFrom = (*UnionType)(nil)
// DecodeFrom decodes this value using the Decoder.
func (e *UnionType) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
  if maxDepth == 0 {
    return 0, fmt.Errorf("decoding UnionType: %w", ErrMaxDecodingDepthReached)
  }
  maxDepth -= 1
  v, n, err := d.DecodeInt()
  if err != nil {
    return n, fmt.Errorf("decoding UnionType: %w", err)
  }
  if _, ok := unionTypeMap[v]; !ok {
    return n, fmt.Errorf("'%d' is not a valid UnionType enum value", v)
  }
  *e = UnionType(v)
  return n, nil
}
// MarshalBinary implements encoding.BinaryMarshaler.
func (s UnionType) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *UnionType) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  o := xdr.DefaultDecodeOptions
  o.MaxInputLen = len(inp)
  d := xdr.NewDecoderWithOptions(r, o)
  _, err := s.DecodeFrom(d, o.MaxDepth)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*UnionType)(nil)
  _ encoding.BinaryUnmarshaler = (*UnionType)(nil)
)

// xdrType signals that this type represents XDR values defined by this package.
func (s UnionType) xdrType() {}

var _ xdrType = (*UnionType)(nil)

// MyUnion is an XDR Union defines as:
//
//   union MyUnion switch (UnionType type) {
//        case UNION_A:
//            int armA;
//        case UNION_B:
//            unsigned int armB;
//                    
//        case UNION_C:
//            unsigned hyper armC;
//          
//        case UNION_D:
//            void;
//    };
//
type MyUnion struct{
  Type UnionType
  ArmA *int32 
  ArmB *uint32 
  ArmC *uint64 
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u MyUnion) SwitchFieldName() string {
  return "Type"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of MyUnion
func (u MyUnion) ArmForSwitch(sw int32) (string, bool) {
switch UnionType(sw) {
    case UnionTypeUnionA:
      return "ArmA", true
    case UnionTypeUnionB:
      return "ArmB", true
    case UnionTypeUnionC:
      return "ArmC", true
    case UnionTypeUnionD:
      return "", true
}
return "-", false
}

// NewMyUnion creates a new  MyUnion.
func NewMyUnion(aType UnionType, value interface{}) (result MyUnion, err error) {
  result.Type = aType
switch UnionType(aType) {
    case UnionTypeUnionA:
                  tv, ok := value.(int32)
            if !ok {
              err = errors.New("invalid value, must be int32")
              return
            }
            result.ArmA = &tv
    case UnionTypeUnionB:
                  tv, ok := value.(uint32)
            if !ok {
              err = errors.New("invalid value, must be uint32")
              return
            }
            result.ArmB = &tv
    case UnionTypeUnionC:
                  tv, ok := value.(uint64)
            if !ok {
              err = errors.New("invalid value, must be uint64")
              return
            }
            result.ArmC = &tv
    case UnionTypeUnionD:
      // void
}
  return
}
// MustArmA retrieves the ArmA value from the union,
// panicing if the value is not set.
func (u MyUnion) MustArmA() int32 {
  val, ok := u.GetArmA()

  if !ok {
    panic("arm ArmA is not set")
  }

  return val
}

// GetArmA retrieves the ArmA value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u MyUnion) GetArmA() (result int32, ok bool) {
  armName, _ := u.ArmForSwitch(int32(u.Type))

  if armName == "ArmA" {
    result = *u.ArmA
    ok = true
  }

  return
}
// MustArmB retrieves the ArmB value from the union,
// panicing if the value is not set.
func (u MyUnion) MustArmB() uint32 {
  val, ok := u.GetArmB()

  if !ok {
    panic("arm ArmB is not set")
  }

  return val
}

// GetArmB retrieves the ArmB value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u MyUnion) GetArmB() (result uint32, ok bool) {
  armName, _ := u.ArmForSwitch(int32(u.Type))

  if armName == "ArmB" {
    result = *u.ArmB
    ok = true
  }

  return
}
// MustArmC retrieves the ArmC value from the union,
// panicing if the value is not set.
func (u MyUnion) MustArmC() uint64 {
  val, ok := u.GetArmC()

  if !ok {
    panic("arm ArmC is not set")
  }

  return val
}

// GetArmC retrieves the ArmC value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u MyUnion) GetArmC() (result uint64, ok bool) {
  armName, _ := u.ArmForSwitch(int32(u.Type))

  if armName == "ArmC" {
    result = *u.ArmC
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
switch UnionType(u.Type) {
    case UnionTypeUnionA:
        if _, err = e.EncodeInt(int32((*u.ArmA))); err != nil {
    return err
  }
return nil
    case UnionTypeUnionB:
        if _, err = e.EncodeUint(uint32((*u.ArmB))); err != nil {
    return err
  }
return nil
    case UnionTypeUnionC:
        if   _, err = e.EncodeUhyper(uint64((*u.ArmC))); err != nil {
    return err
  }
return nil
    case UnionTypeUnionD:
      // Void
return nil
}
  return fmt.Errorf("Type (UnionType) switch value '%d' is not valid for union MyUnion", u.Type)
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
    return n, fmt.Errorf("decoding UnionType: %w", err)
  }
switch UnionType(u.Type) {
    case UnionTypeUnionA:
        u.ArmA = new(int32)
  (*u.ArmA), nTmp, err = d.DecodeInt()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Int: %w", err)
  }
  return n, nil
    case UnionTypeUnionB:
        u.ArmB = new(uint32)
  (*u.ArmB), nTmp, err = d.DecodeUint()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Unsigned int: %w", err)
  }
  return n, nil
    case UnionTypeUnionC:
        u.ArmC = new(uint64)
  (*u.ArmC), nTmp, err = d.DecodeUhyper()
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding Unsigned hyper: %w", err)
  }
  return n, nil
    case UnionTypeUnionD:
      // Void
  return n, nil
}
  return n, fmt.Errorf("union MyUnion has invalid Type (UnionType) switch value '%d'", u.Type)
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
