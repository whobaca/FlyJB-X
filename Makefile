GO_EASY_ON_ME = 1
FINALPACKAGE=1
DEBUG=0

ARCHS := arm64 arm64e
TARGET := iphone:clang:14.0:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FlyJBX
$(TWEAK_NAME)_FRAMEWORKS = Dobby MobileCoreServices
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = AppSupport BackBoardServices
$(TWEAK_NAME)_LIBRARIES = substrate MobileGestalt
$(TWEAK_NAME)_FILES = Cryptor/NSString+AESCrypt.m Cryptor/NSData+AESCrypt.m Tweaks/FJPattern.xm Tweaks/Tweak.xm Tweaks/LibraryHooks.xm Tweaks/ObjCHooks.xm Tweaks/DisableInjector.xm Tweaks/SysHooks.xm Tweaks/NoSafeMode.xm Tweaks/MemHooks.xm Tweaks/OptimizeHooks.xm Tweaks/CheckHooks.xm Tweaks/PatchFinder.xm Tweaks/AeonLucid.xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += FlyJBXPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk
