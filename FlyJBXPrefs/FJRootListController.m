#import <spawn.h>
#include "FJRootListController.h"
#include "FJAppListController.h"
#include "FJCr4shF1xListController.h"
#include "FJDisablerListController.h"
#import "../Cryptor/NSString+AESCrypt.h"

#define RESET_PREFS 100
#define INSTALL_TWITTER 101
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define PREFERENCE_FlyJB @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist"
#define PREFERENCE_Cr4shF1x @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_crashfix.plist"
#define PREFERENCE_Disabler @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_disabler.plist"

NSMutableDictionary *prefs_FlyJB;
NSMutableDictionary *prefs_Cr4shF1x;
NSMutableDictionary *prefs_Disabler;
static NSString *vers = @"1.0.0";

static const NSBundle *tweakBundle;
#define LOCALIZED(str) [tweakBundle localizedStringForKey:str value:@"" table:nil]
static NSString *easterkey = @"이 편지는 영국에서 최초로 시작돼 일 년에 지구 한 바퀴를 돌면서 받는 사람에게 행운을 가져다주었습니다. 지금 당신에게 옮겨진 이 편지는 4일 안에 당신 곁을 떠나야 합니다. 이 편지를 포함하여 7통의 편지를 행운이 필요한 사람에게 보내 주어야 합니다. 복사를 해도 좋습니다. 영국에서 ‘HGXWCH’라는 사람은 1930년 이 편지를 받았습니다. 그는 비서에게 복사해서 보내라고 했습니다. 며칠 뒤 그는 복권이 당첨되어 20억원을 받았습니다. 어떤 이는 이 편지를 받았으나 96시간 이내 자신의 손에서 떠나야 한다는 사실을 잊었습니다. 그는 곧 사직되었습니다. 나중에야 이 사실을 알고 7통의 편지를 보낸 후 다시 좋은 직장을 얻었습니다. 이 편지를 보내면 7년간 행운이 있을 것이고 그렇지 않으면 3년간 불행이 있을 것입니다.";

@implementation FJRootListController
- (instancetype)init {

	self = [super init];

	if (self) {
		tweakBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/FlyJBXPrefs.bundle"];

		self.title = LOCALIZED(@"FlyJB_TITLE");
	}

	return self;

}



- (void)viewDidLoad {
	if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
		[super viewDidLoad];
		return;
	}


	[super viewDidLoad];


	self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,150)];
	self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,200,150)];
	self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
	self.headerImageView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/FlyJBXPrefs.bundle/Banner.png"];
	self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;

	[self.headerView addSubview:self.headerImageView];
	[NSLayoutConstraint activateConstraints:@[
		 [self.headerImageView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor],
		 [self.headerImageView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor],
		 [self.headerImageView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor],
		 [self.headerImageView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
	]];

	_table.tableHeaderView = self.headerView;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	tableView.tableHeaderView = self.headerView;
	return [super tableView:tableView cellForRowAtIndexPath:indexPath];

}

- (NSArray *)specifiers {
	if (!_specifiers) {
		[self getPreference];
		NSMutableArray *specifiers = [[NSMutableArray alloc] init];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_ACTIVATION") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && [[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/FJMemory"]) {
			        NSString *FJDataPath = @"/var/mobile/Library/Preferences/FJMemory";
			        NSData *FJMemory = [NSData dataWithContentsOfFile:FJDataPath options:0 error:nil];
			        NSData *FJMemory_dec = [FJMemory AES256DecryptWithKey:easterkey];
			        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:FJMemory_dec options:0 error:nil];
			        NSString *version = [dict objectForKeyedSubscript:@"version"];
			        [specifier.properties setValue:@"0" forKey:@"footerAlignment"];
			        [specifier.properties setValue:[NSString stringWithFormat:LOCALIZED(@"FlyJB_UPDATE_LASTDATE"), version] forKey:@"footerText"];
			}
			specifier;
		})];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_ENABLE") target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:@"enabled" forKey:@"displayIdentifier"];
			specifier;
		})];
		
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && [[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/FJMemory"]) {
			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_UPDATE_MEMORY") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
				specifier->action = @selector(UpdatePatchData);
				specifier;
			})];
		}

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_APPSETTINGS") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			[specifier.properties setValue:@"0" forKey:@"footerAlignment"];
			[specifier.properties setValue:LOCALIZED(@"FlyJB_BYPASS_DESC") forKey:@"footerText"];
			specifier;
		})];
		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_BYPASSLIST") target:nil set:nil get:nil detail:[FJAppListController class] cell:PSLinkListCell edit:nil]];

		[specifiers addObject:({
			PSSpecifier *specifier = [[PSSpecifier alloc] init];
			[specifier.properties setValue:@"0" forKey:@"footerAlignment"];
			[specifier.properties setValue:LOCALIZED(@"FlyJB_OPTIMIZE_DESC") forKey:@"footerText"];
			specifier;
		})];
		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_OPTIMIZELIST") target:nil set:nil get:nil detail:[FJCr4shF1xListController class] cell:PSLinkListCell edit:nil]];
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
			[specifiers addObject:({
				PSSpecifier *specifier = [[PSSpecifier alloc] init];
				[specifier.properties setValue:@"0" forKey:@"footerAlignment"];
				[specifier.properties setValue:LOCALIZED(@"FlyJB_DISABLER_DESC") forKey:@"footerText"];
				specifier;
			})];
			[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_DISABLERLIST") target:nil set:nil get:nil detail:[FJDisablerListController class] cell:PSLinkListCell edit:nil]];
		}
#if defined __arm64__ || defined __arm64e__
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && [[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/FJMemory"]) {
			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_UPDATEINFO") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
				[specifier.properties setValue:@"0" forKey:@"footerAlignment"];
				[specifier.properties setValue:LOCALIZED(@"FlyJB_PATCHDATA_DESC") forKey:@"footerText"];
				specifier;
			})];

			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_SHOWPATCHDATA") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
				[specifier setIdentifier:@"ShowPatchData"];
				specifier->action = @selector(openWebsite:);
				specifier;
			})];
		}
#endif





		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_ETCOPTIONS") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			specifier;
		})];
/*
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")) {
                        [specifiers addObject:({
                                PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_BAR_ENABLE") target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
                                [specifier.properties setValue:@"FlyJBBarEnable" forKey:@"displayIdentifier"];
                                specifier;
                        })];
                }
 */
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_RESETPREFS") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			specifier->action = @selector(resetPrefs:);
			[specifier setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
			[specifier setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Init" ofType:@"png"]] forKey:@"iconImage"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_SENDFEEDBACK") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			specifier->action = @selector(sendFeedback);
			[specifier setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
			[specifier setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Mail" ofType:@"png"]] forKey:@"iconImage"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_LIKE") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			specifier->action = @selector(Like);
			[specifier setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
			[specifier setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Heart" ofType:@"png"]] forKey:@"iconImage"];
			specifier;
		})];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_CREDIT") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			specifier;
		})];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_DEVELOPER") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"XsF1re"];
			specifier->action = @selector(openWebsite:);
			[specifier setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
			[specifier setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Twitter" ofType:@"png"]] forKey:@"iconImage"];
			specifier;
		})];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_DESIGNER") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_TRANSLATOR_AR") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"Sultan"];
			specifier->action = @selector(openWebsite:);
			[specifier setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
			[specifier setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Twitter" ofType:@"png"]] forKey:@"iconImage"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_TRANSLATOR_CN") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"yunzhimin"];
			specifier->action = @selector(openWebsite:);
			[specifier setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
			[specifier setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Twitter" ofType:@"png"]] forKey:@"iconImage"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_TRANSLATOR_HE") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"guezomri"];
			specifier->action = @selector(openWebsite:);
			[specifier setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
			[specifier setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Twitter" ofType:@"png"]] forKey:@"iconImage"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_TRANSLATOR_DE") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"t0mi"];
			specifier->action = @selector(openWebsite:);
			[specifier setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
			[specifier setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Twitter" ofType:@"png"]] forKey:@"iconImage"];
			specifier;
		})];


		[specifiers addObject:({
			NSString *year = @"2020";
			PSSpecifier *specifier = [[PSSpecifier alloc] init];
			[specifier.properties setValue:@"2" forKey:@"footerAlignment"];
			[specifier.properties setValue:[NSString stringWithFormat:LOCALIZED(@"FlyJB_LASTMSG"), vers, year] forKey:@"footerText"];
			specifier;
		})];

		_specifiers = [specifiers copy];
	}
	return _specifiers;
}

-(void)UpdatePatchData {
	UIAlertController *alert = [UIAlertController
	                            alertControllerWithTitle:LOCALIZED(@"FlyJB_UPDATE_CHECK")
	                            message:LOCALIZED(@"FlyJB_GET_SERVER")
	                            preferredStyle:UIAlertControllerStyleAlert];
	UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[activity startAnimating];
	[activity setFrame:CGRectMake(0, 0, 70, 60)];
	[alert.view addSubview:activity];
	[self presentViewController:alert animated:YES completion:nil];

	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://alias20.dothome.co.kr/785105baa28788d50fad17db79721e5374d7a16c298016c5c8604dc1d71056cca2c1e59de70953b7335570dee95711193d68510a62961b7c477ffd12e1ed8231/last_roleset.php"]];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
	                                      NSString *returnData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	                                      NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
	                                      [alert dismissViewControllerAnimated:YES completion:^{
	                                               if (error || statusCode != 200) {
	                                                       UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOCALIZED(@"FlyJB_UPDATE_FAILED")
	                                                                                   message:LOCALIZED(@"FlyJB_UPDATE_FAILED_DATA")
	                                                                                   preferredStyle:UIAlertControllerStyleAlert];
	                                                       UIAlertAction *ok = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_OK")
	                                                                            style:UIAlertActionStyleDefault
	                                                                            handler:^(UIAlertAction *action){
	                                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
										    }];

	                                                       [alert addAction: ok];
	                                                       [self presentViewController:alert animated:YES completion:nil];
						       }

	                                               if (error == nil && statusCode == 200) {
	                                                       NSString *FJDataPath = @"/var/mobile/Library/Preferences/FJMemory";
	                                                       NSData *FJMemory = [NSData dataWithContentsOfFile:FJDataPath options:0 error:nil];
	                                                       NSData *FJMemory_dec = [FJMemory AES256DecryptWithKey:easterkey];
	                                                       NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:FJMemory_dec options:0 error:nil];
	                                                       NSString *version = [dict objectForKeyedSubscript:@"version"];

	                                                       NSData *returnData_nsd = [returnData dataUsingEncoding:NSUTF8StringEncoding];
	                                                       NSDictionary* dict_web = [NSJSONSerialization JSONObjectWithData:returnData_nsd options:0 error:nil];
	                                                       NSString *version_web = [dict_web objectForKey:@"version"];
	                                                       NSString *supportedVersion_web = [dict_web objectForKey:@"supportedVersion"];

	                                                       NSString *supportedVersion = @"20200703";
	                                                       if(![supportedVersion_web isEqualToString:supportedVersion])  {
	                                                               UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOCALIZED(@"FlyJB_UPDATE_FAILED")
	                                                                                           message:@"현재 버전은 메모리 패치 업데이트 기능을 지원하지 않습니다.\n공중제비 트윅을 최신 버전으로 업데이트해주세요."
	                                                                                           preferredStyle:UIAlertControllerStyleAlert];
	                                                               UIAlertAction *ok = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_OK")
	                                                                                    style:UIAlertActionStyleDefault
	                                                                                    handler:^(UIAlertAction *action){
	                                                                                            [alert dismissViewControllerAnimated:YES completion:nil];
											    }];

	                                                               [alert addAction: ok];
	                                                               [self presentViewController:alert animated:YES completion:nil];
							       }
	                                                       else if([version_web isEqualToString:version]) {
	                                                               UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOCALIZED(@"FlyJB_UPDATE")
	                                                                                           message:LOCALIZED(@"FlyJB_UPDATE_UPTODATE")
	                                                                                           preferredStyle:UIAlertControllerStyleAlert];
	                                                               UIAlertAction *ok = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_OK")
	                                                                                    style:UIAlertActionStyleDefault
	                                                                                    handler:^(UIAlertAction *action){
	                                                                                            [alert dismissViewControllerAnimated:YES completion:nil];
											    }];

	                                                               [alert addAction: ok];
	                                                               [self presentViewController:alert animated:YES completion:nil];
							       }

	                                                       else if(![returnData isEqualToString:version]) {
	                                                               NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://alias20.dothome.co.kr/785105baa28788d50fad17db79721e5374d7a16c298016c5c8604dc1d71056cca2c1e59de70953b7335570dee95711193d68510a62961b7c477ffd12e1ed8231/%@.php", version_web]]];
	                                                               NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
	                                                                                                     NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
	                                                                                                     if (error || statusCode != 200) {
	                                                                                                             UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOCALIZED(@"FlyJB_UPDATE_FAILED")
	                                                                                                                                         message:LOCALIZED(@"FlyJB_UPDATE_FAILED_DATA")
	                                                                                                                                         preferredStyle:UIAlertControllerStyleAlert];
	                                                                                                             UIAlertAction *ok = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_OK")
	                                                                                                                                  style:UIAlertActionStyleDefault
	                                                                                                                                  handler:^(UIAlertAction *action){
	                                                                                                                                          [alert dismissViewControllerAnimated:YES completion:nil];
																	  }];

	                                                                                                             [alert addAction: ok];
	                                                                                                             [self presentViewController:alert animated:YES completion:nil];
													     }

	                                                                                                     if (error == nil && statusCode == 200) {
	                                                                                                             //NSError *error = nil;
	                                                                                                             //NSString *returnData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	                                                                                                             //NSData *nsdataFromBase64String = [[NSData alloc]initWithBase64EncodedString:returnData_prev options:0];
	                                                                                                             //NSString *returnData = [[NSString alloc] initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
	                                                                                                             [data writeToFile:FJDataPath atomically:YES];
	                                                                                                             UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOCALIZED(@"FlyJB_UPDATE_SUCCESS")
	                                                                                                                                         message:LOCALIZED(@"FlyJB_UPDATE_SUCCESS_DATA")
	                                                                                                                                         preferredStyle:UIAlertControllerStyleAlert];
	                                                                                                             UIAlertAction *ok = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_OK")
	                                                                                                                                  style:UIAlertActionStyleDefault
	                                                                                                                                  handler:^(UIAlertAction *action){
	                                                                                                                                          [alert dismissViewControllerAnimated:YES completion:nil];
																	  }];

	                                                                                                             [alert addAction: ok];
	                                                                                                             [self reloadSpecifiers];
	                                                                                                             [self presentViewController:alert animated:YES completion:nil];
													     }
												     }];
	                                                               [task resume];
							       }

						       }
					       }];



				      }];
	[task resume];
	//[self performSelector:@selector(respring:) withObject:nil afterDelay:3.0];
}

- (void)sendFeedback
{
	MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];

	NSString *deviceType = nil, *iOSVersion = nil, *buildNumber = nil, *udid = nil, *JBSubstitutor = nil;

	BOOL isLibHooker = [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libhooker.dylib"];
	BOOL isSubstitute = ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libsubstitute.dylib"] && ![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/substrate"]);


	deviceType = (NSString *)MGCopyAnswer(kMGProductType, nil);
	iOSVersion = (NSString *)MGCopyAnswer(kMGProductVersion, nil);
	buildNumber = (NSString *)MGCopyAnswer(kMGBuildVersion, nil);
	udid = (NSString*)MGCopyAnswer(kMGUniqueDeviceID, nil);

	if(isLibHooker)
		JBSubstitutor = @"libhooker";
	else if(isSubstitute)
		JBSubstitutor = @"Substitute";
	else
		JBSubstitutor = @"Substrate";

	NSString *subject = LOCALIZED(@"FlyJB_FEEDBACK");
	NSString *subjectVers = [NSString stringWithFormat:@"%@%@%@%@",subject,@" (",vers,@")"];

	[mailer setSubject:subjectVers];
	[mailer setMessageBody:[NSString stringWithFormat:LOCALIZED(@"FlyJB_FEEDBACKDATA"), deviceType, iOSVersion, buildNumber, JBSubstitutor, udid] isHTML:NO];
	[mailer setToRecipients:@[@"shg1725x@yahoo.com"]];
	[self.navigationController presentViewController:mailer animated:YES completion:nil];
	mailer.mailComposeDelegate = self;
	[mailer release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissViewControllerAnimated: YES completion: nil];
}

- (void)Like
{
	if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
		SLComposeViewController *twitter = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		[twitter setInitialText:LOCALIZED(@"FlyJB_LIKEDATA")];
		if (twitter != nil) {
			[[self navigationController] presentViewController:twitter animated:YES completion:nil];
		}
	}
	else {

		if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LOCALIZED(@"FlyJB_LIKE") message:LOCALIZED(@"FlyJB_LIKE_INSTALLMSG") delegate:self cancelButtonTitle:LOCALIZED(@"FlyJB_CANCEL") otherButtonTitles:LOCALIZED(@"FlyJB_INSTALL_TWITTER"), nil];
			[alert show];
			alert.tag = INSTALL_TWITTER;
			return;
		}

		UIAlertController *alert = [UIAlertController
		                            alertControllerWithTitle:LOCALIZED(@"FlyJB_LIKE")
		                            message:LOCALIZED(@"FlyJB_LIKE_INSTALLMSG")
		                            preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction* ok = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_INSTALL_TWITTER") style:UIAlertActionStyleDefault
		                     handler:^(UIAlertAction * action){
		                             NSString *url = @"https://apps.apple.com/kr/app/twitter/id333903271";
		                             UIApplication *app = [UIApplication sharedApplication];
		                             [app openURL:[NSURL URLWithString:url]];
				     }];

		UIAlertAction* cancel = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_CANCEL") style:UIAlertActionStyleDefault
		                         handler:^(UIAlertAction * action) {
		                                 [alert dismissViewControllerAnimated:YES completion:nil];
					 }
		                        ];

		[alert addAction:ok];
		[alert addAction:cancel];

		[self presentViewController:alert animated:YES completion:nil];

	}
}

-(void)setSwitch:(NSNumber *)value forSpecifier:(PSSpecifier *)specifier {
	prefs_FlyJB [[specifier propertyForKey:@"displayIdentifier"]] = [NSNumber numberWithBool:[value boolValue]];
	[[prefs_FlyJB copy] writeToFile:PREFERENCE_FlyJB atomically:FALSE];
}
-(NSNumber *)getSwitch:(PSSpecifier *)specifier {
	return [prefs_FlyJB [[specifier propertyForKey:@"displayIdentifier"]] isEqual:@1] ? @1 : @0;
}


-(void)openWebsite:(PSSpecifier *)specifier {
	NSString *value = specifier.identifier;
	NSString *url = nil;
	if([value isEqualToString:@"ShowPatchData"]) {
		url = @"https://repo.xsf1re.kr/flyjb/private/update.txt";
	}
	if([value isEqualToString:@"XsF1re"]) {
		url = @"https://twitter.com/XsF1re";
	}
	if([value isEqualToString:@"Sultan"]) {
		url = @"https://twitter.com/su8782";
	}
	if([value isEqualToString:@"yunzhimin"]) {
		url = @"https://twitter.com/yunzhimin";
	}
	if([value isEqualToString:@"guezomri"]) {
		url = @"https://twitter.com/guezomri";
	}
	if([value isEqualToString:@"t0mi"]) {
		url = @"https://twitter.com/___t0mi___";
	}
	UIApplication *app = [UIApplication sharedApplication];
	[app openURL:[NSURL URLWithString:url]];
}

-(void)resetPrefs:(id)sender {
	if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LOCALIZED(@"FlyJB_TITLE") message:LOCALIZED(@"FlyJB_CHECKRESET") delegate:self cancelButtonTitle:LOCALIZED(@"FlyJB_CANCEL") otherButtonTitles:LOCALIZED(@"FlyJB_RESET"), nil];
		alert.tag = RESET_PREFS;
		[alert show];
		return;
	}
	UIAlertController *alert = [UIAlertController
	                            alertControllerWithTitle:LOCALIZED(@"FlyJB_TITLE")
	                            message:LOCALIZED(@"FlyJB_CHECKRESET")
	                            preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* ok = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_RESET") style:UIAlertActionStyleDefault
	                     handler:^(UIAlertAction * action){

	                             [self resetPreferences];

	                             /*
	                                HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:@"kr.xsf1re.flyjb"];
	                                HBPreferences *prefs_crashfix = [[HBPreferences alloc] initWithIdentifier:@"kr.xsf1re.flyjb_crashfix"];
	                                [prefs removeAllObjects];
	                                [prefs_crashfix removeAllObjects];


	                                [self.enableSwitch setOn:NO animated: YES];

	                                UIAlertController *alert_respring = [UIAlertController
	                                                 alertControllerWithTitle:LOCALIZED(@"FlyJB_RESPRINGSOON")
	                                                 message:LOCALIZED(@"FlyJB_THANKS4TEST")
	                                                 preferredStyle:UIAlertControllerStyleAlert];
	                                [self presentViewController:alert_respring animated:YES completion:nil];
	                                [self performSelector:@selector(respring:) withObject:nil afterDelay:3.0]; */
			     }
	                    ];

	UIAlertAction* cancel = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_CANCEL") style:UIAlertActionStyleDefault
	                         handler:^(UIAlertAction * action) {
	                                 [alert dismissViewControllerAnimated:YES completion:nil];
				 }
	                        ];

	[alert addAction:ok];
	[alert addAction:cancel];

	[self presentViewController:alert animated:YES completion:nil];


}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

	if (alertView.tag == RESET_PREFS && buttonIndex == 1) {
		[self resetPreferences];
	}

	if (alertView.tag == INSTALL_TWITTER && buttonIndex == 1) {
		NSString *url = @"https://apps.apple.com/kr/app/twitter/id333903271";
		UIApplication *app = [UIApplication sharedApplication];
		[app openURL:[NSURL URLWithString:url]];
	}

}

- (void)resetPreferences {
	[[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Preferences/FJMemory" error:NULL];
	[[NSFileManager defaultManager] removeItemAtPath:PREFERENCE_FlyJB error:NULL];
	[[NSFileManager defaultManager] removeItemAtPath:PREFERENCE_Cr4shF1x error:NULL];
	[[NSFileManager defaultManager] removeItemAtPath:PREFERENCE_Disabler error:NULL];

	if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LOCALIZED(@"FlyJB_RESPRINGSOON") message:LOCALIZED(@"FlyJB_THANKS4TEST") delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
		[alert show];
		[self performSelector:@selector(respring:) withObject:nil afterDelay:3.0];
		return;
	}

	UIAlertController *alert_respring = [UIAlertController
	                                     alertControllerWithTitle:LOCALIZED(@"FlyJB_RESPRINGSOON")
	                                     message:LOCALIZED(@"FlyJB_THANKS4TEST")
	                                     preferredStyle:UIAlertControllerStyleAlert];
	[self presentViewController:alert_respring animated:YES completion:nil];
	[self performSelector:@selector(respring:) withObject:nil afterDelay:3.0];

}

- (void)respring:(id)sender {

	if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
		pid_t pid;
		const char* args[] = {"killall", "SpringBoard", NULL};
		posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
		return;
	}

	pid_t pid;
	const char* args[] = {"killall", "backboardd", NULL};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}

-(void)getPreference {
	if(![[NSFileManager defaultManager] fileExistsAtPath:PREFERENCE_FlyJB]) prefs_FlyJB = [[NSMutableDictionary alloc] init];
	else prefs_FlyJB = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCE_FlyJB];
}

@end
