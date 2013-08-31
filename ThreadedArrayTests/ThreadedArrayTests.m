//
//  ThreadedArrayTests.m
//  ThreadedArrayTests
//
//  Created by James Stewart on 8/31/13.
//  Copyright (c) 2013 StewartStuff. All rights reserved.
//

#import "ThreadedArrayTests.h"

/*
 In a relevant language, create an array of 1000 numbers. Initialize all of the values in the array to zero. Create two threads that run concurrently and which increment each element of the array one time. When both threads have finished running, all elements in the array should have the value of two. Verify this.
 */


@implementation ThreadedArrayTests

- (void)setUp {
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown {
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    STAssertTrue(YES, @"Should always pass");
}

@end
