#import "../Headers/LibraryHooks.h"
#import "../Headers/FJPattern.h"

%group LibraryHooks
//NHN Payco (페이코)
%hook Diresu
+(int)s: (id)arg1: (id)arg2: (id)arg3: (id)arg4 {
	return 0;
}
%end

//AppGuardToast 뱅뱅뱅 상상인디지털뱅크
%hook AGFramework
-(void)CGColorSpaceCopyName: (BOOL)arg1 B: (void *)arg2 {
	;
}

-(void)CGColorGetPattern: (int)arg1 {
	;
}
%end

//DexProtector? 화해 - opendir 후킹이 substitute와 충돌 :(
%hook ProbeCallbacks
+(void)notifyWith: (id)arg1 {
	arg1 = [arg1 stringByReplacingOccurrencesOfString:@":1" withString:@":0"];
	%orig;
}
%end

//KSFileUtil - opendir 후킹이 substitute와 충돌 :(
%hook KSFileUtil
+(int)checkJailBreak {
	return 1;
}
%end

//Arxan 카카오뱅크 v2.2.0+
%hook AIPExecutor
-(void)detectedWith:(id)arg1 type:(int)arg2 {
	;
}
%end

//Arxan 삼성카드 마이홈
%hook samsungCardMyHome
-(void)crash {
	;
}

-(void)timeout {
	;
}

-(void)showPopup:(id)arg1 {
	;
}
%end

//Arxan BC카드
%hook BCAppDelegate
- (void)arxanHackingDetected: (id)arg1 {
	;
}
%end

//Arxan SSGPAY
%hook SSGPAY_DetectionController
-(void) sendLogWithFrgflsType: (id)arg1 {
	;
}
%end

//Arxan 우리카드, 우리페이, 위비멤버스
%hook ArxanTamper
-(void)didSendFinishedEx: (id)arg1 {
	;
}
%end

//Arxan 삼성앱카드
%hook EN_AIP
-(void)deleteMemo {
	;
}

//Arxan 우리카드 Lite
-(void)getIpInsideDataWithCode:(int)arg1 {
	;
}
%end

//Arxan? 하나은행
%hook DataManager
//(구)하나은행
-(void)setP_gCheckGuard: (id)arg1 {
	;
}
//NEW하나은행
-(void)setGCheckGuard: (id)arg1 {
	;
}
%end


//SFAntiPiracy 광주은행
%hook RootViewController
-(void)showJailNotice: (id)arg1 {
	;
}
%end

//XecureAppShield? SVC
%hook XASBase64
+(id)decode: (char *)arg1 {
	NSString *path = %orig;
	if([FJPatternX isPathRestricted:path])
		return nil;
	return %orig(arg1);
}
%end

//RaonSecure
%hook mVaccine
-(BOOL)isJailBreak {
	return false;
}

-(BOOL)mvc {
	return false;
}
%end

//NSHC
%hook __ns_a
-(id)__ns_a1 {
	return @"0";
}
%end

%hook Sanne
-(id)sanneResult {
	NSArray *keys = [NSArray arrayWithObjects:@"ResultCode", nil];
	NSArray *objects = [NSArray arrayWithObjects:@"0000", nil];
	NSDictionary *output = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	return output;
}
%end

%hook __ns_d
-(NSString*)detectionObject {
	NSString* orig = %orig;
	if([orig hasSuffix:@"san.dat"] || [orig hasSuffix:@"updateinfo.dat"])
		return orig;
	return @"/NSHC.bypass";
}
%end

%hook IxShieldController
+(BOOL)systemCheck {
	return true;
}

+(BOOL)integrityCheck {
	return true;
}
%end

//AhnLab
%hook AMSLFairPlayInspector
+(id)unarchive: (id)arg1 {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSData *object_nsdata = [@"AhnLab.bypass" dataUsingEncoding:NSUTF8StringEncoding];
	[dict setObject:object_nsdata forKey:@"kConfirm"];
	[dict setObject:object_nsdata forKey:@"kConfirmValidation"];
	[dict setObject:object_nsdata forKey:@"8D9188AA-36C3-428E-BE4C-134EF1EBF648"];
	[dict setObject:object_nsdata forKey:@"95BA52F0-0A20-4728-89C1-18B5E69ECE04"];
	return dict;
}

+(id)hmacWithSierraEchoCharlieRomeoEchoTango: (id)arg1 andData: (id)arg2 {
	NSData *object_nsdata = [@"AhnLab.bypass" dataUsingEncoding:NSUTF8StringEncoding];
	return object_nsdata;
}

-(id)fairPlayWithResponseAck: (id)arg1 {
	return nil;
}
%end

%hook StringEncryption
- (id)decrypt: (id)arg1 key: (id)arg2 padding: (int)arg3 {
	NSData *orig = %orig;
	NSString* decode = [[NSString alloc] initWithData:orig encoding:NSUTF8StringEncoding];
	if([FJPatternX isPathRestricted:decode] || [FJPatternX isAhnLabPathRestricted:decode])
		return [@"/AhnLab.bypass" dataUsingEncoding:NSUTF8StringEncoding];
	return %orig;
}
%end

%hook amsLibrary
- (id)decrypt: (id)arg1 key: (id)arg2 padding: (int)arg3 {
	NSData *orig = %orig;
	NSString* decode = [[NSString alloc] initWithData:orig encoding:NSUTF8StringEncoding];
	if([FJPatternX isPathRestricted:decode] || [FJPatternX isAhnLabPathRestricted:decode])
		return [@"/AhnLab.bypass" dataUsingEncoding:NSUTF8StringEncoding];
	return %orig;
}
%end

%hook ams2Library
- (id)decrypt: (id)arg1 key: (id)arg2 padding: (int)arg3 {
	NSData *orig = %orig;
	NSString* decode = [[NSString alloc] initWithData:orig encoding:NSUTF8StringEncoding];
	if([FJPatternX isPathRestricted:decode] || [FJPatternX isAhnLabPathRestricted:decode])
		return [@"/AhnLab.bypass" dataUsingEncoding:NSUTF8StringEncoding];
	return %orig;
}
%end

%hook AMSLBouncer
- (id)decrypt: (id)arg1 key: (id)arg2 padding: (int)arg3 {
	NSData *orig = %orig;
	NSString* decode = [[NSString alloc] initWithData:orig encoding:NSUTF8StringEncoding];
	if([FJPatternX isPathRestricted:decode] || [FJPatternX isAhnLabPathRestricted:decode])
		return [@"/AhnLab.bypass" dataUsingEncoding:NSUTF8StringEncoding];
	return %orig;
}
%end
%end

void loadLibraryHooks() {
	%init(LibraryHooks,
	      SSGPAY_DetectionController = NSClassFromString(@"SSGPAY.DetectionController"),
	      samsungCardMyHome = NSClassFromString(@" "));
}
