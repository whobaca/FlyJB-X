#import "../Headers/OptimizeHooks.h"
#include <dlfcn.h>

%group OptimizeHooks
%hookf(void *, dlopen, const char *path, int mode) {
	if (path == NULL) return %orig(path, mode);
	{
		NSString *nspath = @(path);
		if([nspath hasPrefix:@"/Library/MobileSubstrate/DynamicLibraries/"]
		   && [nspath hasSuffix:@".dylib"])
		{
			return NULL;
		}
		return %orig(path, mode);
	}
}
%end

void loadOptimizeHooks() {
  %init(OptimizeHooks);
}
