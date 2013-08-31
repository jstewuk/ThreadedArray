//
//  ThreadedArrayTests.m
//  ThreadedArrayTests
//
//  Created by James Stewart on 8/31/13.
//  Copyright (c) 2013 StewartStuff. All rights reserved.
//

#import "ThreadedArrayTests.h"
#import <libkern/OSAtomic.h>

/*
 In a relevant language, create an array of 1000 numbers. Initialize all of the values in the array to zero. Create two threads that run concurrently and which increment each element of the array one time. When both threads have finished running, all elements in the array should have the value of two. Verify this.
 */

/* Tests:
 - can create/alloc and array
 - can increment the ints in the array
 - can increment on a new thread
 - can increment on a second thread
 - after both threads complete increment, verify each array element == 2 (or sum = size * 2)
*/
#define SIZE 1000000

@implementation ThreadedArrayTests {
    int *_p_array;
    NSThread *_threadOne;
    NSThread *_threadTwo;
    NSThread *_threadThree;
    NSThread *_threadFour;
    NSLock *_lock;
    BOOL _debug;
}

- (void)setUp {
    [super setUp];
    _p_array = calloc(sizeof(int), SIZE);
    _threadOne = [[NSThread alloc] initWithTarget:self
                                        selector:@selector(incrementArrayOSAtomicForward)
                                          object:nil];
    _threadOne.name = @"Thr1";
    _threadTwo = [[NSThread alloc] initWithTarget:self
                                         selector:@selector(incrementArrayOSAtomicForward)
                                           object:nil];

    _threadTwo.name = @"Thr2";
    _threadThree = [[NSThread alloc] initWithTarget:self
                                         selector:@selector(incrementArrayUnsynched)
                                           object:nil];
    
    _threadThree.name = @"Thr3";
    _threadFour = [[NSThread alloc] initWithTarget:self
                                           selector:@selector(incrementArrayUnsynched)
                                             object:nil];
    
    _threadFour.name = @"Thr4";
    _lock = [[NSLock alloc] init];
}

- (void)tearDown {
    free(_p_array);
    _threadOne = nil;
    _threadTwo = nil;
    _threadThree = nil;
    _threadFour = nil;
    _lock = nil;
    [super tearDown];
}

- (int) sumOfArrayItems {
    int sum = 0;
    for (int index = 0; index < SIZE; ++ index) {
        if (_debug) {
            if(_p_array[index] != 2) NSLog(@"Not 2 index: %d", index);
        }
        sum += _p_array[index];
    }
    return sum;
}

void forwardLoop( void (*incrementFunction)() ) {
    for (int index = 0; index < SIZE; ++ index) {
        incrementFunction();
    }
}

void reverseLoop( void (*incrementFunction)() ) {
    for (int index = SIZE - 1; index >= 0; --index) {
        incrementFunction();
    }
}

void NSLockIncrement() {
    
}

void synchroIncrement () {
    
}

void myOSAtomicIncrement() {
    
}

void unsynchroIncrement() {
    
}

- (void) incrementArrayNSLockForward {
    for (int index = 0; index < SIZE; ++index){
        int * item = & _p_array[index];
        [_lock lock];
            ++(*item);
        [_lock unlock];
        //NSLog(@"on %@", [NSThread currentThread].name);
    }
}

- (void)incrementArrayNSLockReverse {
    for (int index = SIZE - 1; index >= 0; --index){
        int * item = & _p_array[index];
        [_lock lock];
            ++(*item);
        [_lock unlock];
        //NSLog(@"on %@", [NSThread currentThread].name);
    }
}

- (void)incrementArrayUnsynched {
    for (int index = SIZE - 1; index >= 0; --index){
        ++_p_array[index];
        //NSLog(@"on %@", [NSThread currentThread].name);
    }
}

- (void)incrementArraySynched {
    for (int index = 0; index < SIZE; ++index){
        int * item = & _p_array[index];
        @synchronized(self) {
            ++(*item);
        }
        //NSLog(@"on %@", [NSThread currentThread].name);
    }
}

- (void)incrementArrayOSAtomicForward {
    for (int index = 0; index < SIZE; ++index){
        int * item = & _p_array[index];
        OSAtomicIncrement32(item);
    }
}

- (void)incrementArrayOSAtomicReverse {
    for (int index = SIZE - 1; index >= 0; --index) {
        int * item = & _p_array[index];
        OSAtomicIncrement32(item);
    }
}


- (void)testCanCreateAnEmptyArray {
    STAssertTrue([self sumOfArrayItems] == 0, @"sum of array ints should equal zero initially");
}

- (void)testCanIncrementEachItemInArrayByOne {
    [self incrementArrayNSLockForward];
    STAssertTrue([self sumOfArrayItems] == SIZE * 1, @"sum of array ints after increment should equal array size");
}

- (void)testCanIncrementOnANewThread {
    [_threadOne start];
    while ([_threadOne isExecuting]) {
        ;
    }
    STAssertTrue([self sumOfArrayItems] == SIZE * 1, @"sum of array ints after threaded increment should equal array size");
}

- (void)testCanIncrementOnTwoThreadsSimultaneously {
    [_threadOne start];
    [_threadTwo start];
    while ([_threadOne isExecuting] || [_threadTwo isExecuting]) {
        ;
    }
    int sum = [self sumOfArrayItems];
    if (sum != 2 * SIZE) {
        NSLog(@"sum is: %d, expected %d", sum, 2 * SIZE);
    }
    STAssertTrue(sum == SIZE * 2, @"sum of array ints after both threads increment with sync should equal twice array size");
}

- (void)testMultipleRunsOfIncrement {
    _debug = YES;
    for (int i = 0; i < 2000; ++i) {
        [self testCanIncrementOnTwoThreadsSimultaneously];
        [self tearDown];
        [self setUp];
    }
    _debug = NO;
}

/*
- (void)testCanIncrementOnTwoThreadsSimultaneouslyWithoutSync {
    [_threadThree start];
    [_threadFour start];
    while ([_threadThree isExecuting] || [_threadFour isExecuting]) {
        ;
    }
    if ([self sumOfArrayItems] != 2 * SIZE) {
        NSLog(@"sum is: %d, expected %d", [self sumOfArrayItems], 2 * SIZE);
    }
    STAssertTrue([self sumOfArrayItems] == SIZE * 2, @"sum of array ints after both threads increment without sync should equal twice array size");
}
*/

@end
