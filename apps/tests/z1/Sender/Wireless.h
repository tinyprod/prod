#ifndef WIRELESS_H
#define WIRELESS_H
 
typedef nx_struct wireless_msg {
  nx_uint16_t counter;
} wireless_msg_t;
 
enum {
  AM_WIRELESS_MSG = 23,
};
 
#endif