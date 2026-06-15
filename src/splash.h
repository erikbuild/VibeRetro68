#ifndef MYAPP_SPLASH_H
#define MYAPP_SPLASH_H

#include <Windows.h>

/* Show a plain-bordered modal "splash" window. Blocks until any mouse
   or keystroke dismisses it. The window is created from a 'WIND'
   resource (typically dBoxProc, invisible, noGoAway); the `draw`
   callback paints its contents and gets re-invoked on every update
   event for that window. Other windows' updates are still serviced
   so they keep painting if the splash moves or uncovers them. */
void ShowSplash(short windID, void (*draw)(WindowPtr));

#endif
