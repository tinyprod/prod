#ifndef PRINTF_H
#define PRINTF_H

extern int printf(const char * NTS __fmt, ...) __attribute__((C));
#define platform_printf printf

#endif
