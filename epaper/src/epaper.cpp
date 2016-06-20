//============================================================================
// Name        : epaper.cpp
// Author      : Robin Kirkman
// Version     :
// Copyright   : BSD
// Description : Hello World in C++, Ansi-style
//============================================================================

#include <stdio.h>
#include <unistd.h>
#include "epd.h"

#include <termios.h>

#define DWIDTH 800
#define DHEIGHT 600
#define CWIDTH 25
#define CHEIGHT 30


int main(int argc, const char **argv) {
	const char *tty_dev = (argc == 2 ? argv[1] : NULL);
	int tty_fd;
	if((tty_fd = epd_init(tty_dev)) < 0) {
		printf("Unable to open tty %s\n", tty_dev);
		return -1;
	}

	epd_clear();

	int x = 0, y = 0;

	int ll = 0;

	for(int c = fgetc(stdin); c != EOF; c = fgetc(stdin)) {
		if(c == '\n') {
			if(ll == 0 || (ll > 0 && x != 0)) {
				x = 0;
				y += CHEIGHT;
				if(y > DHEIGHT - CHEIGHT)
					goto done;
			}
			ll = 0;
		} else if(c != '\r') {
			ll++;
			if(c != ' ')
				epd_disp_char(c, x, y);
			x += CWIDTH;
			if(x > DWIDTH - CWIDTH) {
				x = 0;
				y += CHEIGHT;
			}
			if(y > DHEIGHT - CHEIGHT)
				goto done;
		}
	}
	done:
	epd_udpate();
	fsync(tty_fd);
	return 0;
}
