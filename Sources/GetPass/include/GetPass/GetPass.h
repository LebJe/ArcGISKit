//
//  GetPass.h
//  
//
//  Created by Jeff Lebrun on 12/24/20.
//

#ifndef GetPass_h
#define GetPass_h
#include <termios.h>
#include <sys/types.h>
#include <stdio.h>


/// From https://stackoverflow.com/a/32421674/12570844 .
/// read a string from fp into pw masking keypress with mask char. getpasswd will read upto sz - 1 chars into pw, null-terminating the resulting string. On success, the number of characters in pw are returned, -1 otherwise.
///
/// @param pw pw
/// @param sz sz
/// @param mask mask char
/// @param fp fp
ssize_t getPasswordComplex(char **pw, size_t sz, int mask, FILE *fp);

char * getPasswordSimple();
void echoOn();
void echoOff();
#endif /* GetPass_h */
