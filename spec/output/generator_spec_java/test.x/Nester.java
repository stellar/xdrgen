// Automatically generated by xdrgen
// DO NOT EDIT or your changes may be overwritten

package MyXDR;


import java.io.IOException;

import com.google.common.base.Objects;

// === xdr source ============================================================

//  struct Nester
//  {
//    enum {
//      BLAH_1,
//      BLAH_2
//    } nestedEnum;
//  
//    struct {
//      int blah;
//    } nestedStruct;
//  
//    union switch (Color color) {
//      case RED:
//        void;
//      default:
//        int blah2;
//    } nestedUnion;
//  
//  
//  };

//  ===========================================================================
public class Nester implements XdrElement {
  public Nester () {}
  private NesterNestedEnum nestedEnum;
  public NesterNestedEnum getNestedEnum() {
    return this.nestedEnum;
  }
  public void setNestedEnum(NesterNestedEnum value) {
    this.nestedEnum = value;
  }
  private NesterNestedStruct nestedStruct;
  public NesterNestedStruct getNestedStruct() {
    return this.nestedStruct;
  }
  public void setNestedStruct(NesterNestedStruct value) {
    this.nestedStruct = value;
  }
  private NesterNestedUnion nestedUnion;
  public NesterNestedUnion getNestedUnion() {
    return this.nestedUnion;
  }
  public void setNestedUnion(NesterNestedUnion value) {
    this.nestedUnion = value;
  }
  public static void encode(XdrDataOutputStream stream, Nester encodedNester) throws IOException{
    NesterNestedEnum.encode(stream, encodedNester.nestedEnum);
    NesterNestedStruct.encode(stream, encodedNester.nestedStruct);
    NesterNestedUnion.encode(stream, encodedNester.nestedUnion);
  }
  public void encode(XdrDataOutputStream stream) throws IOException {
    encode(stream, this);
  }
  public static Nester decode(XdrDataInputStream stream) throws IOException {
    Nester decodedNester = new Nester();
    decodedNester.nestedEnum = NesterNestedEnum.decode(stream);
    decodedNester.nestedStruct = NesterNestedStruct.decode(stream);
    decodedNester.nestedUnion = NesterNestedUnion.decode(stream);
    return decodedNester;
  }
  @Override
  public int hashCode() {
    return Objects.hashCode(this.nestedEnum, this.nestedStruct, this.nestedUnion);
  }
  @Override
  public boolean equals(Object object) {
    if (!(object instanceof Nester)) {
      return false;
    }

    Nester other = (Nester) object;
    return Objects.equal(this.nestedEnum, other.nestedEnum) && Objects.equal(this.nestedStruct, other.nestedStruct) && Objects.equal(this.nestedUnion, other.nestedUnion);
  }

  public static final class Builder {
    private NesterNestedEnum nestedEnum;
    private NesterNestedStruct nestedStruct;
    private NesterNestedUnion nestedUnion;

    public Builder nestedEnum(NesterNestedEnum nestedEnum) {
      this.nestedEnum = nestedEnum;
      return this;
    }

    public Builder nestedStruct(NesterNestedStruct nestedStruct) {
      this.nestedStruct = nestedStruct;
      return this;
    }

    public Builder nestedUnion(NesterNestedUnion nestedUnion) {
      this.nestedUnion = nestedUnion;
      return this;
    }

    public Nester build() {
      Nester val = new Nester();
      val.setNestedEnum(nestedEnum);
      val.setNestedStruct(nestedStruct);
      val.setNestedUnion(nestedUnion);
      return val;
    }
  }

  public static enum NesterNestedEnum {
    BLAH_1(0),
    BLAH_2(1),
    ;
    private int mValue;

    NestedEnum(int value) {
        mValue = value;
    }

    public int getValue() {
        return mValue;
    }

    public static NestedEnum decode(XdrDataInputStream stream) throws IOException {
      int value = stream.readInt();
      switch (value) {
        case 0: return BLAH_1;
        case 1: return BLAH_2;
        default:
          throw new RuntimeException("Unknown enum value: " + value);
      }
    }

    public static void encode(XdrDataOutputStream stream, NestedEnum value) throws IOException {
      stream.writeInt(value.getValue());
    }

    public void encode(XdrDataOutputStream stream) throws IOException {
      encode(stream, this);
    }

  }
  public static class NesterNestedStruct {
    public NesterNestedStruct () {}
    private Integer blah;
    public Integer getBlah() {
      return this.blah;
    }
    public void setBlah(Integer value) {
      this.blah = value;
    }
    public static void encode(XdrDataOutputStream stream, NesterNestedStruct encodedNesterNestedStruct) throws IOException{
      stream.writeInt(encodedNesterNestedStruct.blah);
    }
    public void encode(XdrDataOutputStream stream) throws IOException {
      encode(stream, this);
    }
    public static NesterNestedStruct decode(XdrDataInputStream stream) throws IOException {
      NesterNestedStruct decodedNesterNestedStruct = new NesterNestedStruct();
      decodedNesterNestedStruct.blah = stream.readInt();
      return decodedNesterNestedStruct;
    }
    @Override
    public int hashCode() {
      return Objects.hashCode(this.blah);
    }
    @Override
    public boolean equals(Object object) {
      if (!(object instanceof NesterNestedStruct)) {
        return false;
      }

      NesterNestedStruct other = (NesterNestedStruct) object;
      return Objects.equal(this.blah, other.blah);
    }

    public static final class Builder {
      private Integer blah;

      public Builder blah(Integer blah) {
        this.blah = blah;
        return this;
      }

      public NesterNestedStruct build() {
        NesterNestedStruct val = new NesterNestedStruct();
        val.setBlah(blah);
        return val;
      }
    }

  }
  public static class NesterNestedUnion {
    public NesterNestedUnion () {}
    Color color;
    public Color getDiscriminant() {
      return this.color;
    }
    public void setDiscriminant(Color value) {
      this.color = value;
    }
    private Integer blah2;
    public Integer getBlah2() {
      return this.blah2;
    }
    public void setBlah2(Integer value) {
      this.blah2 = value;
    }

    public static final class Builder {
      private Color discriminant;
      private Integer blah2;

      public Builder discriminant(Color discriminant) {
        this.discriminant = discriminant;
        return this;
      }

      public Builder blah2(Integer blah2) {
        this.blah2 = blah2;
        return this;
      }

      public NesterNestedUnion build() {
        NesterNestedUnion val = new NesterNestedUnion();
        val.setDiscriminant(discriminant);
        val.setBlah2(blah2);
        return val;
      }
    }

    public static void encode(XdrDataOutputStream stream, NesterNestedUnion encodedNesterNestedUnion) throws IOException {
    //Xdrgen::AST::Identifier
    //Color
    stream.writeInt(encodedNesterNestedUnion.getDiscriminant().getValue());
    switch (encodedNesterNestedUnion.getDiscriminant()) {
    case RED:
    break;
    default:
    stream.writeInt(encodedNesterNestedUnion.blah2);
    break;
    }
    }
    public void encode(XdrDataOutputStream stream) throws IOException {
      encode(stream, this);
    }
    public static NesterNestedUnion decode(XdrDataInputStream stream) throws IOException {
    NesterNestedUnion decodedNesterNestedUnion = new NesterNestedUnion();
    Color discriminant = Color.decode(stream);
    decodedNesterNestedUnion.setDiscriminant(discriminant);
    switch (decodedNesterNestedUnion.getDiscriminant()) {
    case RED:
    break;
    default:
    decodedNesterNestedUnion.blah2 = stream.readInt();
    break;
    }
      return decodedNesterNestedUnion;
    }
    @Override
    public int hashCode() {
      return Objects.hashCode(this.blah2, this.color);
    }
    @Override
    public boolean equals(Object object) {
      if (!(object instanceof NesterNestedUnion)) {
        return false;
      }

      NesterNestedUnion other = (NesterNestedUnion) object;
      return Objects.equal(this.blah2, other.blah2) && Objects.equal(this.color, other.color);
    }

  }
}
