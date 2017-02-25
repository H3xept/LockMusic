include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockMusic
LockMusic_FILES = Tweak.xm ./tools/LLIPC.mm ./tools/LLLog.mm
LockMusic_LIBRARIES = rocketbootstrap
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += lockmusicprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
