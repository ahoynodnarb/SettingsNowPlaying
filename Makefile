ARCHS = arm64 arm64e
THEOS_DEVICE_IP=localhost
THEOS_DEVICE_PORT=2222

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk


TWEAK_NAME = SettingsNowPlaying

SettingsNowPlaying_FILES = Settings.xm
SettingsNowPlaying_PRIVATE_FRAMEWORKS = MediaRemote
SettingsNowPlaying_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
