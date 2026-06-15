#include "about.h"

#include "splash.h"

#include <Quickdraw.h>
#include <Fonts.h>
#include <Windows.h>
#include <TextEdit.h>

#define kAboutWindID 129

static void DrawAboutContent(WindowPtr w)
{
    Rect r = w->portRect;
    EraseRect(&r);

    TextFont(systemFont);
    TextSize(12);
    TextFace(bold);
    MoveTo(24, 32);
    DrawString("\pMyApp");

    /* APP_VERSION_STR comes from CMake (see CMakeLists.txt / VERSION). */
    TextFace(0);
    {
        Str255 line;
        const char *src = "Version " APP_VERSION_STR;
        short n = 0;
        while (src[n] && n < 255) { line[n + 1] = src[n]; n++; }
        line[0] = n;
        MoveTo(24, 54);
        DrawString(line);
    }

    TextFace(italic);
    MoveTo(24, 90);
    DrawString("\p(click anywhere to dismiss)");
    TextFace(0);
}

void DoAbout(void) { ShowSplash(kAboutWindID, DrawAboutContent); }
