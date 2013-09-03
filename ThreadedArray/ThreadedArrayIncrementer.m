//
//  ThreadedArrayIncrementer.m
//  ThreadedArray
//
//  Created by James Stewart on 9/2/13.
//  Copyright (c) 2013 StewartStuff. All rights reserved.
//

#import "ThreadedArrayIncrementer.h"
#import <libkern/OSAtomic.h>

@implementation ThreadedArrayIncrementer {
    NSUInteger _numberOfItems;
    int *_p_array;
    NSThread *_thread1;
    NSThread *_thread2;
}

- (id)initWithNumberOfItems:(NSUInteger)numberOfItems {
    self = [super init];
    if (self) {
        _numberOfItems = numberOfItems;
        _p_array = calloc(sizeof(int), numberOfItems);
    }
    return self;
}

- (void)dealloc {
    free(_p_array);
}

- (NSInteger)sumOfArrayItemsAfterIncrementArrayWithTwoThreadsSynchronized {
    [self createThreadsWithSelector:@selector(incrementArrayItemsSynchronized)];
    [self startThreads];
    [self waitForThreadsToFinish];
    NSInteger sum = [self sumOfArrayItems];
    return sum;
}

- (NSInteger)sumOfArrayItemsAfterIncrementArrayWithTwoThreadsOSAtomic {
    [self createThreadsWithSelector:@selector(incrementArrayItemsOSAtomic)];
    [self startThreads];
    [self waitForThreadsToFinish];
    NSInteger sum = [self sumOfArrayItems];
    return sum;
}

- (void)createThreadsWithSelector:(SEL)selector {
    _thread1 = [[NSThread alloc] initWithTarget:self
                                       selector:selector
                                         object:nil];
    _thread2 = [[NSThread alloc] initWithTarget:self
                                       selector:selector
                                         object:nil];
}

- (void)startThreads {
    [_thread1 start];
    [_thread2 start];
}

- (void)waitForThreadsToFinish {
    while ([_thread1 isExecuting] || [_thread2 isExecuting]) {
        ;
    }
}

- (int) sumOfArrayItems {
    int sum = 0;
    for (int index = 0; index < _numberOfItems; ++ index) {
        sum += _p_array[index];
    }
    return sum;
}


- (void)incrementArrayItemsSynchronized {
    for (int index = 0; index < _numberOfItems; ++index){
        int * item = & _p_array[index];
        @synchronized(self) {
            ++(*item);
        }
    }
}

- (void)incrementArrayItemsOSAtomic {
    for (int index = 0; index < _numberOfItems; ++index){
        int * item = & _p_array[index];
        OSAtomicIncrement32(item);
    }
}

@end
