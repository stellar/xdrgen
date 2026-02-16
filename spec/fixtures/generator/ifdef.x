// Test fixture for #ifdef support

// A simple constant (no ifdef)
const BASE_VALUE = 1;

// An enum with conditional members
enum MyEnum {
    MEMBER_A = 0,
    MEMBER_B = 1,
#ifdef FEATURE_A
    MEMBER_C = 2,
#endif
    MEMBER_D = 3
};

// A struct with conditional fields
struct MyStruct {
    int field1;
    MyEnum field2;
#ifdef FEATURE_A
    unsigned int field3;
#endif
};

// An entirely conditional type
#ifdef FEATURE_A
struct ConditionalStruct {
    int data;
};
#endif

// A type with #else
#ifdef FEATURE_A
struct VariantStruct {
    int newField;
};
#else
struct VariantStruct {
    unsigned int oldField;
};
#endif

// A union with conditional arms
enum UnionType {
    UNION_A = 0,
    UNION_B = 1,
#ifdef FEATURE_A
    UNION_C = 2,
#endif
    UNION_D = 3
};

union MyUnion switch (UnionType type) {
    case UNION_A:
        int armA;
    case UNION_B:
        unsigned int armB;
#ifdef FEATURE_A
    case UNION_C:
        unsigned hyper armC;
#endif
    case UNION_D:
        void;
};

// A struct with a nested union that has an ifdef'd arm
struct ContainerStruct {
    int baseField;
    union switch (UnionType type) {
        case UNION_A: int dataA;
        case UNION_B: unsigned int dataB;
#ifdef FEATURE_A
        case UNION_C: unsigned hyper dataC;
#endif
        case UNION_D: void;
    } body;
};
