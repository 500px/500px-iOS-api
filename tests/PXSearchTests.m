//
//  PXSearchTests.m
//  500px-iOS-api
//
//  Created by Ash Furrow on 2012-08-05.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXSearchTests.h"

@implementation PXSearchTests
{
    PXAPIHelper *helper;
}

- (void)setUp
{
    [super setUp];
    
    helper = [[PXAPIHelper alloc] initWithHost:nil
                                   consumerKey:kPXAPIConsumerKey
                                consumerSecret:kPXAPIConsumerSecret];
}

-(void)testForNilSearchTerm
{
    NSURLRequest *searchRequest = [helper urlRequestForSearchTerm:nil];
    STAssertNil(searchRequest, @"Search request is not nil despite nil search term.");
}

-(void)testForNilSearchTag
{
    NSURLRequest *searchRequest = [helper urlRequestForSearchTag:nil];
    STAssertNil(searchRequest, @"Search request is not nil despite nil search tag.");
}

-(void)testForDefaultPhotoSizes
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForSearchTerm:@"cats"] expectingResponseCode:200];
    
    STAssertTrue([[[[dictionary valueForKey:@"photos"] lastObject] valueForKey:@"images"] count] > 1, @"GET search returned only 1 or no photos jpegs");
}

@end
