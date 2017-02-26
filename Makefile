include $(THEOS)/makefiles/common.mk

TWEAK_NAME = lockmusic
lockmusic_FILES = Tweak.xm LLIPC.mm LLLog.mm
lockmusic_LIBRARIES = rocketbootstrap

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += lockmusicprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
