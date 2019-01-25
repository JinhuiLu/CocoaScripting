//
//  Person.h
//  CocoaScripting
//
//  Created by lujh on 2019/1/23.
//  Copyright © 2019 mob. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, Gender) {
    GenderMale = 'gMAL',
    GenderFemale = 'gFEM',
};

@class Pair;
@class ViewController;

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) Gender gender;
@property (nonatomic, strong) Pair *pair;
@property (nonatomic, strong) ViewController *master;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) NSInteger cardID;

@end

NS_ASSUME_NONNULL_END
