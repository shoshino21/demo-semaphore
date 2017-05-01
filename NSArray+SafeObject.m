//
//  NSArray+SafeObject.m
//  demo-semaphore
//
//  Created by shoshino21 on 5/1/17.
//  Copyright © 2017 shoshino21. All rights reserved.
//

#import "NSArray+SafeObject.h"

@implementation NSArray (SafeObject)

- (id)sho_safeObjectAtIndex:(NSInteger)index {
  return (index >= 0 && index < self.count) ? [self objectAtIndex:index] : nil;
}

@end
