// Automatically generated by xdrgen
// DO NOT EDIT or your changes may be overwritten

package MyXDR;

import java.io.IOException;

import static MyXDR.Constants.*;
import com.google.common.base.Objects;

// === xdr source ============================================================

//  typedef string str2<>;

//  ===========================================================================
public class Str2 implements XdrElement {
  private XdrString str2;

  public Str2() {}

  public Str2(XdrString str2) {
    this.str2 = str2;
  }

  public XdrString getStr2() {
    return this.str2;
  }

  public void setStr2(XdrString value) {
    this.str2 = value;
  }

  public static void encode(XdrDataOutputStream stream, Str2  encodedStr2) throws IOException {
    encodedStr2.str2.encode(stream);
  }

  public void encode(XdrDataOutputStream stream) throws IOException {
    encode(stream, this);
  }
  public static Str2 decode(XdrDataInputStream stream) throws IOException {
    Str2 decodedStr2 = new Str2();
    decodedStr2.str2 = XdrString.decode(stream, );
    return decodedStr2;
  }

  @Override
  public int hashCode() {
    return Objects.hashCode(this.str2);
  }

  @Override
  public boolean equals(Object object) {
    if (!(object instanceof Str2)) {
      return false;
    }

    Str2 other = (Str2) object;
    return Objects.equal(this.str2, other.str2);
  }
}
