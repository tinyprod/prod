#ifndef ASSERTREBOOT_H
#define ASSERTREBOOT_H

#define assert(condition, output) doAssert((condition), (output))
#define assertNot(condition, output) doAssertNot((condition), (output))
#define assertSuccess(error, output) doAssertSuccess((error), (output))
#define assertEquals(a, b, output) doAssertEquals((a), (b), (output))

#endif
