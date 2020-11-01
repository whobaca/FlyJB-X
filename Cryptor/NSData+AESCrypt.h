//
//  NSData+AESCrypt.h
//
//  AES Encrypt/Decrypt


#import <Foundation/Foundation.h>

@interface NSData (AESCrypt)

/*
 \internal
 @function AES256EncryptWithKey
 @abstract This function accepts the key to encrypt the NSData.
 @discussion This function accepts the key to encrypt and converts the NSData to encrypted
 NSData.
 @result Returns the encrypted NSData.
 */
- (NSData *)AES256EncryptWithKey:(NSString *)key;

/*
 \internal
 @function AES256DecryptWithKey
 @abstract This function accepts the key to decrypt the encrypted NSData.
 @discussion This function accepts the key to decrypt the NSData that is  encrypted and
 converts it to plain NSData
 @result Returns the decrypted NSData.
 */
- (NSData *)AES256DecryptWithKey:(NSString *)key;

/*
 \internal
 @function dataWithBase64EncodedString
 @abstract This function returns the string in NSData format.
 @discussion Converts the string to NSData.
 @result NSData.
 */
+ (NSData *)dataWithBase64EncodedString:(NSString *)string;

/*
 \internal
 @function initWithBase64EncodedString
 @abstract Convert the string to NSData.
 @discussion Convert the string to ASCII data and then to NSData.
 @result Returns NSData.
 */
- (id)initWithBase64EncodedString:(NSString *)string;

/*
 \internal
 @function base64Encoding
 @abstract Convert NSData to NSString.
 @discussion This function calls base64EncodingWithLineLength.
 @result Returns NSString.
 */
- (NSString *)base64Encoding;

/*
 \internal
 @function base64EncodingWithLineLength
 @abstract Convert NSData to NSString.
 @discussion This function is used to convert the encrypted data to encrypted string.
 @result Returns NSString.
 */
- (NSString *)base64EncodingWithLineLength:(NSUInteger)lineLength;


@end
