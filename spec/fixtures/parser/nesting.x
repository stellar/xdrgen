union MyUnion switch (UnionKey type)
{
    case ONE:
        struct {
            int someInt;
        } one;

    case TWO:
        struct {
            int someInt;
            Foo foo;
        } two;

    case OFFER:
        void;
};

struct MyStruct
{
    union switch (int v)
    {
    case 0:
        void;
    }
    ext;
};
