ARCHS = armv7 armv7s arm64
CFLAGS = -fno-objc-arc -O2

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ReachAppAssertiondHooks
ReachAppAssertiondHooks_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
