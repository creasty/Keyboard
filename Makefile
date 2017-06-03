SHELL := /bin/bash -eu -o pipefail

NAME     := Keyboard
VERSION  := 1.0.0
OS       := sierra

.PHONY: build
build:
	@xcodebuild -project keyboard.xcodeproj -target keyboard -configuration Release build

.PHONY: dist
dist:
	@cd build/Release \
		&& zip -r "$(NAME)-$(VERSION)-$(OS).zip" keyboard.app \
		&& mv "$(NAME)-$(VERSION)-$(OS).zip" .. \
		&& cd ../..
