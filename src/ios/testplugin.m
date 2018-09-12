#import "testplugin.h"
static NSString* s_arg_no_num=@"Argument is not a Number.";
@implementation GeneroTestPlugin

- (void)stringEcho:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    id idArg = [command argumentAtIndex:0 withDefault:nil];
    if (idArg!=nil && ![idArg isKindOfClass:NSString.class]) {
      [self sendStringError:@"Argument is not a String." callbackId:command.callbackId];
      return;
    }
    NSString* echo = (NSString*)idArg;
    if (echo != nil && [echo length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"param must be non NULL and not empty"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/* checks if we are able to survive a result when using the Cordova IOS runInBackground API */
- (void)stringEchoInBg:(CDVInvokedUrlCommand*)command
{
    NSString* echo = [command.arguments objectAtIndex:0];
    __weak GeneroTestPlugin* weakSelf = self;
    [self.commandDelegate runInBackground:^{
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
      [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

/* checks if we are able to survive a result from a background thread */
- (void)stringEchoInThread:(CDVInvokedUrlCommand*)command
{
    NSString* echo = [command.arguments objectAtIndex:0];
    __weak GeneroTestPlugin* weakSelf = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
      [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    });
}

/* checks if we are able to survive an evalJs from a background thread */
/* some IOS plugins do *not* return a result, instead they are */
/* calling evalJs from arbitrary background threads */
- (void)evalJsInThread:(CDVInvokedUrlCommand*)command
{
    __weak GeneroTestPlugin* weakSelf = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
      [weakSelf.commandDelegate evalJs:@"console.log('evalJs');testFunc();"];
    });
}

- (void)intPlus:(CDVInvokedUrlCommand*)command
{
    id idArg = [command.arguments objectAtIndex:0];
    if (![idArg isKindOfClass:NSNumber.class]) {
      [self sendStringError:s_arg_no_num callbackId:command.callbackId];
      return;
    }
    NSNumber* arg = (NSNumber*)idArg;
    int value=arg.intValue;
    value=value+1;
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:value];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)doublePlus:(CDVInvokedUrlCommand*)command
{
    id idArg = [command.arguments objectAtIndex:0];
    if (![idArg isKindOfClass:NSNumber.class]) {
      [self sendStringError:s_arg_no_num callbackId:command.callbackId];
      return;
    }
    NSNumber* arg = (NSNumber*)idArg;
    double value=arg.doubleValue;
    value=value+0.1;
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:value];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)testRecord:(CDVInvokedUrlCommand*)command
{
    id idArg = [command.arguments objectAtIndex:0];
    if (![idArg isKindOfClass:NSDictionary.class]) {
      [self sendStringError:@"Argument is not a Dictionary." callbackId:command.callbackId];
      return;
    }
    NSDictionary* arg = (NSDictionary*)idArg;
    NSMutableDictionary* value=[NSMutableDictionary dictionaryWithDictionary:arg];
    [value setObject:@"testSeen" forKey:@"test"];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:value];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)testArray:(CDVInvokedUrlCommand*)command
{
    id idArg = [command.arguments objectAtIndex:0];
    if (![idArg isKindOfClass:NSArray.class]) {
      [self sendStringError:@"Argument is not an Array." callbackId:command.callbackId];
      return;
    }
    NSArray* arg = (NSArray*)idArg;
    NSMutableArray* value=[NSMutableArray arrayWithArray:arg];
    NSDictionary* dict=@{
        @"i" : @(10),
        @"str" : @"str10"
    };
    [value addObject:dict];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:value];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)testData:(CDVInvokedUrlCommand*)command
{
    NSData* value=[@"test" dataUsingEncoding:NSUTF8StringEncoding];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArrayBuffer:value];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)testBg:(CDVInvokedUrlCommand*)command
{
    NSString* arg = [command.arguments objectAtIndex:0];
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:arg];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)startBgTimer:(CDVInvokedUrlCommand*)command
{
  _testCount=0;
  __weak GeneroTestPlugin* weakSelf=self;
  id idArg = [command.arguments objectAtIndex:0];
  if (![idArg isKindOfClass:NSNumber.class]) {
    [self sendStringError:s_arg_no_num callbackId:command.callbackId];
    return;
  }
  NSNumber* arg = (NSNumber*)idArg;
  double interval=arg.doubleValue;
  _timer = [NSTimer scheduledTimerWithTimeInterval:interval
     target:[NSBlockOperation blockOperationWithBlock:^{
       CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:weakSelf.testCount];
       weakSelf.testCount=weakSelf.testCount+1;
       [weakSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
     }] selector:@selector(main) userInfo:nil repeats:YES];
}

- (void)stopBgTimer:(CDVInvokedUrlCommand*)command
{
  [_timer invalidate];
  _timer=nil;
  CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:_testCount];
  [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)testStringError:(CDVInvokedUrlCommand*)command
{
    NSString* arg = [command.arguments objectAtIndex:0];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:arg];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendStringError:(NSString*)err callbackId:(NSString*)callbackId
{
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:err];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)testDictionaryError:(CDVInvokedUrlCommand*)command
{
    NSDictionary* arg = [command.arguments objectAtIndex:0];
    NSMutableDictionary* value=[NSMutableDictionary dictionaryWithDictionary:arg];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:value];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)testIntError:(CDVInvokedUrlCommand*)command
{
    id idArg = [command.arguments objectAtIndex:0];
    if (![idArg isKindOfClass:NSNumber.class]) {
      [self sendStringError:s_arg_no_num callbackId:command.callbackId];
      return;
    }
    NSNumber* arg = (NSNumber*)idArg;
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:arg.intValue];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)testGetSetting:(CDVInvokedUrlCommand*)command
{
    NSString* key = [[command.arguments objectAtIndex:0] lowercaseString];
    //we are using the undocumented method call [self commandDelegate] here
    //instead of self.commandDelegate because CDVBarcodeScanner uses it too,
    //so we ensure plugins compile using that API
    NSString* value= [[self commandDelegate].settings objectForKey:key];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:value];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)testIsNull:(CDVInvokedUrlCommand*)command
{
    id idArg = [command.arguments objectAtIndex:0];
    BOOL isNull= (idArg==[NSNull null]);
    id idTest = [command argumentAtIndex:0 withDefault:nil];
    if (isNull && idTest!=nil) {
      [self sendStringError:@"argumentAtIndex with default not working" callbackId:command.callbackId];
      return;
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isNull];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
