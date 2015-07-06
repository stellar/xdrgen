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
