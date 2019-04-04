#import "SampleClass+Cat.h"

@implementation SampleClass (Cat)

@dynamic additionalDynamicProperty;

- (void)setAdditionalNonDynamicProperty:(NSString *)additionalNonDynamicProperty {

}

- (NSString *)additionalNonDynamicProperty {
    return @"test";
}

@end
