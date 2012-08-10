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

#define kUserNameForAuthentication  @"ashfurrow"
#define kPasswordForAuthentication  @"P@ssword2"

#define kPXAPIConsumerKey       @"zEJa8SeeKpcrqQQfHGzDiKuuHRQssAS09ppVl7Kb"
#define kPXAPIConsumerSecret    @"VyJcaxeMcEnjDYO9OQLNYsbENNEDZ0pycTn7NTy2"

@interface PXTests : SenTestCase

+(NSDictionary *)jsonDictionaryForRequest:(NSURLRequest *)urlRequest expectingResponseCode:(NSInteger)httpResponseCode;

@end
