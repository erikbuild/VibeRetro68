cmake_minimum_required(VERSION 3.13)
project(MyApp C)

# ---- Versioning ----------------------------------------------------
#
# Single source of truth is /VERSION. We parse it into MAJOR/MINOR/PATCH
# so we can bake the BCD bytes the 'vers' resource needs, then emit:
#   - ${CMAKE_BINARY_DIR}/version.r  (included by resources/${name}.r)
#   - APP_VERSION_STR compile-time macro  (usable from C/C++)
# Bump VERSION and rebuild; both artifacts follow.

file(STRINGS "${CMAKE_SOURCE_DIR}/VERSION" APP_VERSION LIMIT_COUNT 1)
if(NOT APP_VERSION MATCHES "^([0-9])\\.([0-9])\\.([0-9])$")
    message(FATAL_ERROR
        "VERSION must be MAJOR.MINOR.PATCH with single-digit components "
        "(required by BCD packing in the 'vers' resource); got: '${APP_VERSION}'")
endif()
set(APP_VER_MAJOR ${CMAKE_MATCH_1})
set(APP_VER_MINOR ${CMAKE_MATCH_2})
set(APP_VER_PATCH ${CMAKE_MATCH_3})

configure_file(resources/version.r.in ${CMAKE_BINARY_DIR}/version.r @ONLY)
list(APPEND REZ_INCLUDE_PATH ${CMAKE_BINARY_DIR})
add_compile_definitions(APP_VERSION_STR="${APP_VERSION}")
message(STATUS "${PROJECT_NAME} version: ${APP_VERSION}")

# ---- App build -----------------------------------------------------

add_application(${PROJECT_NAME}
    src/main.c
    src/about.c
    src/splash.c
    resources/${PROJECT_NAME}.r
)

# ---- Post-build artifacts ------------------------------------------
#
# Each step is independent. Together they produce:
#   ${name}       — renamed APPL, taggable by SetFile for ExtFS
#   ${name}.bin   — MacBinary container (transfer over any channel)
#   ${name}.dsk   — raw HFS disk image (Mini vMac, Basilisk II)
#   ${name}.img   — Disk Copy 4.2 wrapped (real-hardware mounters)
#   ${name}.hqx   — BinHex 4.0 (email/web-safe; needs binhex+macbinary)

find_program(SETFILE_EXECUTABLE SetFile)
find_program(BINHEX_EXECUTABLE binhex)
find_program(MACBINARY_EXECUTABLE macbinary)

set(_target ${PROJECT_NAME}_APPL)
set(_outdir ${CMAKE_BINARY_DIR})
set(_name   ${PROJECT_NAME})

# 1. Drop the .APPL extension. add_application produces ${name}.APPL on
#    the data-fork side, but real Mac apps have no extension. The
#    %${name}.ad AppleDouble sidecar already pairs by basename, so the
#    pairing stays intact after the rename. The empty ${name}.ad is
#    redundant once the sidecar is in place; discard it.
add_custom_command(TARGET ${_target} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E rename ${_outdir}/${_name}.APPL ${_outdir}/${_name}
    COMMAND ${CMAKE_COMMAND} -E remove -f ${_outdir}/${_name}.ad
    COMMENT "Renaming ${_name}.APPL -> ${_name}"
    VERBATIM)

# 2. Patch 'has bundle' Finder bit into the AppleDouble sidecar so
#    System 6/7 Finders pick up our BNDL/ICN# resources on a desktop
#    rebuild. We do NOT touch the .bin -- Apple's macbinary and Basilisk
#    II's ExtFS strip byte 73 from MacBinary headers, so the bit never
#    reaches the decoded file and the rewritten CRC breaks the container.
#    Patching the sidecar is the safe channel since ExtFS reads it
#    directly as host-side metadata.
add_custom_command(TARGET ${_target} POST_BUILD
    COMMAND python3 ${CMAKE_SOURCE_DIR}/scripts/set-bundle-bit.py
            ${_outdir}/%${_name}.ad
    COMMENT "Patching 'has bundle' bit on AppleDouble sidecar"
    VERBATIM)

# 3. Wrap the raw .dsk as Disk Copy 4.2 (.img). Real-Mac disk mounters
#    (Disk Copy 4.2, MountImage, ShrinkWrap) need this header. Mini vMac
#    and Basilisk II accept either, so the raw .dsk stays alongside.
add_custom_command(TARGET ${_target} POST_BUILD
    COMMAND python3 ${CMAKE_SOURCE_DIR}/scripts/raw-to-dc42.py
            ${_outdir}/${_name}.dsk
            ${_outdir}/${_name}.img
            ${_name}
    COMMENT "Wrapping .dsk as Disk Copy 4.2 (.img)"
    VERBATIM)

# 4. macOS-only: set Finder type/creator on host-side artifacts via
#    SetFile so Basilisk II's ExtFS exposes them with the right icons.
#    The .bin itself is left bare so ExtFS can unpack its MacBinary
#    container cleanly. Skipped silently on Linux build hosts.
if(SETFILE_EXECUTABLE)
    add_custom_command(TARGET ${_target} POST_BUILD
        COMMAND ${SETFILE_EXECUTABLE} -t APPL -a B ${_outdir}/${_name}
        COMMAND ${SETFILE_EXECUTABLE} -t dCp4 -c dCpy ${_outdir}/${_name}.img
        COMMENT "Tagging Finder type/creator on host-side artifacts"
        VERBATIM)
endif()

# 5. Encode .hqx (BinHex 4.0): text-safe, self-describing, accepted by
#    every classic-Mac decompressor. Survives email, web, and any
#    transport that strips type/creator or resource forks.
if(BINHEX_EXECUTABLE AND MACBINARY_EXECUTABLE)
    add_custom_command(TARGET ${_target} POST_BUILD
        COMMAND ${CMAKE_SOURCE_DIR}/scripts/make-hqx.sh
                ${_outdir}/${_name}.bin
                ${_outdir}/${_name}.hqx
        COMMENT "Encoding ${_name}.hqx (BinHex 4.0)"
        VERBATIM)
endif()
