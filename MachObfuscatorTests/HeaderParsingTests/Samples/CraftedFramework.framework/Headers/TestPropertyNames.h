@property int intProperty;
@property (nonatomic, class) int propertyWithAttributes;
      @property           (      nonatomic       , class   )       int   propertyWithLotOfSpaces;
@property(nonatomic,class)int propertyWithoutSpaces;
@property NSString *pointerProperty;
@property (nonatomic) NSString *(^blockProperty)(NSString *);
@property (nonatomic) TypedeffedBlock typedeffedBlockProperty;
@property (nonatomic) NSArray<NSArray<NSString *> *> *propertyWithGenerics;

// @property int propertyFromComments;

@property NSString *propertyWithMacros NS_AVAILABLE_IOS(10_0);
@property NSString *propertyWithDeprecationMsg NS_DEPRECATED_IOS(4_2,10_0, "Use @property NSString* shouldNotBeParsed instead.");

@property (nonatomic) NSString *property1, *property2, *property3;
