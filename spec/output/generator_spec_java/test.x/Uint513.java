// Automatically generated by xdrgen
// DO NOT EDIT or your changes may be overwritten

package MyXDR;

import java.io.IOException;

import static MyXDR.Constants.*;
import java.util.Base64;;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.util.Arrays;

// === xdr source ============================================================

//  typedef opaque uint513<64>;

//  ===========================================================================
public class Uint513 implements XdrElement {
  private byte[] uint513;

  public Uint513() {}

  public Uint513(byte[] uint513) {
    this.uint513 = uint513;
  }

  public byte[] getUint513() {
    return this.uint513;
  }

  public void setUint513(byte[] value) {
    this.uint513 = value;
  }

  public static void encode(XdrDataOutputStream stream, Uint513  encodedUint513) throws IOException {
    int uint513size = encodedUint513.uint513.length;
    stream.writeInt(uint513size);
    stream.write(encodedUint513.getUint513(), 0, uint513size);
  }

  public void encode(XdrDataOutputStream stream) throws IOException {
    encode(stream, this);
  }
  public static Uint513 decode(XdrDataInputStream stream) throws IOException {
    Uint513 decodedUint513 = new Uint513();
    int uint513size = stream.readInt();
    decodedUint513.uint513 = new byte[uint513size];
    stream.read(decodedUint513.uint513, 0, uint513size);
    return decodedUint513;
  }

  @Override
  public int hashCode() {
    return Arrays.hashCode(this.uint513);
  }

  @Override
  public boolean equals(Object object) {
    if (!(object instanceof Uint513)) {
      return false;
    }

    Uint513 other = (Uint513) object;
    return Arrays.equals(this.uint513, other.uint513);
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

  public static Uint513 fromXdrBase64(String xdr) throws IOException {
    byte[] bytes = Base64.getDecoder().decode(xdr);
    return fromXdrByteArray(bytes);
  }

  public static Uint513 fromXdrByteArray(byte[] xdr) throws IOException {
    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(xdr);
    XdrDataInputStream xdrDataInputStream = new XdrDataInputStream(byteArrayInputStream);
    return decode(xdrDataInputStream);
  }
}
