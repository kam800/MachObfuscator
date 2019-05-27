@import Foundation;

@interface InterfaceWithNSObject: NSObject

@end

@interface RootInterface

@end

@protocol ProtocolWithoutConformance

@end

@protocol ProtocolWithConformance<NSObject>

@end

@class SampleClass_ForwardDeclaration;
@protocol SampleProtocol_ForwardDeclaration;
