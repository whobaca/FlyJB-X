#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListItemsController.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MobileGestalt/MobileGestalt.h>


@interface FJRootListController : PSListController <MFMailComposeViewControllerDelegate>{
    UITableView * _table;
}
@property(nonatomic, retain)UISwitch* enableSwitch;
@property(nonatomic, retain)UIView* headerView;
@property(nonatomic, retain)UIImageView* headerImageView;
@property(nonatomic, retain)UILabel* titleLabel;
@property(nonatomic, retain)UIImageView* iconView;
@end
