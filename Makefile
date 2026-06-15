# VibeRetro68 task runner. Wraps the scripts/ and cmake invocations
# behind short mnemonics. Run `make help` for the full list.

.PHONY: help setup fetch-deps build-retro68 doctor configure build \
        basiliskii minivmac clean

# Path to the Retro68 toolchain file produced by `make build-retro68`.
RETRO68_TOOLCHAIN := deps/retro68/Retro68-build/toolchain/m68k-apple-macos/cmake/retro68.toolchain.cmake

help:
	@echo "VibeRetro68 targets:"
	@echo "  make setup          One-shot env setup (brew + fetch-deps + build-retro68 + doctor)"
	@echo "  make fetch-deps     Download Retro68 source, emulators, ROMs into deps/"
	@echo "  make build-retro68  Build the Retro68 cross-compiler (~30-60 min, one-time)"
	@echo "  make doctor         Diagnose missing pieces of deps/"
	@echo "  make build          Configure (first time) + compile the project"
	@echo "  make basiliskii     Build and run in Basilisk II"
	@echo "  make minivmac       Build and (re)launch Mini vMac"
	@echo "  make clean          Remove build/"

setup:        ; @./scripts/setup.sh
fetch-deps:   ; @./scripts/fetch-deps.sh
build-retro68:; @./scripts/build-retro68.sh
doctor:       ; @./scripts/doctor.sh

configure:
	@cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=$(RETRO68_TOOLCHAIN)

# Auto-configure on the first build, then compile. After the cache
# exists this short-circuits, so warm builds skip the cmake reconfigure.
build:
	@[ -f build/CMakeCache.txt ] || $(MAKE) --no-print-directory configure
	@cmake --build build

basiliskii: build ; @./scripts/run-basiliskii.sh
minivmac:   build ; @./scripts/run-minivmac.sh

clean:
	@rm -rf build/
	@echo "Removed build/"
