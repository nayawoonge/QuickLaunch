APP      = QuickLaunch
BUILD    = build
APP_PATH = $(BUILD)/$(APP).app

# `make app ARCHS="--arch arm64 --arch x86_64"` for a universal binary (needs Xcode).
ARCHS ?=
ifeq ($(strip $(ARCHS)),)
BIN_DIR = .build/release
else
BIN_DIR = .build/apple/Products/Release
endif

.PHONY: build app dmg install run clean

build:
	swift build -c release $(ARCHS)

app: build
	rm -rf $(APP_PATH)
	mkdir -p $(APP_PATH)/Contents/MacOS $(APP_PATH)/Contents/Resources
	cp $(BIN_DIR)/$(APP) $(APP_PATH)/Contents/MacOS/$(APP)
	@if [ -d $(BIN_DIR)/$(APP)_$(APP).bundle ]; then \
		cp -R $(BIN_DIR)/$(APP)_$(APP).bundle $(APP_PATH)/Contents/Resources/; \
	fi
	cp Support/Info.plist $(APP_PATH)/Contents/Info.plist
	cp Support/AppIcon.icns $(APP_PATH)/Contents/Resources/AppIcon.icns
	codesign --force --sign - $(APP_PATH)
	@echo "==> $(APP_PATH)"

# Drag-and-drop installer: QuickLaunch.app + an /Applications symlink.
dmg: app
	rm -rf $(BUILD)/dmg-staging $(BUILD)/$(APP).dmg
	mkdir -p $(BUILD)/dmg-staging
	cp -R $(APP_PATH) $(BUILD)/dmg-staging/
	ln -s /Applications $(BUILD)/dmg-staging/Applications
	hdiutil create -volname $(APP) -srcfolder $(BUILD)/dmg-staging \
		-fs HFS+ -ov -format UDZO $(BUILD)/$(APP).dmg
	rm -rf $(BUILD)/dmg-staging
	@echo "==> $(BUILD)/$(APP).dmg"

install: app
	rm -rf /Applications/$(APP).app
	cp -R $(APP_PATH) /Applications/
	@echo "==> Installed to /Applications/$(APP).app"

run: app
	open $(APP_PATH)

clean:
	rm -rf .build $(BUILD)
