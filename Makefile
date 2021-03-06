export ARCHS = arm64 arm64e
export TARGET = iphone:clang:13.5:13.0
export SYSROOT = $(THEOS)/sdks/iPhoneOS13.5.sdk/
export PREFIX = $(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

TWEAK_NAME = SettingsNowPlaying
$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = MediaRemote
ADDITIONAL_CFLAGS += -DTHEOS_LEAN_AND_MEAN

THEOS_DEVICE_IP=localhost -p 2222

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk
SUBPROJECTS += settingsnowplayingprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
include $(THEOS_MAKE_PATH)/tweak.mk
