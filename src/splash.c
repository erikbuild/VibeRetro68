#include "splash.h"

#include <Quickdraw.h>
#include <Windows.h>
#include <Events.h>
#include <ToolUtils.h>

void ShowSplash(short windID, void (*draw)(WindowPtr))
{
    WindowPtr w;
    GrafPtr savedPort;
    EventRecord ev;
    Boolean done = false;

    InitCursor();
    w = GetNewWindow(windID, NULL, (WindowPtr)-1L);
    if (w == NULL) return;

    GetPort(&savedPort);
    SetPort(w);
    ShowWindow(w);
    draw(w);

    while (!done) {
        if (WaitNextEvent(everyEvent, &ev, 6, NULL)) {
            switch (ev.what) {
                case mouseDown:
                case keyDown:
                case autoKey:
                    done = true;
                    break;
                case updateEvt: {
                    WindowPtr uw = (WindowPtr)ev.message;
                    SetPort(uw);
                    BeginUpdate(uw);
                    if (uw == w) draw(uw);
                    EndUpdate(uw);
                    break;
                }
            }
        }
    }

    DisposeWindow(w);
    SetPort(savedPort);
}
