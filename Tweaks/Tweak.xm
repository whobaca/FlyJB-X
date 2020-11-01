#import <substrate.h>
#import "../Headers/FJPattern.h"
#import "../Headers/LibraryHooks.h"
#import "../Headers/ObjCHooks.h"
#import "../Headers/DisableInjector.h"
#import "../Headers/SysHooks.h"
#import "../Headers/NoSafeMode.h"
#import "../Headers/MemHooks.h"
#import "../Headers/OptimizeHooks.h"
#import "../Headers/CheckHooks.h"
#import "../Headers/PatchFinder.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <spawn.h>
extern "C" void BKSTerminateApplicationForReasonAndReportWithDescription(NSString *bundleID, int reasonID, bool report, NSString *description);

@interface SBHomeScreenViewController : UIViewController
@end

@interface LSApplicationProxy
+(LSApplicationProxy *)applicationProxyForIdentifier:(NSString *)bundleId;
-(NSString *)bundleExecutable;
@end

%group NoFile
%hook SpringBoard
-(void)applicationDidFinishLaunching: (id)arg1 {
	%orig;
	UIAlertController *alertController = [UIAlertController
	                                      alertControllerWithTitle:@"공중제비"
	                                      message:@"FJMemory 파일을 불러올 수 없습니다. 트윅을 재설치하십시오."
	                                      preferredStyle:UIAlertControllerStyleAlert
	                                     ];

	[alertController addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
	                                    [((UIApplication*)self).keyWindow.rootViewController dismissViewControllerAnimated:YES completion:NULL];
				    }]];

	[((UIApplication*)self).keyWindow.rootViewController presentViewController:alertController animated:YES completion:NULL];
}
%end
%end

%group ReachItIntegrityFail
%hook SpringBoard
-(void)applicationDidFinishLaunching: (id)arg1 {
	%orig;
	UIAlertController *alertController = [UIAlertController
	                                      alertControllerWithTitle:@"공중제비"
	                                      message:@"현재 설치된 공중제비 트윅은 신뢰되지 않거나 크랙, 또는 불법 소스로부터 설치된 것으로 판단됩니다.\n제거하시고 아래 소스로부터 설치하시기 바랍니다.\nhttps://repo.xsf1re.kr/"
	                                      preferredStyle:UIAlertControllerStyleAlert
	                                     ];

	[alertController addAction:[UIAlertAction actionWithTitle:@"에휴" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
	                                    [((UIApplication*)self).keyWindow.rootViewController dismissViewControllerAnimated:YES completion:NULL];
				    }]];

	[((UIApplication*)self).keyWindow.rootViewController presentViewController:alertController animated:YES completion:NULL];
}
%end
%end

%group SpringBoardGetAlert
%hook SBHomeScreenViewController
-(void)loadView {
	%orig;
	CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"kr.xsf1re.flyjbcenter"];
	[center runServerOnCurrentThread];
	[center registerForMessageName:@"getAlert" target:self selector:@selector(alert:message:)];
}

%new
- (NSDictionary *)alert: (NSString *)name message: (NSDictionary *)userInfo {
	if([[userInfo objectForKey:@"message"] isEqualToString:@"Unregistered"]) {
		//BKSTerminateApplicationForReasonAndReportWithDescription([userInfo objectForKey:@"bundleID"], 5, false, NULL);
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"공중제비" message:@"현재 우회 기능이 작동하지 않습니다.\n개발자에게 문의하세요." preferredStyle: UIAlertControllerStyleAlert];
		[alert addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		                          [alert dismissViewControllerAnimated:YES completion:nil];
				  }]];

		[self presentViewController:alert animated:true completion:nil];
		sleep(1);
		NSString *executablePath = [[LSApplicationProxy applicationProxyForIdentifier:[userInfo objectForKey:@"bundleID"]] bundleExecutable];
		pid_t pid;
		const char* args[] = {"killall", [executablePath UTF8String], NULL};
		posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
		//BKSTerminateApplicationForReasonAndReportWithDescription([userInfo objectForKey:@"bundleID"], 5, false, NULL);
	}
	return nil;
}
%end
%end

%ctor{

	NSLog(@"[FlyJB] Loaded!!!");

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist"];
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	BOOL isSubstitute = ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libsubstitute.dylib"] && ![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/substrate"] && ![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libhooker.dylib"]);

	if([bundleID isEqualToString:@"com.vivarepublica.cash"]) {
		loadNoSafeMode();

		if(![prefs[@"enabled"] boolValue] || ![prefs[@"com.vivarepublica.cash"] boolValue]) {
			exit(0);
		}
	}

	if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/kr.xsf1re.flyjbx.list"]) {
		%init(ReachItIntegrityFail);
		return;
	}

	if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/FJMemory"]) {
		%init(NoFile);
		return;
	}

	%init(SpringBoardGetAlert);
	loadDisableInjector();

	NSMutableDictionary *prefs_crashfix = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_crashfix.plist"];
	if(prefs_crashfix && [prefs[@"enabled"] boolValue] && [prefs_crashfix[bundleID] boolValue]) {
		loadOptimizeHooks();
	}

	if(![bundleID hasPrefix:@"com.apple"] && prefs && [prefs[@"enabled"] boolValue]) {
		if(([prefs[bundleID] boolValue])
		   || ([bundleID hasPrefix:@"com.ibk.ios.ionebank"] && [prefs[@"com.ibk.ios.ionebank"] boolValue])
		   || ([bundleID hasPrefix:@"com.lguplus.mobile.cs"] && [prefs[@"com.lguplus.mobile.cs"] boolValue]))
		{
			if([bundleID isEqualToString:@"com.kbstar.kbbank"])
				loadNoSafeMode();

			loadFJMemoryHooks();

			if([bundleID isEqualToString:@"com.hana.hanamembers"] || [bundleID isEqualToString:@"com.lottecard.mobilepay"])
				loadFJMemoryIntegrityRecover();

			if([bundleID isEqualToString:@"com.kakaobank.channel"]) {
				//loadFJMemorySymbolHooks();
				//kakaoBankPatch();
				NSLog(@"[FlyJB] kakaoBankPatch: %d", kakaoBankPatch());
			}
//AhnLab Mobile Security - NH올원페이, 하나카드
			if([bundleID isEqualToString:@"com.nonghyup.card.NHAllonePay"] || [bundleID isEqualToString:@"com.hanaskcard.mobileportal"])
				loadAhnLabMemHooks();

//락인컴퍼니 솔루션 LiApp - 차이, 랜덤다이스, 아시아나항공, 코인원
			if([bundleID isEqualToString:@"finance.chai.app"] || [bundleID isEqualToString:@"com.percent.royaldice"] || [bundleID isEqualToString:@"com.asiana.asianaapp"]
			   || [bundleID isEqualToString:@"kr.co.coinone.officialapp"])
				loadSysHooks4();

//스틸리언
			Class stealienExist = objc_getClass("StockNewsdmManager");
			Class stealienExist2 = objc_getClass("FactoryConfigurati");
			if((stealienExist || stealienExist2) && ![bundleID isEqualToString:@"com.vivarepublica.cash"])
				loadStealienObjCHooks();

//스틸리언2 - 케이뱅크, 보험파트너, 토스, 사이다뱅크(SBI저축은행), 티머니페이, 티머니 비즈페이
			if([bundleID isEqualToString:@"com.kbankwith.smartbank"] || [bundleID isEqualToString:@"im.toss.app.insurp"] || [bundleID isEqualToString:@"com.vivarepublica.cash"]
			   || [bundleID isEqualToString:@"com.sbi.saidabank"] || [bundleID isEqualToString:@"com.tmoney.tmpay"] || [bundleID isEqualToString:@"com.kscc.t-gift"])
				loadSysHooks4();

//배달요기요앱은 한번 탈옥감지하면 설정파일에 colorChecker key에 TRUE 값이 기록됨.
			if([bundleID isEqualToString:@"com.yogiyo.yogiyoapp"])
				loadYogiyoObjcHooks();

//따로 제작? 불명 - KB손해보험; AppDefense? - 우체국예금 스마트 뱅킹, 바이오인증공동앱, 모바일증권 나무, 디지털OTP(스마트보안카드)
			if([bundleID isEqualToString:@"com.kbinsure.kbinsureapp"] || [bundleID isEqualToString:@"com.epost.psf.sd"]  || [bundleID isEqualToString:@"org.kftc.fido.lnk.lnkApp"]
			   || [bundleID isEqualToString:@"com.wooriwm.txsmart"] || [bundleID isEqualToString:@"kr.or.kftc.fsc.dist"])
				loadSVC80MemHooks();

//NSHC ixShield 또는 변종? - 엘페이, 엘포인트, 현대카드, 온통대전, 고향사랑페이, Seezn, KT패밀리박스, 모바일 관세청, KT 콘텐츠박스, KT멤버쉽, 마이케이티, 원네비
			if([bundleID isEqualToString:@"com.lotte.mybee.lpay"] || [bundleID isEqualToString:@"com.lottecard.LotteMembers"]
			   || [bundleID isEqualToString:@"kr.co.nmcs.ontongdaejeon"] || [bundleID isEqualToString:@"kr.co.nmcs.lpay"] || [bundleID isEqualToString:@"kr.co.show.ollehtv"]
			   || [bundleID isEqualToString:@"com.kt.ollehfamilybox"] || [bundleID isEqualToString:@"kr.go.kcs.mobile.pubservice"] || [bundleID isEqualToString:@"com.kt.contentsbox"]
			   || [bundleID isEqualToString:@"kr.co.show.ollehclub2"] || [bundleID isEqualToString:@"kr.co.show.cs.full"] || [bundleID isEqualToString:@"kr.co.show.shownavi"]
			   || [bundleID isEqualToString:@"com.kt.ios.dongbaekpay"])
				loadSVC80MemHooks();

//NSHC Sanne? - 티머니페이, 티머니페이 비즈페이(업무택시)
			if([bundleID isEqualToString:@"com.tmoney.tmpay"] || [bundleID isEqualToString:@"com.kscc.t-gift"])
				loadSVC80MemHooks();

//NSHC lxShield - 가디언테일즈, 현대카드
			if([bundleID isEqualToString:@"com.kakaogames.gdtskr"] || [bundleID isEqualToString:@"com.hyundaicard.hcappcard"])
				loadlxShieldMemHooks();

//RaonSecure TouchEn mVaccine - 비플제로페이, 하나은행(+Arxan?), 하나알리미(+Arxan?, 메모리 패치 있음), 미래에셋생명 모바일창구
			if([bundleID isEqualToString:@"com.bizplay.zeropay"] || [bundleID isEqualToString:@"com.hanabank.smart.HanaNBank"] || [bundleID isEqualToString:@"com.kebhana.hanapush"]
			   || [bundleID isEqualToString:@"com.miraeasset.mobilewindow"])
				loadSVC80MemHooks();

//Arxan - 스마일페이, THE POP, 나만의 냉장고(GS25), GS수퍼마켓, BC카드, 삼성카드 마이홈, 하나금융투자 1Q MTS, 하나금융투자 파생, 하나금융투자 프로, 하나원큐 주식 - 하나금융투자
			if([bundleID isEqualToString:@"com.mysmilepay.app"] || [bundleID isEqualToString:@"com.gsretail.ios.thepop"] || [bundleID isEqualToString:@"com.gsretail.gscvs"]
			   || [bundleID isEqualToString:@"com.gsretail.supermarket"] || [bundleID isEqualToString:@"com.bccard.iphoneapp"] || [bundleID isEqualToString:@"com.samsungCard.samsungCard"]
			   || [bundleID isEqualToString:@"com.app.shd.pstock"] || [bundleID isEqualToString:@"com.hanasec.world"] || [bundleID isEqualToString:@"com.hanasec.stock"]
			   || [bundleID isEqualToString:@"com.app.shd.spstock"]) {
				//loadSysHooks4();
				loadSVC80MemHooks();
			}

//하나카드, NEW하나은행은 우회가 좀 까다로운 듯? 하면 안되는 시스템 후킹이 있음

			if(![bundleID isEqualToString:@"com.hanaskcard.mobileportal"] && ![bundleID isEqualToString:@"com.kebhana.hanapush"]) {
				loadSysHooks2();
				if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0"))
					loadSysHooks3();
			}

			if(isSubstitute)
				loadOpendirMemHooks();
			else
				loadOpendirSysHooks();

			loadObjCHooks();
			loadSysHooks();
			loadLibraryHooks();

//토스 탈옥감지 확인
			if([bundleID isEqualToString:@"com.vivarepublica.cash"])
				loadCheckHooks();


		}
	}
}
