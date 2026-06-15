#include "Windows.r"
#include "Menus.r"
#include "Processes.r"

/* 'vers' resource generated from /VERSION by CMake's configure_file. */
#include "version.r"

resource 'WIND' (128, "Hello") {
    { 60, 60, 220, 380 },
    documentProc,
    visible,
    goAway,
    0x0,
    "Hello, world!",
    centerMainScreen
};

/* About window. dBoxProc = plain bordered modal-style window with no
   title bar or close box; we dismiss it on any click or keystroke. */
resource 'WIND' (129, "About") {
    { 90, 80, 200, 380 },
    dBoxProc,
    invisible,
    noGoAway,
    0x0,
    "",
    centerMainScreen
};

resource 'MBAR' (128) {
    { 128, 129 }
};

resource 'MENU' (128, "Apple") {
    128, textMenuProc, allEnabled, enabled,
    apple,
    {
        "About MyApp...",       noIcon, noKey,  noMark, plain;
        "-",                    noIcon, noKey,  noMark, plain;
    }
};

resource 'MENU' (129, "File") {
    129, textMenuProc, allEnabled, enabled,
    "File",
    {
        "Quit",                 noIcon, "Q",    noMark, plain;
    }
};

resource 'SIZE' (-1) {
    reserved,
    acceptSuspendResumeEvents,
    reserved,
    canBackground,
    doesActivateOnFGSwitch,
    backgroundAndForeground,
    dontGetFrontClicks,
    ignoreChildDiedEvents,
    is32BitCompatible,
    notHighLevelEventAware,
    onlyLocalHLEvents,
    notStationeryAware,
    dontUseTextEditServices,
    reserved,
    reserved,
    reserved,
    256 * 1024,
    128 * 1024
};
