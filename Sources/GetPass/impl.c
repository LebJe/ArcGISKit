//
//  impl.c
//  
//
//  Created by Jeff Lebrun on 12/24/20.
//


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>

#define MAXPW 200

struct termios tp, save;

// From https://stackoverflow.com/a/32421674/12570844 .
//
/* read a string from fp into pw masking keypress with mask char.
 getPasswordComplex will read up to sz - 1 chars into pw, null-terminating
 the resulting string. On success, the number of characters in
 pw are returned, -1 otherwise.
 */
ssize_t getPasswordComplex(char **pw, size_t sz, int mask, FILE *fp) {
	if (!pw || !sz || !fp) return -1;       /* validate input   */
#ifdef MAXPW
	if (sz > MAXPW) sz = MAXPW;
#endif

	if (*pw == NULL) {              /* reallocate if no address */
		void *tmp = realloc(*pw, sz * sizeof **pw);
		if (!tmp)
			return -1;
		memset (tmp, 0, sz);    /* initialize memory to 0   */
		*pw =  (char*) tmp;
	}

	size_t idx = 0;         /* index, number of chars in read   */
	int c = 0;

	struct termios old_kbd_mode;    /* orig keyboard settings   */
	struct termios new_kbd_mode;

	if (tcgetattr(0, &old_kbd_mode)) { /* save orig settings   */
		fprintf(stderr, "%s() error: tcgetattr failed.\n", __func__);
		return -1;
	}   /* copy old to new */
	memcpy (&new_kbd_mode, &old_kbd_mode, sizeof(struct termios));

	new_kbd_mode.c_lflag &= ~(ICANON | ECHO);  /* new kbd flags */
	new_kbd_mode.c_cc[VTIME] = 0;
	new_kbd_mode.c_cc[VMIN] = 1;
	if (tcsetattr(0, TCSANOW, &new_kbd_mode)) {
		fprintf(stderr, "%s() error: tcsetattr failed.\n", __func__);
		return -1;
	}

	/* read chars from fp, mask if valid char specified */
	while (((c = fgetc(fp)) != '\n' && c != EOF && idx < sz - 1) ||
		   (idx == sz - 1 && c == 127))
	{
		if (c != 127) {
			if (31 < mask && mask < 127)    /* valid ascii char */
				fputc(mask, stdout);
			(*pw)[idx++] = c;
		}
		else if (idx > 0) {         /* handle backspace (del)   */
			if (31 < mask && mask < 127) {
				fputc(0x8, stdout);
				fputc(' ', stdout);
				fputc(0x8, stdout);
			}
			(*pw)[--idx] = 0;
		}
	}
	(*pw)[idx] = 0; /* null-terminate   */

	/* reset original keyboard  */
	if (tcsetattr(0, TCSANOW, &old_kbd_mode)) {
		fprintf(stderr, "%s() error: tcsetattr failed.\n", __func__);
		return -1;
	}

	if (idx == sz - 1 && c != '\n') /* warn if pw truncated */
		fprintf(stderr, " (%s() warning: truncated at %zu chars.)\n",
				 __func__, sz - 1);

	return idx; /* number of chars in passwd */
}


/// Get a password from the user.
char * getPasswordSimple() {
	char pw[MAXPW] = {0};
	char *p = pw;
	FILE *fp = stdin;
	printf("%zd", getPasswordComplex(&p, MAXPW, '*', fp));
	return p;
}

void echoOff() {
	tcgetattr( STDIN_FILENO, &tp);              /* get existing terminal properties */
	save = tp;                                  /* save existing terminal properties */

	tp.c_lflag &= ~ECHO;                        /* only cause terminal echo off */

	tcsetattr( STDIN_FILENO, TCSAFLUSH, &tp );  /* set terminal settings */
}

void echoOn() {
	tcsetattr( STDIN_FILENO, TCSAFLUSH, &save );  /* set terminal settings */
}
