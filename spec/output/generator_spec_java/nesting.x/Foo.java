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
 * Foo's original definition in the XDR file is:
 * <pre>
 * typedef int Foo;
 * </pre>
 */
public class Foo implements XdrElement {
  private Integer Foo;

  public Foo() {}

  public Foo(Integer Foo) {
    this.Foo = Foo;
  }

  public Integer getFoo() {
    return this.Foo;
  }

  public void setFoo(Integer value) {
    this.Foo = value;
  }

  public static void encode(XdrDataOutputStream stream, Foo  encodedFoo) throws IOException {
    stream.writeInt(encodedFoo.Foo);
  }

  public void encode(XdrDataOutputStream stream) throws IOException {
    encode(stream, this);
  }
  public static Foo decode(XdrDataInputStream stream) throws IOException {
    Foo decodedFoo = new Foo();
    decodedFoo.Foo = stream.readInt();
    return decodedFoo;
  }

  @Override
  public int hashCode() {
    return Objects.hash(this.Foo);
  }

  @Override
  public boolean equals(Object object) {
    if (!(object instanceof Foo)) {
      return false;
    }

    Foo other = (Foo) object;
    return Objects.equals(this.Foo, other.Foo);
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

  public static Foo fromXdrBase64(String xdr) throws IOException {
    byte[] bytes = Base64Factory.getInstance().decode(xdr);
    return fromXdrByteArray(bytes);
  }

  public static Foo fromXdrByteArray(byte[] xdr) throws IOException {
    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(xdr);
    XdrDataInputStream xdrDataInputStream = new XdrDataInputStream(byteArrayInputStream);
    return decode(xdrDataInputStream);
  }
}
