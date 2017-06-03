SHELL := /bin/bash -eu -o pipefail

NAME := keyboard
OS   := sierra

.PHONY: build
build:
	@xcodebuild -project keyboard.xcodeproj -target keyboard -configuration Release build

.PHONY: dist
dist:
	@cd build/Release \
		&& zip -r "$(NAME)-$(OS).zip" keyboard.app \
		&& mv "$(NAME)-$(OS).zip" .. \
		&& cd ../..
