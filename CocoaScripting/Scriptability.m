//
//  Scriptability.m
//  CocoaScripting
//
//  Created by lujh on 2019/1/23.
//  Copyright © 2019 mob. All rights reserved.
//

#import "Scriptability.h"

#import "ViewController.h"
#import "Person.h"
#import "Pair.h"

@implementation NSObject (CocoaScriptability)

- (void)returnError:(int)n string:(NSString *)s
{
    NSScriptCommand *c = [NSScriptCommand currentCommand];
    [c setScriptErrorNumber:n];
    if (s)
    {
        [c setScriptErrorString:s];
    }
}

@end

@implementation ViewController (CocoaScriptability)
// we are the app delegate

- (BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key
{
    NSLog(@"handles %@",key);
    if ([key isEqualToString: @"personsArray"])
    {
        return YES;
    }
    return NO;
}

- (NSArray *)personsArray
{
    NSLog(@"getPersonsArray:%@", self.persons);
    return self.persons;
}

//// we have one element: "personsArray" (facade for self->persons)
//
//- (NSUInteger)countOfPersonsArray
//{
//    NSLog(@"countofpersons");
//    return self.persons.count;
//}
//
//// needed by "get every person"
//
//- (Person *)objectInPersonsArrayAtIndex:(unsigned int)i {
//    NSLog(@"personAtIndex %i", i);
//    return [self.persons objectAtIndex: i];
//}
//

// 这些似乎解决了NSReceiverEvaluationScriptError消息
- (Person *)valueInPersonsArrayAtIndex:(unsigned int)i
{
    NSLog(@"valueInPersonsAtIndex %i", i);
    if (![[NSScriptCommand currentCommand] isKindOfClass:[NSExistsCommand class]])
        if (i >= self.persons.count)
        {
            [self returnError:errAENoSuchObject string:@"No such person."];
            return nil;
        }
    return self.persons[i];
}

- (Person *)valueInPersonsArrayWithName:(NSString *)name
{
    NSLog(@"valueInPersonsWithName %@", name);

    for (Person *p in self.persons)
    {
        if ([p.name caseInsensitiveCompare:name] == NSOrderedSame)
        {
            return p;
        }
    }
    if (![[NSScriptCommand currentCommand] isKindOfClass:[NSExistsCommand class]])
    {
        [self returnError:errAENoSuchObject string:@"No such person."];
        return [[Person alloc] init];
    }
    return nil;
}

// 错误检查

- (void)scripterWantsToChangeName:(NSString*)n of:(Person *)p
{
    if ([n isEqualToString:p.name])
    {
        return;
    }
    if (![self canGivePerson:p name:n])
    {
        return;
    }
    p.name = n;
}

// 指定创建person 的规则
- (BOOL)canGivePerson:(Person *)p name:(NSString *)name
{
    if (!name || [name isEqualToString:@""])
    {
        [self returnError:errOSACantAssign string:@"Can't give person empty name."];
        return NO;
    }
    if ([self existsPersonWithName:name])
    {
        [self returnError:errOSACantAssign string:@"Can't give person same name as existing person."];
        return NO;
    }
    return YES;
}

- (BOOL)canCreatePerson:(Person*)p
{
    if (![self canGivePerson:p name:p.name]) return NO;
    if (! (p.gender == GenderMale || p.gender == GenderFemale))
    {
        [self returnError:errOSACantAssign string:@"A person must have a gender."];
        return NO;
    }
    if ([[NSScriptCommand currentCommand] scriptErrorNumber] < 0)
    {
        return NO; // 其他命令断定无效
    }
    return YES;
}

// 创建person
// 同样需要遵守KVC
- (void)insertObject:(Person *)p inPersonsArrayAtIndex:(unsigned int)index
{
    NSLog(@"newPerson: %@", p.name);
    if (![self canCreatePerson:p])
    {
        return;
    }
    p.master = self;
    [self.persons insertObject:p atIndex:index];
}

- (void)insertInPersonsArray:(Person *)p
{
    NSLog(@"newPerson2: %@", p.name);
    if (![self canCreatePerson:p])
    {
        return;
    }
    p.master = self;
    [self.persons addObject:p];
}


// 删除person
// 这两个也需要满足KVC
- (void)removeObjectFromPersonsArrayAtIndex:(unsigned int)index
{
    NSLog(@"deletePerson");
    [self returnError:OSAMessageNotUnderstood string:nil];
}

- (void)removeFromPersonsArrayAtIndex:(unsigned int)index
{
    NSLog(@"deletePerson2");
    [self returnError:OSAMessageNotUnderstood string:nil];
}

// 由person 调用 pair
- (void)scripterWantsToPair:(Person *)firstPerson with: (Person *)secondPerson;
{
    if ([firstPerson pair] || [secondPerson pair])
    {
        [self returnError:errOSACantAssign string:@"Can't pair a person who is already paired."];
        return;
    }
    [self pair:firstPerson with:secondPerson];
}

@end

@implementation Person (CocoaScriptability)

// return a reference
- (NSScriptObjectSpecifier *)objectSpecifier
{
    NSLog(@"personObjectSpecifier");
    NSScriptClassDescription* appDesc = (NSScriptClassDescription*)[NSApp classDescription];
    // name 或者 uniqueID 是设置该对象的唯一标识 以ID 为索引，对应的code为'ID  ', 两个空格不能省略。
//    return [[NSNameSpecifier alloc] initWithContainerClassDescription:appDesc containerSpecifier:nil key:@"personsArray" name:self.name];
    return [[NSUniqueIDSpecifier alloc] initWithContainerClassDescription:appDesc containerSpecifier:nil key:@"personsArray" uniqueID:[NSNumber numberWithInteger:self.cardID]];
}

- (NSString *)personName
{
    NSLog(@"getPersonName:%@", self.name);
    return self.name;
}

- (void)setPersonName:(NSString *)personName
{
    //判断是新建person 还是改变名字
    if ([[NSScriptCommand currentCommand] isKindOfClass: [NSCreateCommand class]])
    {
        self.name = personName;
    }
    else
    {
        [self.master scripterWantsToChangeName:personName of:self];
    }
    
}

- (Gender)personGender
{
    NSLog(@"getPersonGender:%lu", (unsigned long)self.gender);
    return self.gender;
}

- (void)setPersonGender:(Gender)gender
{
    if ([[NSScriptCommand currentCommand] isKindOfClass: [NSCreateCommand class]])
    {
        self.gender = gender;
    }
    else
    {
        [self returnError:errOSACantAssign string:@"Can't change person's gender."];
    }
}

- (NSInteger)personAge
{
    return self.age;
}

- (void)setPersonAge:(NSInteger)age
{
    if ([[NSScriptCommand currentCommand] isKindOfClass: [NSCreateCommand class]])
    {
        self.age = age;
    }
    else
    {
        [self returnError:errOSACantAssign string:@"Can't change person's age."];
    }
}

- (NSInteger)personCardID
{
    return self.cardID;
}

- (void)setPersonCardID:(NSInteger)cardID
{
    if ([[NSScriptCommand currentCommand] isKindOfClass: [NSCreateCommand class]])
    {
        self.cardID = cardID;
    }
    else
    {
        [self returnError:errOSACantAssign string:@"Can't change person's cardID."];
    }
}

// pair command
// 一个消息scripterSaysPair:将被发送给代表该命令的直接对象的Person对象。这个方法的参数是一个NSScriptCommand对象，它的evaluatedArguments方法生成一个NSDictionary，其中包含命令的附加参数，这些参数通过Cocoa键进行键控;在这种情况下，只有一个额外的参数，它的key将是“otherPerson”。
- (void)scripterSaysPair:(NSScriptCommand *)command
{
    NSLog(@"pair");
    Person* p1 = [command evaluatedReceivers];
    Person* p2 = [[command evaluatedArguments] valueForKey:@"otherPerson"];
    if (self != p1 || self == p2)
    {
        [self returnError:errOSACantAssign string:@"Invalid pairing."];
        return;
    }
    [self.master scripterWantsToPair:p1 with:p2];
}

// partner and paired properties
// must have both halves of a get/set even if the property is read-only

- (id)personPartner
{
    NSLog(@"getPersonPartner");
    Pair *myPair = [self pair];
    if (!myPair)
    {
        return [NSNull null]; // missing value
    }
    return (myPair.person1 == self ? myPair.person2 : myPair.person1);
}

- (void)setPersonPartner:(id)newPartner
{
    NSLog(@"setPersonPartner");
    [self returnError:errOSACantAssign string:@"Partner property is read-only. To set a person's partner, pair the person with another person."];
}

- (BOOL)personPaired
{
    NSLog(@"getPersonPaired");
    return ([self pair] != nil);
}

- (void)setPersonPaired:(BOOL)newPaired
{
    NSLog(@"setPersonPaired");
    [self returnError:errOSACantAssign string:@"Paired property is read-only."];
}

@end


