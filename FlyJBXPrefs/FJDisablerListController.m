#include "FJDisablerListController.h"
#import <AppList/AppList.h>
#define PREFERENCE_Disabler @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_disabler.plist"
NSMutableDictionary *prefs_Disabler;

static const NSBundle *tweakBundle;
#define LOCALIZED(str) [tweakBundle localizedStringForKey:str value:@"" table:nil]

static NSInteger DictionaryTextComparator(id a, id b, void *context) {
	return [[(__bridge NSDictionary *)context objectForKey:a] localizedCaseInsensitiveCompare:[(__bridge NSDictionary *)context objectForKey:b]];
}

@implementation FJDisablerListController
- (NSArray *)specifiers {
	if (!_specifiers) {
		tweakBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/FlyJBXPrefs.bundle"];
		[self getPreference];
		NSMutableArray *specifiers = [[NSMutableArray alloc] init];
		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_SELECTEDAPPS") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];
		ALApplicationList *applicationList = [ALApplicationList sharedApplicationList];
		NSDictionary *applications = [applicationList applicationsFilteredUsingPredicate:[NSPredicate predicateWithFormat:@"isSystemApplication = FALSE"]];
		NSMutableArray *displayIdentifiers = [[applications allKeys] mutableCopy];
		[displayIdentifiers sortUsingFunction:DictionaryTextComparator context:(__bridge void *)applications];
		for (NSString *displayIdentifier in displayIdentifiers)
		{
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:applications[displayIdentifier] target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:displayIdentifier forKey:@"displayIdentifier"];
			UIImage *icon = [applicationList iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:displayIdentifier];
			if (icon) [specifier setProperty:icon forKey:@"iconImage"];
			[specifiers addObject:specifier];
		}

		_specifiers = [specifiers copy];
	}

	return _specifiers;
}

-(void)setSwitch:(NSNumber *)value forSpecifier:(PSSpecifier *)specifier {
	prefs_Disabler[[specifier propertyForKey:@"displayIdentifier"]] = [NSNumber numberWithBool:[value boolValue]];
	[[prefs_Disabler copy] writeToFile:PREFERENCE_Disabler atomically:FALSE];
}

-(NSNumber *)getSwitch:(PSSpecifier *)specifier {
	return [prefs_Disabler[[specifier propertyForKey:@"displayIdentifier"]] isEqual:@1] ? @1 : @0;
}
-(void)getPreference {
	if(![[NSFileManager defaultManager] fileExistsAtPath:PREFERENCE_Disabler]) prefs_Disabler = [[NSMutableDictionary alloc] init];
	else prefs_Disabler = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCE_Disabler];
}
@end
