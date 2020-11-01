//
//  NSString+AESCrypt.h
//

#import <Foundation/Foundation.h>
#import "NSData+AESCrypt.h"

@interface NSString (AESCrypt)

/*
 \internal
 @function AES256EncryptWithKey
 @abstract This function accepts the key to encrypt the NSString and return the encrypted
 string.
 @discussion Converts the string to NSData and calls the encryption method of NSData and
 then converts the encrypted NSData to string and returns the encrypted string.
 @result Returns the encrypted string.
 */
- (NSString *)AES256EncryptWithKey:(NSString *)key;

/*
 \internal
 @function AES256DecryptWithKey
 @abstract This function accepts the key to dencrypt the NSString and return the plain
 string.
 @discussion Converts the encrypted string to encrypted NSData and calls the decryption method of NSData to get the plain NSData which is then converted to string.
 @result Returns the encrypted string.
 */
- (NSString *)AES256DecryptWithKey:(NSString *)key;

@end
