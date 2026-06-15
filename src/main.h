#ifndef MYAPP_MAIN_H
#define MYAPP_MAIN_H

#include <Quickdraw.h>
#include <Events.h>

#define kWindowID 128
#define kMenuBarID 128
#define kAppleMenuID 128
#define kFileMenuID 129
#define kAboutItem 1
#define kQuitItem 1

static void DrawHello(WindowPtr w);
static void HandleMenu(long menuChoice);
static void HandleMouse(EventRecord *event);
static void HandleKey(EventRecord *event);

#endif