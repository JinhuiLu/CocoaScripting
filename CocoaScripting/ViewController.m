//
//  ViewController.m
//  CocoaScripting
//
//  Created by lujh on 2019/1/23.
//  Copyright © 2019 mob. All rights reserved.
//

#import "ViewController.h"

#import "Pair.h"
#import "Person.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSApplication sharedApplication].delegate = self;

    self.persons = [[NSMutableArray alloc] init];
    
    Person *p1 = [[Person alloc] init];
    p1.name = @"Jack";
    p1.gender = GenderMale;
    p1.master = self;
    p1.age = 20;
    p1.cardID = 1001;
    
    Person *p2 = [[Person alloc] init];
    p2.name = @"Rose";
    p2.gender = GenderFemale;
    p2.master = self;
    p2.age = 18;
    p2.cardID = 1002;
    
    [self.persons addObject:p1];
    [self.persons addObject:p2];
    
    self.pairs = [[NSMutableArray alloc] init];
}

- (void)pair:(Person*)p1 with:(Person*)p2
{
    Pair *p = [[Pair alloc] init];
    p.person1 = p1;
    p.person2 = p2;
    p1.pair = p;
    p2.pair = p;
}

- (BOOL)existsPersonWithName:(NSString *)name
{
    for (Person *p in self.persons)
    {
        if ([p.name caseInsensitiveCompare:name] == NSOrderedSame)
        {
            return YES;
        }
    }
    return NO;
}

@end
