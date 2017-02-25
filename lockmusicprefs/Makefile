include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = lockmusicprefs
lockmusicprefs_FILES = LMPRootListController.m
lockmusicprefs_INSTALL_PATH = /Library/PreferenceBundles
lockmusicprefs_FRAMEWORKS = UIKit
lockmusicprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/lockmusicprefs.plist$(ECHO_END)
