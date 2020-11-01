#import "../Headers/CheckHooks.h"

@interface StockNewsdmManager : NSObject
+ (const char *)defRandomString;
@end

%group CheckHooks
%hookf (int, UIApplicationMain, int argc, char * _Nullable *argv, NSString *principalClassName, NSString *delegateClassName) {
	const char* bypasscode = [%c(StockNewsdmManager) defRandomString];
	NSLog(@"[FlyJB] defRandomString = %s", bypasscode);
	if(strcmp("00000000", bypasscode) != 0) {
		exit(0);
	}
	return %orig;
}
%end

void loadCheckHooks() {
	%init(CheckHooks);
}
