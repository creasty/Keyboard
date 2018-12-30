SHELL := /bin/bash -eu -o pipefail

NAME := keyboard

.PHONY: build
build:
	@xcodebuild -project keyboard.xcodeproj -target keyboard -configuration Release build

.PHONY: dist
dist:
	@cd build/Release \
		&& zip -r "$(NAME).zip" Keyboard.app \
		&& mv "$(NAME).zip" .. \
		&& cd ../..
