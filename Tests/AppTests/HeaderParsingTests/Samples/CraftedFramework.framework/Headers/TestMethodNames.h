- (void)instanceMethod;
+ (void)classMethod;
              - (void)methodWithLeadingInset;
   -        (void)         methodWithLotOfSpaces         ;
-(void)methodWithoutSpaces;
-(NSString *(^)(NSString *))methodThatReturnsBlock;
-(NSString *(^)(NSString *))methodThatReturnsBlock:(BOOL)b andTakesArguments:(BOOL)b;
-(TypedeffedBlock)methodThatReturnsTypedefedBlock;

- (int)methodThatTakesInt:(int)integer andString:(NSString *)string andVoid:(void *)v;

// - (int)methodFromComments;

- (int)methodWithMacros NS_AVAILABLE_IOS(10_0);
- (int)methodWithDeprecationMsg: __deprecated_msg("Use shouldNotBeParsed: instead");
