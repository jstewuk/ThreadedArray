//
//  ThreadedArrayIncrementer.h
//  ThreadedArrayIncrementer
//
//  Created by James Stewart on 9/2/13.
//  Copyright (c) 2013 StewartStuff. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Class that allows two threads to simultaneously increment an array
 Satisfies:
 In a relevant language, create an array of 1000 numbers. Initialize all of the values in the array to zero.
 Create two threads that run concurrently and which increment each element of the array one time. When both
 threads have finished running, all elements in the array should have the value of two. Verify this.
 */
@interface ThreadedArrayIncrementer : NSObject
/**
 @param numberOfItems the number of items in the array
 */
- (id)initWithNumberOfItems:(NSUInteger)numberOfItems;

/**
 Returns the sum of the array items after both threads have finished incrementing
 using locking (@synchronized)
 */
- (NSInteger)sumOfArrayItemsAfterIncrementArrayWithTwoThreadsSynchronized;

/** 
 Returns the sume of the array items after both threads have finished incrementing
 using OSAtomic incrementing
 */
- (NSInteger)sumOfArrayItemsAfterIncrementArrayWithTwoThreadsOSAtomic;
@end
