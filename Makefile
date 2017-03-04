include $(THEOS)/makefiles/common.mk

TWEAK_NAME = lockmusic
lockmusic_FILES = Tweak.xm LLIPC.mm LLLog.mm YoloViewController.m SharedHelper.m
lockmusic_LIBRARIES = rocketbootstrap

YoloViewController.m_CFLAGS = -fobjc-arc
SharedHelper.m_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += lockmusicprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
