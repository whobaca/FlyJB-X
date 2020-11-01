#import "../Headers/MemHooks.h"
#import "../Headers/AeonLucid.h"
#import "../Cryptor/NSString+AESCrypt.h"
#import "../Headers/dobby.h"
#import "../Headers/FJPattern.h"
#include <sys/syscall.h>
#include <dlfcn.h>

@implementation MemHooks
- (NSDictionary *)getDecryptedFJMemory {
	NSData *FJMemory = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Preferences/FJMemory" options:0 error:nil];
	NSData *FJMemory_dec = [FJMemory AES256DecryptWithKey:@"이 편지는 영국에서 최초로 시작돼 일 년에 지구 한 바퀴를 돌면서 받는 사람에게 행운을 가져다주었습니다. 지금 당신에게 옮겨진 이 편지는 4일 안에 당신 곁을 떠나야 합니다. 이 편지를 포함하여 7통의 편지를 행운이 필요한 사람에게 보내 주어야 합니다. 복사를 해도 좋습니다. 영국에서 ‘HGXWCH’라는 사람은 1930년 이 편지를 받았습니다. 그는 비서에게 복사해서 보내라고 했습니다. 며칠 뒤 그는 복권이 당첨되어 20억원을 받았습니다. 어떤 이는 이 편지를 받았으나 96시간 이내 자신의 손에서 떠나야 한다는 사실을 잊었습니다. 그는 곧 사직되었습니다. 나중에야 이 사실을 알고 7통의 편지를 보낸 후 다시 좋은 직장을 얻었습니다. 이 편지를 보내면 7년간 행운이 있을 것이고 그렇지 않으면 3년간 불행이 있을 것입니다."];
	NSDictionary *DecryptedFJMemory = [NSJSONSerialization JSONObjectWithData:FJMemory_dec options:0 error:nil];
	return DecryptedFJMemory;
}
@end

uint8_t RET[] = {
	0xC0, 0x03, 0x5F, 0xD6  //RET
};

void (*orig_subroutine)(void);
void nothing(void)
{
	;
}

void startHookTarget_lxShield(uint8_t* match) {
#if defined __arm64__ || defined __arm64e__
	hook_memory(match - 0x1C, RET, sizeof(RET));
#endif
}

void startHookTarget_AhnLab(uint8_t* match) {
#if defined __arm64__ || defined __arm64e__
	hook_memory(match, RET, sizeof(RET));
#endif
}

void startHookTarget_AhnLab2(uint8_t* match) {
#if defined __arm64__ || defined __arm64e__
	hook_memory(match - 0x10, RET, sizeof(RET));
#endif
}

void startHookTarget_AhnLab3(uint8_t* match) {
#if defined __arm64__ || defined __arm64e__
	hook_memory(match - 0x8, RET, sizeof(RET));
#endif
}

void startHookTarget_AhnLab4(uint8_t* match) {
#if defined __arm64__ || defined __arm64e__
	hook_memory(match - 0x10, RET, sizeof(RET));
#endif
}

// ====== PATCH CODE ====== //
void SVC80_handler(RegisterContext *reg_ctx, const HookEntryInfo *info) {
#if defined __arm64__ || defined __arm64e__
	int syscall_num = (int)(uint64_t)reg_ctx->general.regs.x16;

	if(syscall_num == SYS_open || syscall_num == SYS_access || syscall_num == SYS_lstat64) {
		const char* path = (const char*)(uint64_t)(reg_ctx->general.regs.x0);
		NSString* path2 = [NSString stringWithUTF8String:path];
		if(![path2 hasSuffix:@"/sbin/mount"] && [FJPatternX isPathRestrictedForSymlink:path2]) {
			*(unsigned long *)(&reg_ctx->general.regs.x0) = (unsigned long long)"/XsF1re";
			NSLog(@"[FlyJB] Bypassed SVC #0x80 - num: %d, path: %s", syscall_num, path);
		}
		else {
			NSLog(@"[FlyJB] Detected SVC #0x80 - num: %d, path: %s", syscall_num, path);
		}
	}

	else {
		NSLog(@"[FlyJB] Detected Unknown SVC #0x80 number: %d", syscall_num);
	}
#endif
}

void startHookTarget_SVC80(uint8_t* match) {
#if defined __arm64__ || defined __arm64e__
	dobby_enable_near_branch_trampoline();
	DobbyInstrument((void *)(match), (DBICallTy)SVC80_handler);
	dobby_disable_near_branch_trampoline();
#endif
}

void loadSVC80MemHooks() {
#if defined __arm64__ || defined __arm64e__
	const uint8_t target[] = {
		0x01, 0x10, 0x00, 0xD4  //SVC #0x80
	};
	scan_executable_memory(target, sizeof(target), &startHookTarget_SVC80);
#endif
}

// ====== PATCH FROM FJMemory ====== //
void loadFJMemoryHooks() {
#if defined __arm64__ || defined __arm64e__
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSDictionary *dict = [[[MemHooks alloc] init] getDecryptedFJMemory];
	NSInteger dictAddrCount = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"addr"] count];
	if(dictAddrCount) {
		for(int i=0; i < dictAddrCount; i++)
		{
			NSString* dict_addr = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"addr"] objectAtIndex:i];
			NSString* dict_instr = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"instr"] objectAtIndex:i];
			NSLog(@"[FlyJB] bundleID = %@, dict_addr = %@, dict_instr = %@", bundleID, dict_addr, dict_instr);
			writeData(strtoull(dict_addr.UTF8String, NULL, 0), strtoull(dict_instr.UTF8String, NULL, 0));
		}
	}
#endif
}

// ====== 하나멤버스 무결성 복구 ====== //
%group FJMemoryIntegrityRecoverHMS
%hook NSFileManager
- (BOOL)fileExistsAtPath: (NSString *)path {
#if defined __arm64__ || defined __arm64e__
	if([path hasSuffix:@"/com.vungle/userInfo"]) {
		NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
		NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
		NSDictionary *dict = [[[MemHooks alloc] init] getDecryptedFJMemory];
		NSInteger dictInstrOrigCount = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"instr_orig"] count];
		if(dictInstrOrigCount) {
			for(int i=0; i < dictInstrOrigCount; i++)
			{
				NSString* dict_addr = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"addr"] objectAtIndex:i];
				NSString* dict_instrOrig = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"instr_orig"] objectAtIndex:i];
				writeData(strtoull(dict_addr.UTF8String, NULL, 0), strtoull(dict_instrOrig.UTF8String, NULL, 0));
			}
		}
	}
#endif
	return %orig;
}
%end
%end

// ====== 롯데안심인증 무결성 복구 ====== //
%group FJMemoryIntegrityRecoverLMP
%hook XASAskJobs
+(int)updateCheck {
#if defined __arm64__ || defined __arm64e__
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSDictionary *dict = [[[MemHooks alloc] init] getDecryptedFJMemory];
	NSInteger dictInstrOrigCount = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"instr_orig"] count];
	if(dictInstrOrigCount) {
		for(int i=0; i < dictInstrOrigCount; i++)
		{
			NSString* dict_addr = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"addr"] objectAtIndex:i];
			NSString* dict_instrOrig = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"instr_orig"] objectAtIndex:i];
			writeData(strtoull(dict_addr.UTF8String, NULL, 0), strtoull(dict_instrOrig.UTF8String, NULL, 0));
		}
	}
#endif
	return 121;
}
%end
%end

void loadFJMemoryIntegrityRecover() {
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	if([bundleID isEqualToString:@"com.hana.hanamembers"]) {
		%init(FJMemoryIntegrityRecoverHMS);
	}
	if([bundleID isEqualToString:@"com.lottecard.mobilepay"]) {
		%init(FJMemoryIntegrityRecoverLMP);
	}
}

// ====== PATCH SYMBOL FROM FJMemory ====== //
void loadFJMemorySymbolHooks() {
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSDictionary *dict = [[[MemHooks alloc] init] getDecryptedFJMemory];
	NSInteger SymbolCount = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"symbol"] count];
	for(int i=0; i < SymbolCount; i++)
	{
		NSString* dict_Symbol = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"symbol"] objectAtIndex:i];
		const char *dict_Symbol_cs = [dict_Symbol cStringUsingEncoding:NSUTF8StringEncoding];
		MSHookFunction(MSFindSymbol(NULL, dict_Symbol_cs), (void *)nothing, (void **)&orig_subroutine);
	}
}

void opendir_handler(RegisterContext *reg_ctx, const HookEntryInfo *info) {
	#if defined __arm64__ || defined __arm64e__
	const char* path = (const char*)(uint64_t)(reg_ctx->general.regs.x0);
	NSString* path2 = [NSString stringWithUTF8String:path];

	if([FJPatternX isPathRestricted:path2]) {
		NSLog(@"[FlyJB] Bypassed opendir path = %s", path);
		unsigned long fileValue = 0;
		__asm __volatile("mov x0, %0" :: "r" ("/XsF1re_Bypass!@#"));         //path
		__asm __volatile("mov %0, x0" : "=r" (fileValue));
		*(unsigned long *)(&reg_ctx->general.regs.x0) = fileValue;
	}
	else {
		NSLog(@"[FlyJB] Detected opendir path = %s", path);
	}

	#endif
}

void loadOpendirMemHooks() {
#if defined __arm64__ || defined __arm64e__
	//dobby_enable_near_branch_trampoline();
	DobbyInstrument(dlsym((void *)RTLD_DEFAULT, "opendir"), (DBICallTy)opendir_handler);
	//dobby_disable_near_branch_trampoline();
#endif
}
