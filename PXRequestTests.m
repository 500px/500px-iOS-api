//
//  PXPXRequestTests.m
//  PXAPI
//
//  Created by Ash Furrow on 2013-01-03.
//  Copyright (c) 2013 500px. All rights reserved.
//

#import "PXRequestTests.h"

#import "OCMock.h"

#import "PXRequest.h"

@interface PXRequest (UnitTestAdditions)

-(NSURLConnection *)urlConnectionForURLRequest:(NSURLRequest *)request;
-(id)initWithURLRequest:(NSURLRequest *)urlRequest completion:(PXRequestCompletionBlock)completion;

+(void)generateNoConsumerKeyError:(PXRequestCompletionBlock)completionBlock;

@end

@implementation PXRequestTests

-(void)testURLConnectionStart
{
    NSURLRequest *dummyURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com"]];
    PXRequest *requestUnderTest = [[PXRequest alloc] initWithURLRequest:dummyURLRequest completion:nil];
    
    id mockConnection = [OCMockObject niceMockForClass:[NSURLConnection class]];
    [[mockConnection expect] start];
    
    id partialRequestMock = (PXRequest *)[OCMockObject partialMockForObject:requestUnderTest];
    [[[partialRequestMock stub] andReturn:mockConnection] urlConnectionForURLRequest:OCMOCK_ANY];
    
    [partialRequestMock start];
    
    [mockConnection verify];
}

-(void)testCompletionBlockIsCalledOnConnectionSuccess
{
    __block BOOL completionBlockInvoked = NO;
    
    NSURLRequest *dummyURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com"]];
    PXRequest *requestUnderTest = [[PXRequest alloc] initWithURLRequest:dummyURLRequest completion:^(NSDictionary *results, NSError *error) {
        
        completionBlockInvoked = YES;
        
        STAssertNil(error, @"Completion block should not have error on connection failure, but doesn't.");
        STAssertNotNil(results, @"Completion block should not have results for successful connection.");
    }];
    
    id mockConnection = [OCMockObject niceMockForClass:[NSURLConnection class]];
    [[mockConnection expect] start];
    
    id partialRequestMock = (PXRequest *)[OCMockObject partialMockForObject:requestUnderTest];
    [[[partialRequestMock stub] andReturn:mockConnection] urlConnectionForURLRequest:OCMOCK_ANY];
    
    id mockResponse = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[mockResponse expect] andReturnValue:@(200)] statusCode];
    
    NSData *jsonData = [@"{\"result\": true}" dataUsingEncoding:NSUTF8StringEncoding];
    
    [partialRequestMock start];
    [partialRequestMock connection:mockConnection didReceiveResponse:mockResponse];
    [partialRequestMock connection:mockConnection didReceiveData:jsonData];
    [partialRequestMock connectionDidFinishLoading:mockConnection];
    
    [mockConnection verify];
    STAssertTrue(completionBlockInvoked, @"Completion block was not invoked when connection failed.");
}

-(void)testCompletionBlockIsCalledOnConnectionFailure
{
    __block BOOL completionBlockInvoked = NO;
    
    NSURLRequest *dummyURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com"]];
    PXRequest *requestUnderTest = [[PXRequest alloc] initWithURLRequest:dummyURLRequest completion:^(NSDictionary *results, NSError *error) {
        
        completionBlockInvoked = YES;
        
        STAssertNil(error, @"Completion block should note have error on connection success.");
        STAssertNil(results, @"Completion block should not have results for failed connection.");
    }];
    
    id mockConnection = [OCMockObject niceMockForClass:[NSURLConnection class]];
    [[mockConnection expect] start];
    
    id partialRequestMock = (PXRequest *)[OCMockObject partialMockForObject:requestUnderTest];
    [[[partialRequestMock stub] andReturn:mockConnection] urlConnectionForURLRequest:OCMOCK_ANY];
    
    id mockResponse = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[mockResponse expect] andReturnValue:@(404)] statusCode];
    
    [partialRequestMock start];
    [partialRequestMock connectionDidFinishLoading:mockConnection];
    
    [mockConnection verify];
    STAssertTrue(completionBlockInvoked, @"Completion block was not invoked when connection failed.");
}

@end
