//
//  PXAuthTests.m
//  500px-iOS-api
//
//  Created by Ash Furrow on 2012-08-05.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXAuthTests.h"


@interface PXAPIHelper ()

-(NSDictionary *)requestTokenAndSecret;

@end

@implementation PXAuthTests
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

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

-(void)testForNonEmptyRequestToken
{
    NSDictionary *requestionTokenDictionary = [helper requestTokenAndSecret];
    
    STAssertNotNil(requestionTokenDictionary, @"Request token dictionary is nil");
    STAssertNotNil([requestionTokenDictionary valueForKey:@"oauth_token"], @"Empty oauth token returned");
    STAssertNotNil([requestionTokenDictionary valueForKey:@"oauth_token_secret"], @"Empty oauth token secret returned");
}

-(void)testForLogin
{
    NSDictionary *accessTokenDictionary = [helper authenticate500pxUserName:kUserNameForAuthentication password:kPasswordForAuthentication];
    
    STAssertNotNil(accessTokenDictionary, @"Access token dictionary is nil");
    STAssertNotNil([accessTokenDictionary valueForKey:@"oauth_token"], @"Empty oauth token returned");
    STAssertNotNil([accessTokenDictionary valueForKey:@"oauth_token_secret"], @"Empty oauth token secret returned");
}

@end
