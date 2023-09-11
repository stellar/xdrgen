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

//  typedef Hash *optHash1;

//  ===========================================================================
public class OptHash1 implements XdrElement {
  private Hash optHash1;

  public OptHash1() {}

  public OptHash1(Hash optHash1) {
    this.optHash1 = optHash1;
  }

  public Hash getOptHash1() {
    return this.optHash1;
  }

  public void setOptHash1(Hash value) {
    this.optHash1 = value;
  }

  public static void encode(XdrDataOutputStream stream, OptHash1  encodedOptHash1) throws IOException {
    if (encodedOptHash1.optHash1 != null) {
    stream.writeInt(1);
    Hash.encode(stream, encodedOptHash1.optHash1);
    } else {
    stream.writeInt(0);
    }
  }

  public void encode(XdrDataOutputStream stream) throws IOException {
    encode(stream, this);
  }
  public static OptHash1 decode(XdrDataInputStream stream) throws IOException {
    OptHash1 decodedOptHash1 = new OptHash1();
    int optHash1Present = stream.readInt();
    if (optHash1Present != 0) {
    decodedOptHash1.optHash1 = Hash.decode(stream);
    }
    return decodedOptHash1;
  }

  @Override
  public int hashCode() {
    return Objects.hash(this.optHash1);
  }

  @Override
  public boolean equals(Object object) {
    if (!(object instanceof OptHash1)) {
      return false;
    }

    OptHash1 other = (OptHash1) object;
    return Objects.equals(this.optHash1, other.optHash1);
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

  public static OptHash1 fromXdrBase64(String xdr) throws IOException {
    byte[] bytes = Base64.getDecoder().decode(xdr);
    return fromXdrByteArray(bytes);
  }

  public static OptHash1 fromXdrByteArray(byte[] xdr) throws IOException {
    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(xdr);
    XdrDataInputStream xdrDataInputStream = new XdrDataInputStream(byteArrayInputStream);
    return decode(xdrDataInputStream);
  }
}
