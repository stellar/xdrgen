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

//  typedef Hash Hashes2<12>;

//  ===========================================================================
public class Hashes2 implements XdrElement {
  private Hash[] Hashes2;

  public Hashes2() {}

  public Hashes2(Hash[] Hashes2) {
    this.Hashes2 = Hashes2;
  }

  public Hash[] getHashes2() {
    return this.Hashes2;
  }

  public void setHashes2(Hash[] value) {
    this.Hashes2 = value;
  }

  public static void encode(XdrDataOutputStream stream, Hashes2  encodedHashes2) throws IOException {
    int Hashes2size = encodedHashes2.getHashes2().length;
    stream.writeInt(Hashes2size);
    for (int i = 0; i < Hashes2size; i++) {
      Hash.encode(stream, encodedHashes2.Hashes2[i]);
    }
  }

  public void encode(XdrDataOutputStream stream) throws IOException {
    encode(stream, this);
  }
  public static Hashes2 decode(XdrDataInputStream stream) throws IOException {
    Hashes2 decodedHashes2 = new Hashes2();
    int Hashes2size = stream.readInt();
    decodedHashes2.Hashes2 = new Hash[Hashes2size];
    for (int i = 0; i < Hashes2size; i++) {
      decodedHashes2.Hashes2[i] = Hash.decode(stream);
    }
    return decodedHashes2;
  }

  @Override
  public int hashCode() {
    return Arrays.hashCode(this.Hashes2);
  }

  @Override
  public boolean equals(Object object) {
    if (!(object instanceof Hashes2)) {
      return false;
    }

    Hashes2 other = (Hashes2) object;
    return Arrays.equals(this.Hashes2, other.Hashes2);
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

  public static Hashes2 fromXdrBase64(String xdr) throws IOException {
    byte[] bytes = Base64.getDecoder().decode(xdr);
    return fromXdrByteArray(bytes);
  }

  public static Hashes2 fromXdrByteArray(byte[] xdr) throws IOException {
    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(xdr);
    XdrDataInputStream xdrDataInputStream = new XdrDataInputStream(byteArrayInputStream);
    return decode(xdrDataInputStream);
  }
}
