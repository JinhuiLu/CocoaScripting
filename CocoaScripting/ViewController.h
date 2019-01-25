//
//  ViewController.h
//  CocoaScripting
//
//  Created by lujh on 2019/1/23.
//  Copyright © 2019 mob. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Person;
@class Pair;

@interface ViewController : NSViewController <NSApplicationDelegate>

@property (nonatomic, strong) NSMutableArray <Person *>*persons;
@property (nonatomic, strong) NSMutableArray <Pair *>*pairs;

- (void)pair:(Person*)p1 with:(Person*)p2;
- (BOOL)existsPersonWithName:(NSString *)name;

@end

