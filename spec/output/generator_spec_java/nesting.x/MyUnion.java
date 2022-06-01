// Automatically generated by xdrgen
// DO NOT EDIT or your changes may be overwritten

package MyXDR;


import java.io.IOException;

import com.google.common.base.Objects;

// === xdr source ============================================================

//  union MyUnion switch (UnionKey type)
//  {
//      case ONE:
//          struct {
//              int someInt;
//          } one;
//  
//      case TWO:
//          struct {
//              int someInt;
//              Foo foo;
//          } two;
//  
//      case OFFER:
//          void;
//  };

//  ===========================================================================
public class MyUnion implements XdrElement {
  public MyUnion () {}
  UnionKey type;
  public UnionKey getDiscriminant() {
    return this.type;
  }
  public void setDiscriminant(UnionKey value) {
    this.type = value;
  }
  private MyUnionOne one;
  public MyUnionOne getOne() {
    return this.one;
  }
  public void setOne(MyUnionOne value) {
    this.one = value;
  }
  private MyUnionTwo two;
  public MyUnionTwo getTwo() {
    return this.two;
  }
  public void setTwo(MyUnionTwo value) {
    this.two = value;
  }

  public static final class Builder {
    private UnionKey discriminant;
    private MyUnionOne one;
    private MyUnionTwo two;

    public Builder discriminant(UnionKey discriminant) {
      this.discriminant = discriminant;
      return this;
    }

    public Builder one(MyUnionOne one) {
      this.one = one;
      return this;
    }

    public Builder two(MyUnionTwo two) {
      this.two = two;
      return this;
    }

    public MyUnion build() {
      MyUnion val = new MyUnion();
      val.setDiscriminant(discriminant);
      val.setOne(one);
      val.setTwo(two);
      return val;
    }
  }

  public static void encode(XdrDataOutputStream stream, MyUnion encodedMyUnion) throws IOException {
  //Xdrgen::AST::Identifier
  //UnionKey
  stream.writeInt(encodedMyUnion.getDiscriminant().getValue());
  switch (encodedMyUnion.getDiscriminant()) {
  case ONE:
  MyUnionOne.encode(stream, encodedMyUnion.one);
  break;
  case TWO:
  MyUnionTwo.encode(stream, encodedMyUnion.two);
  break;
  case OFFER:
  break;
  }
  }
  public void encode(XdrDataOutputStream stream) throws IOException {
    encode(stream, this);
  }
  public static MyUnion decode(XdrDataInputStream stream) throws IOException {
  MyUnion decodedMyUnion = new MyUnion();
  UnionKey discriminant = UnionKey.decode(stream);
  decodedMyUnion.setDiscriminant(discriminant);
  switch (decodedMyUnion.getDiscriminant()) {
  case ONE:
  decodedMyUnion.one = MyUnionOne.decode(stream);
  break;
  case TWO:
  decodedMyUnion.two = MyUnionTwo.decode(stream);
  break;
  case OFFER:
  break;
  }
    return decodedMyUnion;
  }
  @Override
  public int hashCode() {
    return Objects.hashCode(this.one, this.two, this.type);
  }
  @Override
  public boolean equals(Object object) {
    if (!(object instanceof MyUnion)) {
      return false;
    }

    MyUnion other = (MyUnion) object;
    return Objects.equal(this.one, other.one) && Objects.equal(this.two, other.two) && Objects.equal(this.type, other.type);
  }

  public static class MyUnionOne {
    public MyUnionOne () {}
    private Integer someInt;
    public Integer getSomeInt() {
      return this.someInt;
    }
    public void setSomeInt(Integer value) {
      this.someInt = value;
    }
    public static void encode(XdrDataOutputStream stream, MyUnionOne encodedMyUnionOne) throws IOException{
      stream.writeInt(encodedMyUnionOne.someInt);
    }
    public void encode(XdrDataOutputStream stream) throws IOException {
      encode(stream, this);
    }
    public static MyUnionOne decode(XdrDataInputStream stream) throws IOException {
      MyUnionOne decodedMyUnionOne = new MyUnionOne();
      decodedMyUnionOne.someInt = stream.readInt();
      return decodedMyUnionOne;
    }
    @Override
    public int hashCode() {
      return Objects.hashCode(this.someInt);
    }
    @Override
    public boolean equals(Object object) {
      if (!(object instanceof MyUnionOne)) {
        return false;
      }

      MyUnionOne other = (MyUnionOne) object;
      return Objects.equal(this.someInt, other.someInt);
    }

    public static final class Builder {
      private Integer someInt;

      public Builder someInt(Integer someInt) {
        this.someInt = someInt;
        return this;
      }

      public MyUnionOne build() {
        MyUnionOne val = new MyUnionOne();
        val.setSomeInt(someInt);
        return val;
      }
    }

  }
  public static class MyUnionTwo {
    public MyUnionTwo () {}
    private Integer someInt;
    public Integer getSomeInt() {
      return this.someInt;
    }
    public void setSomeInt(Integer value) {
      this.someInt = value;
    }
    private Foo foo;
    public Foo getFoo() {
      return this.foo;
    }
    public void setFoo(Foo value) {
      this.foo = value;
    }
    public static void encode(XdrDataOutputStream stream, MyUnionTwo encodedMyUnionTwo) throws IOException{
      stream.writeInt(encodedMyUnionTwo.someInt);
      Foo.encode(stream, encodedMyUnionTwo.foo);
    }
    public void encode(XdrDataOutputStream stream) throws IOException {
      encode(stream, this);
    }
    public static MyUnionTwo decode(XdrDataInputStream stream) throws IOException {
      MyUnionTwo decodedMyUnionTwo = new MyUnionTwo();
      decodedMyUnionTwo.someInt = stream.readInt();
      decodedMyUnionTwo.foo = Foo.decode(stream);
      return decodedMyUnionTwo;
    }
    @Override
    public int hashCode() {
      return Objects.hashCode(this.someInt, this.foo);
    }
    @Override
    public boolean equals(Object object) {
      if (!(object instanceof MyUnionTwo)) {
        return false;
      }

      MyUnionTwo other = (MyUnionTwo) object;
      return Objects.equal(this.someInt, other.someInt) && Objects.equal(this.foo, other.foo);
    }

    public static final class Builder {
      private Integer someInt;
      private Foo foo;

      public Builder someInt(Integer someInt) {
        this.someInt = someInt;
        return this;
      }

      public Builder foo(Foo foo) {
        this.foo = foo;
        return this;
      }

      public MyUnionTwo build() {
        MyUnionTwo val = new MyUnionTwo();
        val.setSomeInt(someInt);
        val.setFoo(foo);
        return val;
      }
    }

  }
}
