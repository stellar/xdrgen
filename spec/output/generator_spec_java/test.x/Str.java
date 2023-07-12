// Automatically generated by xdrgen
// DO NOT EDIT or your changes may be overwritten

package MyXDR;

import java.io.IOException;

import static MyXDR.Constants.*;
import com.google.common.base.Objects;

// === xdr source ============================================================

//  typedef string str<64>;

//  ===========================================================================
public class Str implements XdrElement {
  private XdrString str;

  public Str() {}

  public Str(XdrString str) {
    this.str = str;
  }

  public XdrString getStr() {
    return this.str;
  }

  public void setStr(XdrString value) {
    this.str = value;
  }

  public static void encode(XdrDataOutputStream stream, Str  encodedStr) throws IOException {
    encodedStr.str.encode(stream);
  }

  public void encode(XdrDataOutputStream stream) throws IOException {
    encode(stream, this);
  }
  public static Str decode(XdrDataInputStream stream) throws IOException {
    Str decodedStr = new Str();
    decodedStr.str = XdrString.decode(stream, 64);
    return decodedStr;
  }

  @Override
  public int hashCode() {
    return Objects.hashCode(this.str);
  }

  @Override
  public boolean equals(Object object) {
    if (!(object instanceof Str)) {
      return false;
    }

    Str other = (Str) object;
    return Objects.equal(this.str, other.str);
  }
}
