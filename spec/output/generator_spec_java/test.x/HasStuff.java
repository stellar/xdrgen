// Automatically generated by xdrgen
// DO NOT EDIT or your changes may be overwritten

package MyXDR;


import java.io.IOException;

import com.google.common.base.Objects;

// === xdr source ============================================================

//  struct HasStuff
//  {
//    LotsOfMyStructs data;
//  };

//  ===========================================================================
public class HasStuff implements XdrElement {
  public HasStuff () {}
  private LotsOfMyStructs data;
  public LotsOfMyStructs getData() {
    return this.data;
  }
  public void setData(LotsOfMyStructs value) {
    this.data = value;
  }
  public static void encode(XdrDataOutputStream stream, HasStuff encodedHasStuff) throws IOException{
    LotsOfMyStructs.encode(stream, encodedHasStuff.data);
  }
  public void encode(XdrDataOutputStream stream) throws IOException {
    encode(stream, this);
  }
  public static HasStuff decode(XdrDataInputStream stream) throws IOException {
    HasStuff decodedHasStuff = new HasStuff();
    decodedHasStuff.data = LotsOfMyStructs.decode(stream);
    return decodedHasStuff;
  }
  @Override
  public int hashCode() {
    return Objects.hashCode(this.data);
  }
  @Override
  public boolean equals(Object object) {
    if (!(object instanceof HasStuff)) {
      return false;
    }

    HasStuff other = (HasStuff) object;
    return Objects.equal(this.data, other.data);
  }

  public static final class Builder {
    private LotsOfMyStructs data;

    public Builder data(LotsOfMyStructs data) {
      this.data = data;
      return this;
    }

    public HasStuff build() {
      HasStuff val = new HasStuff();
      val.setData(data);
      return val;
    }
  }
}
