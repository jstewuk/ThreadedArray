//
//  ThreadedArrayIncrementerTests.m
//  ThreadedArrayTests
//
//  Created by James Stewart on 8/31/13.
//  Copyright (c) 2013 StewartStuff. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "ThreadedArrayIncrementer.h"

/*
 In a relevant language, create an array of 1000 numbers. Initialize all of the values in the array to zero. 
 Create two threads that run concurrently and which increment each element of the array one time. When both
 threads have finished running, all elements in the array should have the value of two. Verify this.
 */

/* Tests:
 - can create/alloc an array
 - can increment on two threads
 Acceptance
 - after both threads complete increment, verify each array element == 2 (or sum = size * 2)
*/

#define SIZE 1000

@interface ThreadedArrayIncrementerTests : SenTestCase
@end

@implementation ThreadedArrayIncrementerTests {
    ThreadedArrayIncrementer *_incrementer;
}

- (void)setUp {
    [super setUp];
    _incrementer = [[ThreadedArrayIncrementer alloc] initWithNumberOfItems:SIZE];
 }

- (void)tearDown {
    _incrementer = nil;
    [super tearDown];
}

- (void)testThatCanCreateAnIncrementer {
    STAssertNotNil(_incrementer, @"should be able to create an incrementer");
}

- (void)testThatCanIncrementOnTwoThreadsSynchronized {
    NSInteger sum = [_incrementer sumOfArrayItemsAfterIncrementArrayWithTwoThreadsSynchronized];
    STAssertEquals(sum, SIZE * 2, @"sum after incrementing should equal 2 * SIZE");
}

- (void)testThatCanIncrementOnTwoThreadsOSAtomic {
    NSInteger sum = [_incrementer sumOfArrayItemsAfterIncrementArrayWithTwoThreadsOSAtomic];
    STAssertEquals(sum, SIZE * 2, @"sum after incrementing should equal 2 * SIZE");
}


@end
