// Automatically generated by xdrgen
// DO NOT EDIT or your changes may be overwritten

package MyXDR;

import java.io.IOException;

import static MyXDR.Constants.*;
import org.stellar.sdk.Base64Factory;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.util.Objects;

/**
 * HasStuff's original definition in the XDR file is:
 * <pre>
 * struct HasStuff
 * {
 *   LotsOfMyStructs data;
 * };
 * </pre>
 */
public class HasStuff implements XdrElement {
  public HasStuff () {}
  private LotsOfMyStructs data;
  public LotsOfMyStructs getData() {
    return this.data;
  }
  public void setData(LotsOfMyStructs value) {
    this.data = value;
  }
  public static void encode(XdrDataOutputStream stream, HasStuff encodedHasStuff) throws IOException{
    LotsOfMyStructs.encode(stream, encodedHasStuff.data);
  }
  public void encode(XdrDataOutputStream stream) throws IOException {
    encode(stream, this);
  }
  public static HasStuff decode(XdrDataInputStream stream) throws IOException {
    HasStuff decodedHasStuff = new HasStuff();
    decodedHasStuff.data = LotsOfMyStructs.decode(stream);
    return decodedHasStuff;
  }
  @Override
  public int hashCode() {
    return Objects.hash(this.data);
  }
  @Override
  public boolean equals(Object object) {
    if (!(object instanceof HasStuff)) {
      return false;
    }

    HasStuff other = (HasStuff) object;
    return Objects.equals(this.data, other.data);
  }

  @Override
  public String toXdrBase64() throws IOException {
    return Base64Factory.getInstance().encodeToString(toXdrByteArray());
  }

  @Override
  public byte[] toXdrByteArray() throws IOException {
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    XdrDataOutputStream xdrDataOutputStream = new XdrDataOutputStream(byteArrayOutputStream);
    encode(xdrDataOutputStream);
    return byteArrayOutputStream.toByteArray();
  }

  public static HasStuff fromXdrBase64(String xdr) throws IOException {
    byte[] bytes = Base64Factory.getInstance().decode(xdr);
    return fromXdrByteArray(bytes);
  }

  public static HasStuff fromXdrByteArray(byte[] xdr) throws IOException {
    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(xdr);
    XdrDataInputStream xdrDataInputStream = new XdrDataInputStream(byteArrayInputStream);
    return decode(xdrDataInputStream);
  }
  public static final class Builder {
    private LotsOfMyStructs data;

    public Builder data(LotsOfMyStructs data) {
      this.data = data;
      return this;
    }

    public HasStuff build() {
      HasStuff val = new HasStuff();
      val.setData(this.data);
      return val;
    }
  }
}
