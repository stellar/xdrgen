
union MyUnion switch (UnionKey type)
{
    case ERROR:
        Error error;
    case MULTI:
        Multi things<>;


};

union SomeVeryLongUnionNamePushingSwitchParamToNewLine switch (
	SomeLongUnionKeyType type)
{
    case ERROR:
        Error error;
    case MULTI:
        Multi things<>;
    default:
		void;
};
