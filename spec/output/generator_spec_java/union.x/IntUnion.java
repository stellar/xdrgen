// Automatically generated by xdrgen
// DO NOT EDIT or your changes may be overwritten

package MyXDR;

import java.io.IOException;

import static MyXDR.Constants.*;
import com.google.common.base.Objects;
import java.util.Arrays;

// === xdr source ============================================================

//  union IntUnion switch (int type)
//  {
//      case 0:
//          Error error;
//      case 1:
//          Multi things<>;
//  
//  };

//  ===========================================================================
public class IntUnion implements XdrElement {
  public IntUnion () {}
  Integer type;
  public Integer getDiscriminant() {
    return this.type;
  }
  public void setDiscriminant(Integer value) {
    this.type = value;
  }
  private Error error;
  public Error getError() {
    return this.error;
  }
  public void setError(Error value) {
    this.error = value;
  }
  private Multi[] things;
  public Multi[] getThings() {
    return this.things;
  }
  public void setThings(Multi[] value) {
    this.things = value;
  }

  public static final class Builder {
    private Integer discriminant;
    private Error error;
    private Multi[] things;

    public Builder discriminant(Integer discriminant) {
      this.discriminant = discriminant;
      return this;
    }

    public Builder error(Error error) {
      this.error = error;
      return this;
    }

    public Builder things(Multi[] things) {
      this.things = things;
      return this;
    }

    public IntUnion build() {
      IntUnion val = new IntUnion();
      val.setDiscriminant(discriminant);
      val.setError(this.error);
      val.setThings(this.things);
      return val;
    }
  }

  public static void encode(XdrDataOutputStream stream, IntUnion encodedIntUnion) throws IOException {
  //Xdrgen::AST::Typespecs::Int
  //Integer
  stream.writeInt(encodedIntUnion.getDiscriminant().intValue());
  switch (encodedIntUnion.getDiscriminant()) {
  case 0:
  Error.encode(stream, encodedIntUnion.error);
  break;
  case 1:
  int thingssize = encodedIntUnion.getThings().length;
  stream.writeInt(thingssize);
  for (int i = 0; i < thingssize; i++) {
    Multi.encode(stream, encodedIntUnion.things[i]);
  }
  break;
  }
  }
  public void encode(XdrDataOutputStream stream) throws IOException {
    encode(stream, this);
  }
  public static IntUnion decode(XdrDataInputStream stream) throws IOException {
  IntUnion decodedIntUnion = new IntUnion();
  Integer discriminant = stream.readInt();
  decodedIntUnion.setDiscriminant(discriminant);
  switch (decodedIntUnion.getDiscriminant()) {
  case 0:
  decodedIntUnion.error = Error.decode(stream);
  break;
  case 1:
  int thingssize = stream.readInt();
  decodedIntUnion.things = new Multi[thingssize];
  for (int i = 0; i < thingssize; i++) {
    decodedIntUnion.things[i] = Multi.decode(stream);
  }
  break;
  }
    return decodedIntUnion;
  }
  @Override
  public int hashCode() {
    return Objects.hashCode(this.error, Arrays.hashCode(this.things), this.type);
  }
  @Override
  public boolean equals(Object object) {
    if (!(object instanceof IntUnion)) {
      return false;
    }

    IntUnion other = (IntUnion) object;
    return Objects.equal(this.error, other.error) && Arrays.equals(this.things, other.things) && Objects.equal(this.type, other.type);
  }
}
