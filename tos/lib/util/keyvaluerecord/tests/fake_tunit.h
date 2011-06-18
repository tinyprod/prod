#ifndef _fake_tunit_h
#define _fake_tunit_h

#define assertEqual_int(_v1,_v2) { \
  int v1 = _v1; \
  int v2 = _v2; \
  if (v1 == v2) { \
    printf("pass: " #_v1 " == " #_v2 " [%d]\n", v1); \
  } else { \
    printf("FAIL: " #_v1 " [%d] != " #_v2 " [%d]\n", v1, v2); \
  } \
}

#define assertTrue(_v) { \
  bool v = _v; \
  if (v) { \
    printf("pass: " #_v "\n"); \
  } else { \
    printf("FAIL: " #_v "\n"); \
  } \
}

#define assertEqual(_v1, _v2) assertEqual_int(_v1, _v2)

#endif /* fake_tunit_h */
