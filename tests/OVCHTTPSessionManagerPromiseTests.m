//
//  OVCHTTPSessionManagerPromiseTests.m
//  Overcoat
//
//  Created by guille on 26/05/14.
//  Copyright (c) 2014 Guillermo Gonzalez. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OHHTTPStubs/HTTPStubs.h>
#import <OHHTTPStubs/HTTPStubsPathHelpers.h>
#import <Overcoat/Overcoat.h>
#import <OvercoatPromiseKit/OvercoatPromiseKit.h>
#import <PromiseKit/PromiseKit.h>

#import "OVCTestModel.h"

#pragma mark - PromiseSessionManager

@interface PromiseSessionManager : OVCHTTPSessionManager

@end

@implementation PromiseSessionManager

+ (NSDictionary *)errorModelClassesByResourcePath {
    return @{@"**": [OVCErrorModel class]};
}

+ (NSDictionary *)modelClassesByResourcePath {
    return @{
        @"model/#": [OVCTestModel class],
        @"models": @{
            @201: [OVCTestModel2 class],
            @"*": [OVCTestModel class],
        },
    };
}

@end

#pragma mark - OVCHTTPSessionManagerPromiseTests

@interface OVCHTTPSessionManagerPromiseTests : XCTestCase

@property (strong, nonatomic) PromiseSessionManager *client;

@end

@implementation OVCHTTPSessionManagerPromiseTests

- (void)setUp {
    [super setUp];
    self.client = [[PromiseSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://test/v1/"]];
}

- (void)tearDown {
    [self.client invalidateSessionCancelingTasks:YES resetSession:YES];
    
    self.client = nil;
    [HTTPStubs removeAllStubs];
    
    [super tearDown];
}

- (void)testGET {
    NSURLRequest * __block request = nil;
    
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *r) {
        request = r;
        return YES;
    } withStubResponse:^HTTPStubsResponse *(NSURLRequest *request) {
        NSString * path = OHPathForFile(@"model.json", self.class);
        return [HTTPStubsResponse responseWithFileAtPath:path
                                                statusCode:200
                                                   headers:@{@"Content-Type": @"application/json"}];
    }];
    
    XCTestExpectation *completed = [self expectationWithDescription:@"completed"];
    OVCResponse * __block response = nil;
    
    [self.client pmk_GET:@"model/42" parameters:nil].then(^(OVCResponse *r) {
        response = r;
        [completed fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertTrue([response.result isKindOfClass:[OVCTestModel class]], @"should return a test model");
    
    XCTAssertEqualObjects(@"GET", request.HTTPMethod, @"should send a GET request");
}

- (void)testGETServerError {
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^HTTPStubsResponse *(NSURLRequest *request) {
        NSString * path = OHPathForFile(@"error.json", self.class);
        return [HTTPStubsResponse responseWithFileAtPath:path
                                                statusCode:401
                                                   headers:@{@"Content-Type": @"application/json"}];
    }];
    
    XCTestExpectation *completed = [self expectationWithDescription:@"completed"];
    NSError * __block error = nil;
    
    [self.client pmk_GET:@"model/42" parameters:nil].catch(^(NSError *e) {
        error = e;
        [completed fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OVCResponse *response = error.ovc_response;
    XCTAssertTrue([response.result isKindOfClass:[OVCErrorModel class]], @"should return an error model");
}

- (void)testHEAD {
    NSURLRequest * __block request = nil;
    
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *r) {
        request = r;
        return YES;
    } withStubResponse:^HTTPStubsResponse *(NSURLRequest *request) {
        return [HTTPStubsResponse responseWithData:[NSData data]
                                          statusCode:200
                                             headers:@{@"Content-Type": @"application/json"}];
    }];
    
    XCTestExpectation *completed = [self expectationWithDescription:@"completed"];
    OVCResponse * __block response = nil;
    
    [self.client pmk_HEAD:@"models" parameters:@{@"foo": @"bar"}].then(^(OVCResponse *r) {
        response = r;
        [completed fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertNil(response.result, @"should return an empty response");
    
    XCTAssertEqualObjects(@"HEAD", request.HTTPMethod, @"should send a HEAD request");
}

- (void)testPOST {
    NSURLRequest * __block request = nil;
    
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *r) {
        request = r;
        return YES;
    } withStubResponse:^HTTPStubsResponse *(NSURLRequest *request) {
        NSString * path = OHPathForFile(@"model.json", self.class);
        return [HTTPStubsResponse responseWithFileAtPath:path
                                                statusCode:201
                                                   headers:@{@"Content-Type": @"application/json"}];
    }];
    
    XCTestExpectation *completed = [self expectationWithDescription:@"completed"];
    OVCResponse * __block response = nil;
    
    [self.client pmk_POST:@"models" parameters:@{@"name": @"Iron Man"}].then(^(OVCResponse *r) {
        response = r;
        [completed fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertTrue([response.result isKindOfClass:[OVCTestModel2 class]], @"should return a test model");
    
    XCTAssertEqualObjects(@"POST", request.HTTPMethod, @"should send a POST request");
}

- (void)testPOSTServerError {
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^HTTPStubsResponse *(NSURLRequest *request) {
        NSString * path = OHPathForFile(@"error.json", self.class);
        return [HTTPStubsResponse responseWithFileAtPath:path
                                                statusCode:401
                                                   headers:@{@"Content-Type": @"application/json"}];
    }];
    
    XCTestExpectation *completed = [self expectationWithDescription:@"completed"];
    NSError * __block error = nil;
    
    [self.client pmk_POST:@"models" parameters:@{@"name": @"Iron Man"}].catch(^(NSError *e) {
        error = e;
        [completed fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OVCResponse *response = error.ovc_response;
    XCTAssertTrue([response.result isKindOfClass:[OVCErrorModel class]], @"should return an error model");
}

- (void)testPUT {
    NSURLRequest * __block request = nil;
    
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *r) {
        request = r;
        return YES;
    } withStubResponse:^HTTPStubsResponse *(NSURLRequest *request) {
        NSString * path = OHPathForFile(@"model.json", self.class);
        return [HTTPStubsResponse responseWithFileAtPath:path
                                                statusCode:200
                                                   headers:@{@"Content-Type": @"application/json"}];
    }];
    
    XCTestExpectation *completed = [self expectationWithDescription:@"completed"];
    OVCResponse * __block response = nil;
    
    [self.client pmk_PUT:@"model/42" parameters:@{@"name": @"Golden Avenger"}].then(^(OVCResponse *r) {
        response = r;
        [completed fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertTrue([response.result isKindOfClass:[OVCTestModel class]], @"should return a test model");
    
    XCTAssertEqualObjects(@"PUT", request.HTTPMethod, @"should send a PUT request");
}

- (void)testPUTServerError {
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^HTTPStubsResponse *(NSURLRequest *request) {
        NSString * path = OHPathForFile(@"error.json", self.class);
        return [HTTPStubsResponse responseWithFileAtPath:path
                                                statusCode:401
                                                   headers:@{@"Content-Type": @"application/json"}];
    }];
    
    XCTestExpectation *completed = [self expectationWithDescription:@"completed"];
    NSError * __block error = nil;
    
    [self.client pmk_PUT:@"model/42" parameters:@{@"name": @"Golden Avenger"}].catch(^(NSError *e) {
        error = e;
        [completed fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OVCResponse *response = error.ovc_response;
    XCTAssertTrue([response.result isKindOfClass:[OVCErrorModel class]], @"should return an error model");
}

- (void)testPATCH {
    NSURLRequest * __block request = nil;
    
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *r) {
        request = r;
        return YES;
    } withStubResponse:^HTTPStubsResponse *(NSURLRequest *request) {
        NSString * path = OHPathForFile(@"model.json", self.class);
        return [HTTPStubsResponse responseWithFileAtPath:path
                                                statusCode:200
                                                   headers:@{@"Content-Type": @"application/json"}];
    }];
    
    XCTestExpectation *completed = [self expectationWithDescription:@"completed"];
    OVCResponse * __block response = nil;
    
    [self.client pmk_PATCH:@"model/42" parameters:@{@"name": @"Golden Avenger"}].then(^(OVCResponse *r) {
        response = r;
        [completed fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertTrue([response.result isKindOfClass:[OVCTestModel class]], @"should return a test model");
    
    XCTAssertEqualObjects(@"PATCH", request.HTTPMethod, @"should send a PATCH request");
}

- (void)testPATCHServerError {
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^HTTPStubsResponse *(NSURLRequest *request) {
        NSString * path = OHPathForFile(@"error.json", self.class);
        return [HTTPStubsResponse responseWithFileAtPath:path
                                                statusCode:401
                                                   headers:@{@"Content-Type": @"application/json"}];
    }];
    
    XCTestExpectation *completed = [self expectationWithDescription:@"completed"];
    NSError * __block error = nil;
    
    [self.client pmk_PATCH:@"model/42" parameters:@{@"name": @"Golden Avenger"}].catch(^(NSError *e) {
        error = e;
        [completed fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OVCResponse *response = error.ovc_response;
    XCTAssertTrue([response.result isKindOfClass:[OVCErrorModel class]], @"should return an error model");
}

- (void)testDELETE {
    NSURLRequest * __block request = nil;
    
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *r) {
        request = r;
        return YES;
    } withStubResponse:^HTTPStubsResponse *(NSURLRequest *request) {
        NSString * path = OHPathForFile(@"model.json", self.class);
        return [HTTPStubsResponse responseWithFileAtPath:path
                                                statusCode:200
                                                   headers:@{@"Content-Type": @"application/json"}];
    }];
    
    XCTestExpectation *completed = [self expectationWithDescription:@"completed"];
    OVCResponse * __block response = nil;
    
    [self.client pmk_DELETE:@"model/42" parameters:nil].then(^(OVCResponse *r) {
        response = r;
        [completed fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertTrue([response.result isKindOfClass:[OVCTestModel class]], @"should return a test model");
    
    XCTAssertEqualObjects(@"DELETE", request.HTTPMethod, @"should send a DELETE request");
}

- (void)testDELETEServerError {
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^HTTPStubsResponse *(NSURLRequest *request) {
        NSString * path = OHPathForFile(@"error.json", self.class);
        return [HTTPStubsResponse responseWithFileAtPath:path
                                                statusCode:401
                                                   headers:@{@"Content-Type": @"application/json"}];
    }];
    
    XCTestExpectation *completed = [self expectationWithDescription:@"completed"];
    NSError * __block error = nil;
    
    [self.client pmk_DELETE:@"model/42" parameters:nil].catch(^(NSError *e) {
        error = e;
        [completed fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OVCResponse *response = error.ovc_response;
    XCTAssertTrue([response.result isKindOfClass:[OVCErrorModel class]], @"should return an error model");
}

@end
