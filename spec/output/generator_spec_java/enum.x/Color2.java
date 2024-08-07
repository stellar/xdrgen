// Automatically generated by xdrgen
// DO NOT EDIT or your changes may be overwritten

package MyXDR;

import java.io.IOException;

import org.stellar.sdk.Base64Factory;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;

/**
 * Color2's original definition in the XDR file is:
 * <pre>
 * enum Color2 {
 *     RED2=RED,  
 *     GREEN2=1,  
 *     BLUE2=2  
 * };
 * </pre>
 */
public enum Color2 implements XdrElement {
  RED2(0),
  GREEN2(1),
  BLUE2(2);

  private final int value;

  Color2(int value) {
      this.value = value;
  }

  public int getValue() {
      return value;
  }

  public static Color2 decode(XdrDataInputStream stream) throws IOException {
    int value = stream.readInt();
    switch (value) {
      case 0: return RED2;
      case 1: return GREEN2;
      case 2: return BLUE2;
      default:
        throw new IllegalArgumentException("Unknown enum value: " + value);
    }
  }

  public void encode(XdrDataOutputStream stream) throws IOException {
    stream.writeInt(value);
  }
  public static Color2 fromXdrBase64(String xdr) throws IOException {
    byte[] bytes = Base64Factory.getInstance().decode(xdr);
    return fromXdrByteArray(bytes);
  }

  public static Color2 fromXdrByteArray(byte[] xdr) throws IOException {
    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(xdr);
    XdrDataInputStream xdrDataInputStream = new XdrDataInputStream(byteArrayInputStream);
    return decode(xdrDataInputStream);
  }
}
