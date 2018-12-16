typedef int Error;
typedef int Multi;

enum UnionKey {
  ERROR,
  MULTI
};

union MyUnion switch (UnionKey type)
{
    case ERROR:
        Error error;
    case MULTI:
        Multi things<>;


};

union IntUnion switch (int type)
{
    case 0:
        Error error;
    case 1:
        Multi things<>;

};

typedef IntUnion IntUnion2;

union VoidDefaultUnion switch (int type)
{
    case 0:
        int anInt;
    default:
        void;
};

union SomeDefaultUnion switch (int type)
{
    case 0:
        int anInt;
    default:
        string str<64>;
};

union TypedIntDiscriminatedUnion switch (Error type) {
    case 0:
        void;
    default:
        string str<64>;
};

