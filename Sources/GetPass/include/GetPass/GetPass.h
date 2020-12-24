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

ssize_t
my_getpass (char **lineptr, size_t *n, FILE *stream);

#endif /* GetPass_h */
