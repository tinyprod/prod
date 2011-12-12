#ifndef ASSERTUART_H
#define ASSERTUART_H

// preprocessor magic to get __LINE__ as a string, from
// http://www.decompile.com/cpp/faq/file_and_line_error_string.htm
#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)

// Long paths in __FILE__ file names may use excessive amounts
// of memory (either ROM or both ROM and RAM, depending on your compiler)
// so this define allows you to switch file names on and off.
#ifdef ASSERT_UART_EXCLUDE_FILE_NAME
#define SOURCE_LOCATION "line " TOSTRING(__LINE__)
#else
#define SOURCE_LOCATION __FILE__ ":" TOSTRING(__LINE__)
#endif

#define assert(condition, output) doAssert((condition), (output), #condition, #output, SOURCE_LOCATION)
#define assertNot(condition, output) doAssertNot((condition), (output), #condition " != FALSE", #output, SOURCE_LOCATION)
#define assertSuccess(err, output) doAssertSuccess((err), (output), #err " != SUCCESS", #output, SOURCE_LOCATION)
#define assertEquals(a, b, output) doAssertEquals((a), (b), (output), #a, #b, #output, SOURCE_LOCATION)

#endif
