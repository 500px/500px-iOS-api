//
//  _00px_iOS_apiTests.m
//  500px-iOS-apiTests
//
//  Created by Ash Furrow on 12-07-27.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "_00px_iOS_apiTests.h"
#import "PXAPIHelper.h"

@implementation _00px_iOS_apiTests
{
    PXAPIHelper *helper;
}

- (void)setUp
{
    [super setUp];
    
    helper = [[PXAPIHelper alloc] init];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

#pragma mark - Helper Methods

-(NSDictionary *)jsonDictionaryForRequest:(NSURLRequest *)urlRequest expectingResponseCode:(NSInteger)httpResponseCode
{
    NSHTTPURLResponse *returnResponse;
    NSError *connectionError;
    NSData *returnedData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&returnResponse error:&connectionError];
    
    if (connectionError)
    {
        STFail(@"Connection returned error: %@", connectionError);
        return nil;
    }
    
    if (returnResponse.statusCode != httpResponseCode)
    {
        STFail(@"Connection returned response code %d but we were expecting %d", returnResponse.statusCode, httpResponseCode);
        return nil;
    }
    
    NSError *jsonParseError;
    NSDictionary *returnedDictionary = [NSJSONSerialization JSONObjectWithData:returnedData options:0 error:&jsonParseError];
    
    return returnedDictionary;
}

-(void)testForNonNillResponse
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotos] expectingResponseCode:200];
    
    STAssertNotNil(dictionary, @"API returned nil response");
}

-(void)testForDefaultFeature
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotos] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"popular", @"Default photo stream request not returning popular, the default feature");
}

-(void)testForDefaultResultsPageSize
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotos] expectingResponseCode:200];
    
    NSInteger numberOfReturnedPhotos = [[dictionary valueForKey:@"photos"] count];
    
    STAssertEquals(numberOfReturnedPhotos, kPXAPIHelperDefaultResultsPerPage, @"Default photo stream request returning %d photos, not the default page size of %d", numberOfReturnedPhotos, kPXAPIHelperDefaultResultsPerPage);
}

-(void)testForDefaultPageNumber
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotos] expectingResponseCode:200];
    
    NSInteger returnedPageNumber = [[dictionary valueForKey:@"current_page"] intValue];
    
    STAssertEquals(returnedPageNumber, 1, @"Default photo stream request returning page %d, not the default page of 1", returnedPageNumber);
}

-(void)testForExcludeNude
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotoFeature:kPXAPIHelperDefaultFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage pageNumber:1 photoSizes:kPXAPIHelperDefaultPhotoSize sortOrder:kPXAPIHelperDefaultSortOrder except:PXPhotoModelCategoryNude] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.exclude"] intValue], PXPhotoModelCategoryNude, @"API Request exlucding nude photographs contains unfiltered results");
}

-(void)testForOnlyLanscapes
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotoFeature:kPXAPIHelperDefaultFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage pageNumber:1 photoSizes:kPXAPIHelperDefaultPhotoSize sortOrder:kPXAPIHelperDefaultSortOrder except:PXAPIHelperUnspecifiedCategory only:PXPhotoModelCategoryLandscapes] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.category"] intValue], PXPhotoModelCategoryLandscapes, @"API Request including only landscape photographs contains unfiltered results");
}

//TODO: Pending a merge from preproduction being pushed live
//-(void)testForDefaultImageSize
//{
//    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotos] expectingResponseCode:200];
//    NSLog(@"%@", dictionary);
//    STAssertTrue([dictionary valueForKeyPath:@"photos.images"], <#description, ...#>)
//}

@end
