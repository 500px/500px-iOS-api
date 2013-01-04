//
//  PXPXRequestTests.m
//  PXAPI
//
//  Created by Ash Furrow on 2013-01-03.
//  Copyright (c) 2013 500px. All rights reserved.
//

#import "PXPXRequestTests.h"

#import "OCMock.h"

#import "PXRequest.h"

@interface PXRequest (UnitTestAdditions)

-(NSURLConnection *)urlConnectionForURLRequest:(NSURLRequest *)request;
-(id)initWithURLRequest:(NSURLRequest *)urlRequest completion:(PXRequestCompletionBlock)completion;

@end

@implementation PXPXRequestTests

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

-(void)testCompletionBlockIsCalledOnConnectionFailure
{
    __block BOOL completionBlockInvoked = NO;
    
    NSURLRequest *dummyURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com"]];
    PXRequest *requestUnderTest = [[PXRequest alloc] initWithURLRequest:dummyURLRequest completion:^(NSDictionary *results, NSError *error) {
        
        completionBlockInvoked = YES;
        
        STAssertNotNil(error, @"Completion block should have error on connection failure, but doesn't.");
        STAssertNil(results, @"Completion block should not have results for failed connection.");
    }];
    
    id mockConnection = [OCMockObject niceMockForClass:[NSURLConnection class]];
    [[mockConnection expect] start];
    [[mockConnection expect] cancel];
    
    id partialRequestMock = (PXRequest *)[OCMockObject partialMockForObject:requestUnderTest];
    [[[partialRequestMock stub] andReturn:mockConnection] urlConnectionForURLRequest:OCMOCK_ANY];
    
    id mockResponse = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[mockResponse expect] andReturnValue:@(404)] statusCode];
    
    [partialRequestMock start];
    [partialRequestMock connection:mockConnection didReceiveResponse:mockResponse];
    
    [mockConnection verify];
    STAssertTrue(completionBlockInvoked, @"Completion block was not invoked when connection failed.");
}

@end
