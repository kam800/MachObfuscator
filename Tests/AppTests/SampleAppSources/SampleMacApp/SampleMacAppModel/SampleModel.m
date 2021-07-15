#import "SampleModel.h"

@interface SampleModel ()

@property (nonatomic) NSInteger counter;

@end

@implementation SampleModel

- (void)increment {
    ++self.counter;
}

@end
