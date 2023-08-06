// Automatically generated by xdrgen
// DO NOT EDIT or your changes may be overwritten

package MyXDR;


import java.io.IOException;

import com.google.common.io.BaseEncoding;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import com.google.common.base.Objects;

// === xdr source ============================================================

//  typedef int Foo;

//  ===========================================================================
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
    return Objects.hashCode(this.Foo);
  }

  @Override
  public boolean equals(Object object) {
    if (!(object instanceof Foo)) {
      return false;
    }

    Foo other = (Foo) object;
    return Objects.equal(this.Foo, other.Foo);
  }
  @Override
  public String toXdrBase64() throws IOException {
    BaseEncoding base64Encoding = BaseEncoding.base64();
    return base64Encoding.encode(toXdrByteArray());
  }

  @Override
  public byte[] toXdrByteArray() throws IOException {
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    XdrDataOutputStream xdrDataOutputStream = new XdrDataOutputStream(byteArrayOutputStream);
    encode(xdrDataOutputStream);
    return byteArrayOutputStream.toByteArray();
  }

  public static Foo fromXdrBase64(String xdr) throws IOException {
    BaseEncoding base64Encoding = BaseEncoding.base64();
    byte[] bytes = base64Encoding.decode(xdr);
    return fromXdrByteArray(bytes);
  }

  public static Foo fromXdrByteArray(byte[] xdr) throws IOException {
    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(xdr);
    XdrDataInputStream xdrDataInputStream = new XdrDataInputStream(byteArrayInputStream);
    return decode(xdrDataInputStream);
  }
}
