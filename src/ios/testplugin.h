#import <Cordova/CDVPlugin.h>

@interface GeneroTestPlugin : CDVPlugin
{
  NSTimer* _timer;
  int _testCount;
}
@property (nonatomic) int testCount;
@end
