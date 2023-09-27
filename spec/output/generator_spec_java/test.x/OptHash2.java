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

//  typedef Hash* optHash2;

//  ===========================================================================
public class OptHash2 implements XdrElement {
  private Hash optHash2;

  public OptHash2() {}

  public OptHash2(Hash optHash2) {
    this.optHash2 = optHash2;
  }

  public Hash getOptHash2() {
    return this.optHash2;
  }

  public void setOptHash2(Hash value) {
    this.optHash2 = value;
  }

  public static void encode(XdrDataOutputStream stream, OptHash2  encodedOptHash2) throws IOException {
    if (encodedOptHash2.optHash2 != null) {
    stream.writeInt(1);
    Hash.encode(stream, encodedOptHash2.optHash2);
    } else {
    stream.writeInt(0);
    }
  }

  public void encode(XdrDataOutputStream stream) throws IOException {
    encode(stream, this);
  }
  public static OptHash2 decode(XdrDataInputStream stream) throws IOException {
    OptHash2 decodedOptHash2 = new OptHash2();
    int optHash2Present = stream.readInt();
    if (optHash2Present != 0) {
    decodedOptHash2.optHash2 = Hash.decode(stream);
    }
    return decodedOptHash2;
  }

  @Override
  public int hashCode() {
    return Objects.hash(this.optHash2);
  }

  @Override
  public boolean equals(Object object) {
    if (!(object instanceof OptHash2)) {
      return false;
    }

    OptHash2 other = (OptHash2) object;
    return Objects.equals(this.optHash2, other.optHash2);
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

  public static OptHash2 fromXdrBase64(String xdr) throws IOException {
    byte[] bytes = Base64Factory.getInstance().decode(xdr);
    return fromXdrByteArray(bytes);
  }

  public static OptHash2 fromXdrByteArray(byte[] xdr) throws IOException {
    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(xdr);
    XdrDataInputStream xdrDataInputStream = new XdrDataInputStream(byteArrayInputStream);
    return decode(xdrDataInputStream);
  }
}
