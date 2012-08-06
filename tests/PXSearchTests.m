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

-(void)testForExcludeNude
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForSearchTerm:@"cats" page:1  resultsPerPage:kPXAPIHelperDefaultResultsPerPage photoSizes:kPXAPIHelperDefaultPhotoSize except:PXPhotoModelCategoryNude] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.exclude"] intValue], PXPhotoModelCategoryNude, @"API Request exlucding nude photographs contains unfiltered results");
}

-(void)testForOnlyLanscapes
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForSearchTerm:@"mountains" page:1  resultsPerPage:kPXAPIHelperDefaultResultsPerPage photoSizes:kPXAPIHelperDefaultPhotoSize except:PXPhotoModelCategoryNude] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.category"] intValue], PXPhotoModelCategoryLandscapes, @"API Request including only landscape photographs contains unfiltered results");
}


@end
