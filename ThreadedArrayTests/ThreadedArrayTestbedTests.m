//
//  ThreadedArrayTestbedTests.m
//  ThreadedArrayTestBedTests
//
//  Empirical tests that synchronization,locking and OSAtomicIncrementer work.
//  May have to increase size to see thread contention and get the unsyncronized test
//  to fail
//
//
//  Created by James Stewart on 8/31/13.
//  Copyright (c) 2013 StewartStuff. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <libkern/OSAtomic.h>

/*
 In a relevant language, create an array of 1000 numbers. Initialize all of the values in the array to zero. 
 Create two threads that run concurrently and which increment each element of the array one time. When both
 threads have finished running, all elements in the array should have the value of two. Verify this.
 */

/* Tests:
 - can create/alloc and array
 - can increment the ints in the array
 - can increment on a new thread
 - can increment on a second thread
 - after both threads complete increment, verify each array element == 2 (or sum = size * 2)
*/
#define SIZE 1000

@interface ThreadedArrayTestBedTests : SenTestCase
@end

@implementation ThreadedArrayTestBedTests {
    int *_p_array;
    NSThread *_threadOne;
    NSThread *_threadTwo;
    NSLock *_lock;
    BOOL _debug;
    void (*_incrementFunction)(id self_, int index);
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

    _lock = [[NSLock alloc] init];
}

- (void)tearDown {
    free(_p_array);
    _threadOne = nil;
    _threadTwo = nil;
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


#pragma mark - C stuff
- (void)forwardLoopWrapper {
    forwardLoop(self, _incrementFunction);
}

- (void)reverseLoopWrapper {
    reverseLoop(self, _incrementFunction);
}

void forwardLoop( id _self, void (*incrementFunction)(id self_, int index) ) {
    for (int index = 0; index < SIZE; ++ index) {
        incrementFunction(_self, index);
    }
}

void reverseLoop( id _self, void (*incrementFunction)(id self_, int index) ) {
    for (int index = SIZE - 1; index >= 0; --index) {
        incrementFunction(_self, index);
    }
}

void NSLockIncrement(ThreadedArrayTestBedTests* self_, int index) {
    int * item = & self_->_p_array[index];
    [self_->_lock lock];
    ++(*item);
    [self_->_lock unlock];
}

void synchroIncrement (ThreadedArrayTestBedTests* self_, int index) {
    int * item = & self_->_p_array[index];
    @synchronized(self_) {
        ++(*item);
    }
}

void myOSAtomicIncrement(ThreadedArrayTestBedTests* self_, int index) {
    int * item = & self_->_p_array[index];
    OSAtomicIncrement32(item);
}

void unsynchroIncrement(ThreadedArrayTestBedTests* self_, int index) {
    ++(self_->_p_array[index]);
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


#pragma mark - TDD

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



- (void)incrementTwoThreadsWithCUsingIncrementFunction {
    if (_incrementFunction == nil) _incrementFunction = synchroIncrement;
    
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self
                                                selector:@selector(forwardLoopWrapper)
                                                  object:nil];
    NSThread *thread2 = [[NSThread alloc] initWithTarget:self
                                                selector:@selector(forwardLoopWrapper)
                                                  object:nil];
    [thread1 start];
    [thread2 start];
    while ([thread1 isExecuting] || [thread2 isExecuting]) {
        ;
    }
    int sum = [self sumOfArrayItems];
    if (sum != 2 * SIZE) {
        NSLog(@"sum is: %d, expected %d", sum, 2 * SIZE);
    }
    STAssertTrue(sum == SIZE * 2, @"sum of array ints after both threads increment should equal twice array size");
}

- (void)testIncrementingTwoThreadsWithCUsingSynchro {
    _incrementFunction = synchroIncrement;
    [self incrementTwoThreadsWithCUsingIncrementFunction];
}

- (void)testIncrementingTwoThreadsWithCUsingNSLock {
    _incrementFunction = NSLockIncrement;
    [self incrementTwoThreadsWithCUsingIncrementFunction];
}

- (void)testIncrementingTwoThreadsWithCUsingOSAtomicIncrement {
    _incrementFunction = myOSAtomicIncrement;
    [self incrementTwoThreadsWithCUsingIncrementFunction];
}

- (void)testCanIncrementOnTwoThreadsSimultaneouslyWithoutSync {
    _incrementFunction = unsynchroIncrement;
    [self incrementTwoThreadsWithCUsingIncrementFunction];
}

- (void)testMultipleRunsOfIncrementWithoutSync {
    _debug = YES;
    for (int i = 0; i < 10000; ++i) {
        [self testCanIncrementOnTwoThreadsSimultaneouslyWithoutSync];
        [self tearDown];
        [self setUp];
    }
    _debug = NO;
}

- (void)testMultipleRunsOfIncrementWithpNSLock {
    _debug = YES;
    for (int i = 0; i < 10000; ++i) {
        [self testIncrementingTwoThreadsWithCUsingNSLock];
        [self tearDown];
        [self setUp];
    }
    _debug = NO;
}



@end
