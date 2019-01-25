//
//  Pair.h
//  CocoaScripting
//
//  Created by lujh on 2019/1/23.
//  Copyright © 2019 mob. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Person;
NS_ASSUME_NONNULL_BEGIN

@interface Pair : NSObject

@property (nonatomic, strong) Person *person1;
@property (nonatomic, strong) Person *person2;

@end

NS_ASSUME_NONNULL_END
