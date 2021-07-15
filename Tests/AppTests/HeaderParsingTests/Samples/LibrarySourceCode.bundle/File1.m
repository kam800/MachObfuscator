#import "File1.h"

@interface PrivateClass : NSObject

@property (nonatomic, readonly) NSString *privateProperty;

- (void)privateMethod;

@end

@implementation PublicClass

@end
