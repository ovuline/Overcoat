//
//  OVCResponseClassPerPathTest.m
//  Overcoat
//
//  Created by Elias Turbay on 21/09/14.
//  Copyright (c) 2014 Guillermo Gonzalez. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OHHTTPStubs/HTTPStubs.h>
#import <OHHTTPStubs/HTTPStubsPathHelpers.h>
#import <OVercoat/Overcoat.h>

#import "OVCTestModel.h"
#import "OVCTestResponse.h"
#import "OVCCustomEnvelopTestResponse.h"

#pragma mark - ResponseClassPerPathTest

@interface TestSessionManagerWithCustomResponseClassPerPath : OVCHTTPSessionManager

@end

@implementation TestSessionManagerWithCustomResponseClassPerPath

+ (NSDictionary *)errorModelClassesByResourcePath {
    return @{@"**": [OVCErrorModel class]};
}

+ (NSDictionary *)modelClassesByResourcePath {
    return @{
        @"model/#": [OVCTestModel class],
        @"models": [OVCTestModel class],
        @"model_with_custom_envelop/#": [OVCTestModel class]
    };
}

+ (NSDictionary *)responseClassesByResourcePath {
    return @{
        @"model/#": [OVCTestResponse class],
        @"models": [OVCTestResponse class],
        @"model_with_custom_envelop/#": [OVCCustomEnvelopTestResponse class]
    };
}

@end

#pragma mark - OVCResponseClassPerPathTest

@interface OVCResponseClassPerPathTest : XCTestCase

@property (strong, nonatomic) TestSessionManagerWithCustomResponseClassPerPath *client;

@end

@implementation OVCResponseClassPerPathTest

- (void)setUp {
    [super setUp];
    self.client = [[TestSessionManagerWithCustomResponseClassPerPath alloc]
                   initWithBaseURL:[NSURL URLWithString:@"http://test/v1/"]];
}

- (void)tearDown {
    [self.client invalidateSessionCancelingTasks:YES resetSession:YES];
    
    self.client = nil;
    [HTTPStubs removeAllStubs];
    
    [super tearDown];
}

- (void)testModelClassesByResourcePathMustBeOverridenBySubclass {
    XCTAssertThrows([OVCHTTPSessionManager modelClassesByResourcePath], @"should throw an exception");
}

- (void)testEnvelopOption1GET {
    NSURLRequest * __block request = nil;
    
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *r) {
        request = r;
        return YES;
    } withStubResponse:^HTTPStubsResponse *(NSURLRequest *request) {
        NSString * path = OHPathForFile(@"envelop1_model.json", self.class);
        return [HTTPStubsResponse responseWithFileAtPath:path
                                                statusCode:200
                                                   headers:@{@"Content-Type": @"application/json"}];
    }];
    
    XCTestExpectation *completed = [self expectationWithDescription:@"completed"];
    OVCResponse * __block response = nil;
    NSError * __block error = nil;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self.client GET:@"model/42" parameters:nil completion:^(OVCResponse *r, NSError *e) {
        response = r;
        error = e;
        [completed fulfill];
    }];
#pragma clang diagnostic pop

    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertNil(error, @"should not return an error");
    XCTAssertTrue([response.result isKindOfClass:[OVCTestModel class]], @"should return a test model");
    
    XCTAssertEqualObjects(@"GET", request.HTTPMethod, @"should send a GET request");
}

- (void)testEnvelopOption2GET {
    NSURLRequest * __block request = nil;
    
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *r) {
        request = r;
        return YES;
    } withStubResponse:^HTTPStubsResponse *(NSURLRequest *request) {
        NSString * path = OHPathForFile(@"envelop2_model.json", self.class);
        return [HTTPStubsResponse responseWithFileAtPath:path
                                                statusCode:200
                                                   headers:@{@"Content-Type": @"application/json"}];
    }];
    
    XCTestExpectation *completed = [self expectationWithDescription:@"completed"];
    OVCResponse * __block response = nil;
    NSError * __block error = nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self.client GET:@"model_with_custom_envelop/42" parameters:nil completion:^(OVCResponse *r, NSError *e) {
        response = r;
        error = e;
        [completed fulfill];
    }];
#pragma clang diagnostic pop

    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertNil(error, @"should not return an error");
    XCTAssertTrue([response.result isKindOfClass:[OVCTestModel class]], @"should return a test model");
    
    XCTAssertEqualObjects(@"GET", request.HTTPMethod, @"should send a GET request");
}

@end
