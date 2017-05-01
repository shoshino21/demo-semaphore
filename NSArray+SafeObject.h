//
//  NSArray+SafeObject.h
//  demo-semaphore
//
//  Created by shoshino21 on 5/1/17.
//  Copyright © 2017 shoshino21. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (SafeObject)

- (id)sho_safeObjectAtIndex:(NSInteger)index;

@end
