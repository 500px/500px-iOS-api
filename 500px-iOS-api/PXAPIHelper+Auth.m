//
//  PXAuthHelper.m
//  500px-iOS-api
//
//  Created by Ash Furrow on 2012-08-05.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXAPIHelper+Auth.h"
#import "OAuthCore.h"
#import "OAuth+Additions.h"

@implementation PXAPIHelper (Auth)

-(NSDictionary *)requestTokenAndSecret
{
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@oauth/request_token", @"https://api.500px.com/v1/"]];
    NSMutableURLRequest *requestTokenURLRequest = [NSMutableURLRequest requestWithURL:requestURL];
    [requestTokenURLRequest setHTTPMethod:@"POST"];
    
    NSString *requestTokenAuthorizationHeader = OAuthorizationHeader(requestURL, @"POST", nil, self.consumerKey, self.consumerSecret, nil, nil);
    
    [requestTokenURLRequest setHTTPMethod:@"POST"];
    [requestTokenURLRequest setValue:requestTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
    
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:requestTokenURLRequest returningResponse:&response error:&error];
    
    NSString *returnedRequestTokenString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //        NSLog(@"%@", returnedString);
    
    NSDictionary *returnedRequestTokenDictionary = [returnedRequestTokenString ab_parseURLQueryString];
    return returnedRequestTokenDictionary;
}

-(void)authenticate500pxUserName:(NSString *)username password:(NSString *)password
{
}

@end
