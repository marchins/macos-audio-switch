# Makefile for AudioSwitcher

APP_NAME = AudioSwitcher
BUNDLE_NAME = $(APP_NAME).app
BUILD_DIR = build
SOURCES = AudioSwitcher/main.swift \
          AudioSwitcher/AppDelegate.swift \
          AudioSwitcher/AudioDeviceManager.swift \
          AudioSwitcher/KeyboardShortcutManager.swift \
          AudioSwitcher/LaunchAtLoginManager.swift

.PHONY: all build run clean install dmg

all: build

build:
	@echo "Building $(APP_NAME)..."
	@mkdir -p $(BUILD_DIR)/$(BUNDLE_NAME)/Contents/MacOS
	@mkdir -p $(BUILD_DIR)/$(BUNDLE_NAME)/Contents/Resources
	@swiftc $(SOURCES) \
		-o $(BUILD_DIR)/$(BUNDLE_NAME)/Contents/MacOS/$(APP_NAME) \
		-framework Cocoa \
		-framework CoreAudio \
		-framework Carbon \
		-framework ServiceManagement \
		-Xlinker -rpath -Xlinker @executable_path/../Frameworks
	@cp AudioSwitcher/Info.plist $(BUILD_DIR)/$(BUNDLE_NAME)/Contents/
	@echo "Build complete! App bundle created at: $(BUILD_DIR)/$(BUNDLE_NAME)"

run: build
	@echo "Launching $(APP_NAME)..."
	@open $(BUILD_DIR)/$(BUNDLE_NAME)

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@echo "Clean complete!"

install: build
	@echo "Installing $(APP_NAME) to /Applications..."
	@sudo cp -r $(BUILD_DIR)/$(BUNDLE_NAME) /Applications/
	@echo "Installation complete! You can now run $(APP_NAME) from /Applications"

dmg: build
	@echo "Creating DMG installer..."
	@./create-dmg.sh

help:
	@echo "Available targets:"
	@echo "  make build   - Build the application"
	@echo "  make run     - Build and run the application"
	@echo "  make clean   - Remove build artifacts"
	@echo "  make install - Install to /Applications (requires sudo)"
	@echo "  make dmg     - Create a DMG installer for distribution"
	@echo "  make help    - Show this help message"
