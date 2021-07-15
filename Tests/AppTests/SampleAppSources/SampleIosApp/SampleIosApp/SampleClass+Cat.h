#import "SampleClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface SampleClass (Cat)

@property (nonatomic) NSString *additionalDynamicProperty;
@property (nonatomic) NSString *additionalNonDynamicProperty;

@end

NS_ASSUME_NONNULL_END
