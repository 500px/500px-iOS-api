//
//  PXTests.h
//  500px-iOS-apiTests
//
//  Created by Ash Furrow on 12-07-27.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "PXAPIHelper.h"
#import "OAuthCore.h"
#import "OAuth+Additions.h"
#import "PXAPIHelper+Auth.h"

#define kTestUserID     213451
#define kTestUserName   @"ashfurrow"
#define kTestUserEmail  @"ash.furrow@gmail.com"

#define kTestPhotoID    6617598

#define kUserNameForAuthentication  @"__CHANGE_ME__"
#define kPasswordForAuthentication  @"__CHANGE_ME__"

#define kPXAPIConsumerKey       @"__CHANGE_ME__"
#define kPXAPIConsumerSecret    @"__CHANGE_ME__"

@interface PXTests : SenTestCase

+(NSDictionary *)jsonDictionaryForRequest:(NSURLRequest *)urlRequest expectingResponseCode:(NSInteger)httpResponseCode;

@end
