// Automatically generated by xdrgen
// DO NOT EDIT or your changes may be overwritten

package MyXDR;

import java.io.IOException;

import static MyXDR.Constants.*;
import java.util.Base64;;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.util.Objects;

// === xdr source ============================================================

//  struct HasOptions
//  {
//    int* firstOption;
//    int *secondOption;
//    Arr *thirdOption;
//  };

//  ===========================================================================
public class HasOptions implements XdrElement {
  public HasOptions () {}
  private Integer firstOption;
  public Integer getFirstOption() {
    return this.firstOption;
  }
  public void setFirstOption(Integer value) {
    this.firstOption = value;
  }
  private Integer secondOption;
  public Integer getSecondOption() {
    return this.secondOption;
  }
  public void setSecondOption(Integer value) {
    this.secondOption = value;
  }
  private Arr thirdOption;
  public Arr getThirdOption() {
    return this.thirdOption;
  }
  public void setThirdOption(Arr value) {
    this.thirdOption = value;
  }
  public static void encode(XdrDataOutputStream stream, HasOptions encodedHasOptions) throws IOException{
    if (encodedHasOptions.firstOption != null) {
    stream.writeInt(1);
    stream.writeInt(encodedHasOptions.firstOption);
    } else {
    stream.writeInt(0);
    }
    if (encodedHasOptions.secondOption != null) {
    stream.writeInt(1);
    stream.writeInt(encodedHasOptions.secondOption);
    } else {
    stream.writeInt(0);
    }
    if (encodedHasOptions.thirdOption != null) {
    stream.writeInt(1);
    Arr.encode(stream, encodedHasOptions.thirdOption);
    } else {
    stream.writeInt(0);
    }
  }
  public void encode(XdrDataOutputStream stream) throws IOException {
    encode(stream, this);
  }
  public static HasOptions decode(XdrDataInputStream stream) throws IOException {
    HasOptions decodedHasOptions = new HasOptions();
    int firstOptionPresent = stream.readInt();
    if (firstOptionPresent != 0) {
    decodedHasOptions.firstOption = stream.readInt();
    }
    int secondOptionPresent = stream.readInt();
    if (secondOptionPresent != 0) {
    decodedHasOptions.secondOption = stream.readInt();
    }
    int thirdOptionPresent = stream.readInt();
    if (thirdOptionPresent != 0) {
    decodedHasOptions.thirdOption = Arr.decode(stream);
    }
    return decodedHasOptions;
  }
  @Override
  public int hashCode() {
    return Objects.hash(this.firstOption, this.secondOption, this.thirdOption);
  }
  @Override
  public boolean equals(Object object) {
    if (!(object instanceof HasOptions)) {
      return false;
    }

    HasOptions other = (HasOptions) object;
    return Objects.equals(this.firstOption, other.firstOption) && Objects.equals(this.secondOption, other.secondOption) && Objects.equals(this.thirdOption, other.thirdOption);
  }

  @Override
  public String toXdrBase64() throws IOException {
    return Base64.getEncoder().encodeToString(toXdrByteArray());
  }

  @Override
  public byte[] toXdrByteArray() throws IOException {
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    XdrDataOutputStream xdrDataOutputStream = new XdrDataOutputStream(byteArrayOutputStream);
    encode(xdrDataOutputStream);
    return byteArrayOutputStream.toByteArray();
  }

  public static HasOptions fromXdrBase64(String xdr) throws IOException {
    byte[] bytes = Base64.getDecoder().decode(xdr);
    return fromXdrByteArray(bytes);
  }

  public static HasOptions fromXdrByteArray(byte[] xdr) throws IOException {
    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(xdr);
    XdrDataInputStream xdrDataInputStream = new XdrDataInputStream(byteArrayInputStream);
    return decode(xdrDataInputStream);
  }
  public static final class Builder {
    private Integer firstOption;
    private Integer secondOption;
    private Arr thirdOption;

    public Builder firstOption(Integer firstOption) {
      this.firstOption = firstOption;
      return this;
    }

    public Builder secondOption(Integer secondOption) {
      this.secondOption = secondOption;
      return this;
    }

    public Builder thirdOption(Arr thirdOption) {
      this.thirdOption = thirdOption;
      return this;
    }

    public HasOptions build() {
      HasOptions val = new HasOptions();
      val.setFirstOption(this.firstOption);
      val.setSecondOption(this.secondOption);
      val.setThirdOption(this.thirdOption);
      return val;
    }
  }
}
