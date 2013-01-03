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
    NSURLRequest *dummyURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"any string"]];
    PXRequest *requestUnderTest = [[PXRequest alloc] initWithURLRequest:dummyURLRequest completion:nil];
    
    id mockConnection = [OCMockObject niceMockForClass:[NSURLConnection class]];
    [[mockConnection expect] start];
    
    id partialRequestMock = (PXRequest *)[OCMockObject partialMockForObject:requestUnderTest];
    [[[partialRequestMock stub] andReturn:mockConnection] urlConnectionForURLRequest:OCMOCK_ANY];
    
    [partialRequestMock start];
    
    [mockConnection verify];
}

@end
