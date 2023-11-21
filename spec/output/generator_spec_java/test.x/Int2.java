// Automatically generated by xdrgen
// DO NOT EDIT or your changes may be overwritten

package MyXDR;

import java.io.IOException;

import static MyXDR.Constants.*;
import org.stellar.sdk.Base64Factory;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.util.Objects;

// === xdr source ============================================================

//  typedef hyper           int2;

//  ===========================================================================
public class Int2 implements XdrElement {
  private Long int2;

  public Int2() {}

  public Int2(Long int2) {
    this.int2 = int2;
  }

  public Long getInt2() {
    return this.int2;
  }

  public void setInt2(Long value) {
    this.int2 = value;
  }

  public static void encode(XdrDataOutputStream stream, Int2  encodedInt2) throws IOException {
    stream.writeLong(encodedInt2.int2);
  }

  public void encode(XdrDataOutputStream stream) throws IOException {
    encode(stream, this);
  }
  public static Int2 decode(XdrDataInputStream stream) throws IOException {
    Int2 decodedInt2 = new Int2();
    decodedInt2.int2 = stream.readLong();
    return decodedInt2;
  }

  @Override
  public int hashCode() {
    return Objects.hash(this.int2);
  }

  @Override
  public boolean equals(Object object) {
    if (!(object instanceof Int2)) {
      return false;
    }

    Int2 other = (Int2) object;
    return Objects.equals(this.int2, other.int2);
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

  public static Int2 fromXdrBase64(String xdr) throws IOException {
    byte[] bytes = Base64Factory.getInstance().decode(xdr);
    return fromXdrByteArray(bytes);
  }

  public static Int2 fromXdrByteArray(byte[] xdr) throws IOException {
    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(xdr);
    XdrDataInputStream xdrDataInputStream = new XdrDataInputStream(byteArrayInputStream);
    return decode(xdrDataInputStream);
  }
}
