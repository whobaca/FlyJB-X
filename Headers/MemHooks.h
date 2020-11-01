#import <substrate.h>
#import "../Headers/dobby.h"

void loadFJMemoryHooks();
void loadFJMemoryIntegrityRecover();
void loadFJMemorySymbolHooks();
void loadSVC80MemHooks();
void loadOpendirMemHooks();
void startHookTarget_lxShield(uint8_t* match);
void startHookTarget_AhnLab(uint8_t* match);
void startHookTarget_AhnLab2(uint8_t* match);
void startHookTarget_AhnLab3(uint8_t* match);
void startHookTarget_AhnLab4(uint8_t* match);

@interface MemHooks: NSObject
- (NSDictionary *)getDecryptedFJMemory;
@end
