//
//  impl.c
//  
//
//  Created by Jeff Lebrun on 12/24/20.
//

#include <stdio.h>
#include <termios.h>
#include <unistd.h>

struct termios tp, save;

void echoOff() {
	tcgetattr( STDIN_FILENO, &tp);              /* get existing terminal properties */
	save = tp;                                  /* save existing terminal properties */

	tp.c_lflag &= ~ECHO;                        /* only cause terminal echo off */

	tcsetattr( STDIN_FILENO, TCSAFLUSH, &tp );  /* set terminal settings */
}

void echoOn() {
	tcsetattr( STDIN_FILENO, TCSAFLUSH, &save );  /* set terminal settings */
}
