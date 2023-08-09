// Automatically generated by xdrgen
// DO NOT EDIT or your changes may be overwritten

package MyXDR;

import java.io.IOException;

import static MyXDR.Constants.*;
import com.google.common.base.Objects;

// === xdr source ============================================================

//  typedef int Error;

//  ===========================================================================
public class Error implements XdrElement {
  private Integer Error;

  public Error() {}

  public Error(Integer Error) {
    this.Error = Error;
  }

  public Integer getError() {
    return this.Error;
  }

  public void setError(Integer value) {
    this.Error = value;
  }

  public static void encode(XdrDataOutputStream stream, Error  encodedError) throws IOException {
    stream.writeInt(encodedError.Error);
  }

  public void encode(XdrDataOutputStream stream) throws IOException {
    encode(stream, this);
  }
  public static Error decode(XdrDataInputStream stream) throws IOException {
    Error decodedError = new Error();
    decodedError.Error = stream.readInt();
    return decodedError;
  }

  @Override
  public int hashCode() {
    return Objects.hashCode(this.Error);
  }

  @Override
  public boolean equals(Object object) {
    if (!(object instanceof Error)) {
      return false;
    }

    Error other = (Error) object;
    return Objects.equal(this.Error, other.Error);
  }
}
