NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<K, V> (NSGenericFastEnumeraiton) <NSFastEnumeration>
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(K __unsafe_unretained _Nullable [_Nonnull])buffer count:(NSUInteger)len;
@end

NS_ASSUME_NONNULL_END
