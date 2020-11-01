

ARCHS := armv7 armv7s arm64 arm64e
TARGET := iphone:clang:14.0:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = FlyJBXPrefs
$(BUNDLE_NAME)_FILES = ../Cryptor/NSString+AESCrypt.m ../Cryptor/NSData+AESCrypt.m FJRootListController.m FJAppListController.m FJCr4shF1xListController.m FJDisablerListController.m
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_FRAMEWORKS = UIKit
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_LIBRARIES = MobileGestalt applist

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/FlyJBXPrefs.plist$(ECHO_END)
