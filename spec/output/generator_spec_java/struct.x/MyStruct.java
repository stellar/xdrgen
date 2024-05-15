// Automatically generated by xdrgen
// DO NOT EDIT or your changes may be overwritten

package MyXDR;

import java.io.IOException;

import static MyXDR.Constants.*;
import org.stellar.sdk.Base64Factory;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.util.Objects;
import java.util.Arrays;

/**
 * MyStruct's original definition in the XDR file is:
 * <pre>
 * struct MyStruct
 * {
 *     int    someInt;
 *     int64  aBigInt;
 *     opaque someOpaque[10];
 *     string someString&lt;&gt;;
 *     string maxString&lt;100&gt;;
 * };
 * </pre>
 */
public class MyStruct implements XdrElement {
  public MyStruct () {}
  private Integer someInt;
  public Integer getSomeInt() {
    return this.someInt;
  }
  public void setSomeInt(Integer value) {
    this.someInt = value;
  }
  private Int64 aBigInt;
  public Int64 getABigInt() {
    return this.aBigInt;
  }
  public void setABigInt(Int64 value) {
    this.aBigInt = value;
  }
  private byte[] someOpaque;
  public byte[] getSomeOpaque() {
    return this.someOpaque;
  }
  public void setSomeOpaque(byte[] value) {
    this.someOpaque = value;
  }
  private XdrString someString;
  public XdrString getSomeString() {
    return this.someString;
  }
  public void setSomeString(XdrString value) {
    this.someString = value;
  }
  private XdrString maxString;
  public XdrString getMaxString() {
    return this.maxString;
  }
  public void setMaxString(XdrString value) {
    this.maxString = value;
  }
  public static void encode(XdrDataOutputStream stream, MyStruct encodedMyStruct) throws IOException{
    stream.writeInt(encodedMyStruct.someInt);
    Int64.encode(stream, encodedMyStruct.aBigInt);
    int someOpaquesize = encodedMyStruct.someOpaque.length;
    stream.write(encodedMyStruct.getSomeOpaque(), 0, someOpaquesize);
    encodedMyStruct.someString.encode(stream);
    encodedMyStruct.maxString.encode(stream);
  }
  public void encode(XdrDataOutputStream stream) throws IOException {
    encode(stream, this);
  }
  public static MyStruct decode(XdrDataInputStream stream) throws IOException {
    MyStruct decodedMyStruct = new MyStruct();
    decodedMyStruct.someInt = stream.readInt();
    decodedMyStruct.aBigInt = Int64.decode(stream);
    int someOpaquesize = 10;
    decodedMyStruct.someOpaque = new byte[someOpaquesize];
    stream.read(decodedMyStruct.someOpaque, 0, someOpaquesize);
    decodedMyStruct.someString = XdrString.decode(stream, Integer.MAX_VALUE);
    decodedMyStruct.maxString = XdrString.decode(stream, 100);
    return decodedMyStruct;
  }
  @Override
  public int hashCode() {
    return Objects.hash(this.someInt, this.aBigInt, Arrays.hashCode(this.someOpaque), this.someString, this.maxString);
  }
  @Override
  public boolean equals(Object object) {
    if (!(object instanceof MyStruct)) {
      return false;
    }

    MyStruct other = (MyStruct) object;
    return Objects.equals(this.someInt, other.someInt) && Objects.equals(this.aBigInt, other.aBigInt) && Arrays.equals(this.someOpaque, other.someOpaque) && Objects.equals(this.someString, other.someString) && Objects.equals(this.maxString, other.maxString);
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

  public static MyStruct fromXdrBase64(String xdr) throws IOException {
    byte[] bytes = Base64Factory.getInstance().decode(xdr);
    return fromXdrByteArray(bytes);
  }

  public static MyStruct fromXdrByteArray(byte[] xdr) throws IOException {
    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(xdr);
    XdrDataInputStream xdrDataInputStream = new XdrDataInputStream(byteArrayInputStream);
    return decode(xdrDataInputStream);
  }
  public static final class Builder {
    private Integer someInt;
    private Int64 aBigInt;
    private byte[] someOpaque;
    private XdrString someString;
    private XdrString maxString;

    public Builder someInt(Integer someInt) {
      this.someInt = someInt;
      return this;
    }

    public Builder aBigInt(Int64 aBigInt) {
      this.aBigInt = aBigInt;
      return this;
    }

    public Builder someOpaque(byte[] someOpaque) {
      this.someOpaque = someOpaque;
      return this;
    }

    public Builder someString(XdrString someString) {
      this.someString = someString;
      return this;
    }

    public Builder maxString(XdrString maxString) {
      this.maxString = maxString;
      return this;
    }

    public MyStruct build() {
      MyStruct val = new MyStruct();
      val.setSomeInt(this.someInt);
      val.setABigInt(this.aBigInt);
      val.setSomeOpaque(this.someOpaque);
      val.setSomeString(this.someString);
      val.setMaxString(this.maxString);
      return val;
    }
  }
}
