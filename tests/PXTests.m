//
//  PXTests.m
//  500px-iOS-apiTests
//
//  Created by Ash Furrow on 12-07-27.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXTests.h"

@implementation PXTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

#pragma mark - Helper Methods

+(NSDictionary *)jsonDictionaryForRequest:(NSURLRequest *)urlRequest expectingResponseCode:(NSInteger)httpResponseCode
{
    NSHTTPURLResponse *returnResponse;
    NSError *connectionError;
    NSData *returnedData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&returnResponse error:&connectionError];
    
    if (connectionError)
    {
        NSLog(@"Connection returned error: %@", connectionError);
        return nil;
    }
    
    if (returnResponse.statusCode != httpResponseCode)
    {
        NSLog(@"Connection returned response code %d but we were expecting %d", returnResponse.statusCode, httpResponseCode);
        return nil;
    }
    
    NSError *jsonParseError;
    NSDictionary *returnedDictionary = [NSJSONSerialization JSONObjectWithData:returnedData options:0 error:&jsonParseError];
    
    return returnedDictionary;
}

@end
