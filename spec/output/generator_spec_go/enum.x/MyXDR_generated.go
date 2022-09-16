//lint:file-ignore S1005 The issue should be fixed in xdrgen. Unfortunately, there's no way to ignore a single file in staticcheck.
//lint:file-ignore U1000 fmtTest is not needed anywhere, should be removed in xdrgen.

// Package MyXDR is generated from:
//
//  spec/fixtures/generator/enum.x
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
  "spec/fixtures/generator/enum.x": "26f6c8245ab186aa48ec0cf17d0e521258741d8d574de33f4631a45cc6d42af7",
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

// MessageType is an XDR Enum defines as:
//
//   enum MessageType
//    {
//        ERROR_MSG,    
//        HELLO,
//        DONT_HAVE,
//    
//        GET_PEERS,   // gets a list of peers this guy knows about        
//        PEERS,
//    
//        GET_TX_SET,  // gets a particular txset by hash        
//        TX_SET,    
//    
//        GET_VALIDATIONS, // gets validations for a given ledger hash        
//        VALIDATIONS,    
//    
//        TRANSACTION, //pass on a tx you have heard about        
//        JSON_TRANSACTION,
//    
//        // FBA        
//        GET_FBA_QUORUMSET,        
//        FBA_QUORUMSET,    
//        FBA_MESSAGE
//    };
//
type MessageType int32
const (
  MessageTypeErrorMsg MessageType = 0
  MessageTypeHello MessageType = 1
  MessageTypeDontHave MessageType = 2
  MessageTypeGetPeers MessageType = 3
  MessageTypePeers MessageType = 4
  MessageTypeGetTxSet MessageType = 5
  MessageTypeTxSet MessageType = 6
  MessageTypeGetValidations MessageType = 7
  MessageTypeValidations MessageType = 8
  MessageTypeTransaction MessageType = 9
  MessageTypeJsonTransaction MessageType = 10
  MessageTypeGetFbaQuorumset MessageType = 11
  MessageTypeFbaQuorumset MessageType = 12
  MessageTypeFbaMessage MessageType = 13
)
var messageTypeMap = map[int32]string{
  0: "MessageTypeErrorMsg",
  1: "MessageTypeHello",
  2: "MessageTypeDontHave",
  3: "MessageTypeGetPeers",
  4: "MessageTypePeers",
  5: "MessageTypeGetTxSet",
  6: "MessageTypeTxSet",
  7: "MessageTypeGetValidations",
  8: "MessageTypeValidations",
  9: "MessageTypeTransaction",
  10: "MessageTypeJsonTransaction",
  11: "MessageTypeGetFbaQuorumset",
  12: "MessageTypeFbaQuorumset",
  13: "MessageTypeFbaMessage",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for MessageType
func (e MessageType) ValidEnum(v int32) bool {
  _, ok := messageTypeMap[v]
  return ok
}
// String returns the name of `e`
func (e MessageType) String() string {
  name, _ := messageTypeMap[int32(e)]
  return name
}

// EncodeTo encodes this value using the Encoder.
func (e MessageType) EncodeTo(enc *xdr.Encoder) error {
  if _, ok := messageTypeMap[int32(e)]; !ok {
    return fmt.Errorf("'%d' is not a valid MessageType enum value", e)
  }
  _, err := enc.EncodeInt(int32(e))
  return err
}
var _ decoderFrom = (*MessageType)(nil)
// DecodeFrom decodes this value using the Decoder.
func (e *MessageType) DecodeFrom(d *xdr.Decoder) (int, error) {
  v, n, err := d.DecodeInt()
  if err != nil {
    return n, fmt.Errorf("decoding MessageType: %s", err)
  }
  if _, ok := messageTypeMap[v]; !ok {
    return n, fmt.Errorf("'%d' is not a valid MessageType enum value", v)
  }
  *e = MessageType(v)
  return n, nil
}
// MarshalBinary implements encoding.BinaryMarshaler.
func (s MessageType) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *MessageType) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  d := xdr.NewDecoder(r)
  _, err := s.DecodeFrom(d)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*MessageType)(nil)
  _ encoding.BinaryUnmarshaler = (*MessageType)(nil)
)

// xdrType signals that this type is an type representing
// representing XDR values defined by this package.
func (s MessageType) xdrType() {}

var _ xdrType = (*MessageType)(nil)

// Color is an XDR Enum defines as:
//
//   enum Color {
//        RED=0,  
//        GREEN=1,  
//        BLUE=2  
//    };
//
type Color int32
const (
  ColorRed Color = 0
  ColorGreen Color = 1
  ColorBlue Color = 2
)
var colorMap = map[int32]string{
  0: "ColorRed",
  1: "ColorGreen",
  2: "ColorBlue",
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
func (e *Color) DecodeFrom(d *xdr.Decoder) (int, error) {
  v, n, err := d.DecodeInt()
  if err != nil {
    return n, fmt.Errorf("decoding Color: %s", err)
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
  d := xdr.NewDecoder(r)
  _, err := s.DecodeFrom(d)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Color)(nil)
  _ encoding.BinaryUnmarshaler = (*Color)(nil)
)

// xdrType signals that this type is an type representing
// representing XDR values defined by this package.
func (s Color) xdrType() {}

var _ xdrType = (*Color)(nil)

// Color2 is an XDR Enum defines as:
//
//   enum Color2 {
//        RED2=RED,  
//        GREEN2=1,  
//        BLUE2=2  
//    };
//
type Color2 int32
const (
  Color2Red2 Color2 = 0
  Color2Green2 Color2 = 1
  Color2Blue2 Color2 = 2
)
var color2Map = map[int32]string{
  0: "Color2Red2",
  1: "Color2Green2",
  2: "Color2Blue2",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for Color2
func (e Color2) ValidEnum(v int32) bool {
  _, ok := color2Map[v]
  return ok
}
// String returns the name of `e`
func (e Color2) String() string {
  name, _ := color2Map[int32(e)]
  return name
}

// EncodeTo encodes this value using the Encoder.
func (e Color2) EncodeTo(enc *xdr.Encoder) error {
  if _, ok := color2Map[int32(e)]; !ok {
    return fmt.Errorf("'%d' is not a valid Color2 enum value", e)
  }
  _, err := enc.EncodeInt(int32(e))
  return err
}
var _ decoderFrom = (*Color2)(nil)
// DecodeFrom decodes this value using the Decoder.
func (e *Color2) DecodeFrom(d *xdr.Decoder) (int, error) {
  v, n, err := d.DecodeInt()
  if err != nil {
    return n, fmt.Errorf("decoding Color2: %s", err)
  }
  if _, ok := color2Map[v]; !ok {
    return n, fmt.Errorf("'%d' is not a valid Color2 enum value", v)
  }
  *e = Color2(v)
  return n, nil
}
// MarshalBinary implements encoding.BinaryMarshaler.
func (s Color2) MarshalBinary() ([]byte, error) {
  b := bytes.Buffer{}
  e := xdr.NewEncoder(&b)
  err := s.EncodeTo(e)
  return b.Bytes(), err
}

// UnmarshalBinary implements encoding.BinaryUnmarshaler.
func (s *Color2) UnmarshalBinary(inp []byte) error {
  r := bytes.NewReader(inp)
  d := xdr.NewDecoder(r)
  _, err := s.DecodeFrom(d)
  return err
}

var (
  _ encoding.BinaryMarshaler   = (*Color2)(nil)
  _ encoding.BinaryUnmarshaler = (*Color2)(nil)
)

// xdrType signals that this type is an type representing
// representing XDR values defined by this package.
func (s Color2) xdrType() {}

var _ xdrType = (*Color2)(nil)

        var fmtTest = fmt.Sprint("this is a dummy usage of fmt")

