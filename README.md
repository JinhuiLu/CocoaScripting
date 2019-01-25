# CocoaScripting
让Cocoa App支持AppleScript
#### 让我们来模拟一个场景
>* 假使我们有一个app，名叫 CocoaScripting。程序里有一个Person类，有名字有性别。一男一女两个人可以配对并且只能和一个人配对。
>* 假设app正在运行，并且启动时初始化了两个 person，名叫 Jack 和 Rose。
>* ViewController 是我们的主控制器，里面有两个属性：persons 和 pairs;
>* persons 由 Person 对象组成的数组，每个Person实例创建后都会添加到该数组里。
>* Person 类中有一个pair属性，ViewController里有一个pairs数组。Pair两个Person属性，为person1和person2。所以我们又建了一个Pair对象，将它加入pairs数组里。而且还在这个Pair对象中指出每一个配对者的pair指针。因此，pair和person是双重关联的。可以通过person的pair属性来找到与之匹配的另一个人。好，这就是我们做的这个简单的程序。

现在我们开始创建sdef格式的字典，并将其添加到项目中。起名叫做CocoaScripting.sdef
如果要app支持AppleScript，必须将以下行加入到Info.plist中
```
<key>NSAppleScriptEnabled</key> 
<string>YES</string> 
<key>OSAScriptingDefinition</key> 
<string>CocoaScripting.sdef</string> 
```
##### 我们的脚本对这个程序该如何实现呢。
首先给CocoaScripting.sdef加一套常用的命令
让我们打开Sdef Editor来开始编辑吧。
选择 File > Open Standard Suite > NSCoreSuite ，然后从里面删除些我们不需要的内容、最后留下了下图
![7110C34A-D358-418B-A3D3-9945D5C77983.png](https://upload-images.jianshu.io/upload_images/2144458-a920466e7fb13ea4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

然后我们创建一个新的suite，叫做CocoaScripting Suite.
![B0B69EF8-B8B0-4C72-BBA9-D72A7CD58C33.png](https://upload-images.jianshu.io/upload_images/2144458-08378c092a105d04.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我们主要操作的是类person，所以创建一个person，person需要有 name 属性等等。
code 是可以随意写的，但是不能和现有的code重复，所以建议使用一些大写字母。因为苹果所有的四个字母的code，都是小写的。
像name、id这些属性是AppleScript中已经定义的标准属性，必须使用已定义的正确的code。
将cocoa key 和code 匹配 person 对应的Cocoa 类是 Person。脚本通过KVC查找对应的代码，所以类需要存在正确的变量和方法。
![screenshot_2.png](https://upload-images.jianshu.io/upload_images/2144458-55e5e06f6f669c88.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![screenshot_1.png](https://upload-images.jianshu.io/upload_images/2144458-ba5364523804c465.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

可能有很多个人，所以我们创建一个 person 的element。也就是说，可以将person放到顶层，作为application的元素。
![screenshot.png](https://upload-images.jianshu.io/upload_images/2144458-86243e16bd600063.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


建议将脚本性访问器与编程访问器分开。当脚本更改person的name属性时，它使用setName:，这与我们在Objective-C代码用于更改person的name的方法完全相同。但是我们的代码可能需要根据调用者的不同做出不同的响应，我们的代码或许会去做用户通过AppleScript不应该做的事情。所以我们可以在字典中指定一个不同的Cocoa键，并创建一组不同的脚本编辑框架访问器。

现在尝试下，通过脚本获取persons，persons 对应的Cocoa Key 是personArray，于是我们在Cocoa 工程里添加上这个方法。
 
```
- (NSArray *)personsArray
{
    return self.persons;
}
```
 
到现在，我们可以在AppleScript中对我们的App，进行一些访问了。
首先运行我们的Xcode工程，这样可以在Xcode的控制台得到一些提示。
在脚本编辑器中，尝试下以下命令：
```
 tell application "CocoaScripting"
	count persons -- 2
    name of person 1 -- "Jack"
    name of person 2 -- "Rose"
    name of every person -- {"Jack", "Rose"}
    name of every person whose name ends with "k" -- {"Jack"}
    exists person "Jack" -- true
    exists person "Tom" -- false
    delete person "Jack" --  Xcode 控制台： [<ViewController 0x600002c02d00> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key personsArray.
    get person 1 (* Error while returning the result of a script command: the result object...
<Person: 0x60000175f280>
...could not be converted to an Apple event descriptor of type 'person'. This instance of the class 'Person' returned nil when sent -objectSpecifier (is it not overridden?) and there is no coercible type declared for the scripting class 'person'.
    make new person 
*)
 end tell
```
  delete person "Jack" 的报错，提示不满足KVC，因为delete 对应的方法没有写呀。比如我们不让用户通过AppleScript删除用户那么可以这样实现下
```
  - (void)removeObjectFromPersonsArrayAtIndex:(unsigned int)index
{
    [self returnError:OSAMessageNotUnderstood string:nil];
}

- (void)removeFromPersonsArrayAtIndex:(unsigned int)index
{
    [self returnError:OSAMessageNotUnderstood string:nil];
}
```
  下面的get person 1，报错，说明我们仅仅实现personArray的getter方法是不行的。提示无法转换成对应的person类型，需要重写objectSpecifier方法
 * 实现objectSpecifier
 我们的应用程序声明的每个AppleScript类都应该在其对应的Objective-C类中有 objectSpecifier 方法的实现 。这就是当用户调用如get person 1或make new person之类的命令时，允许将如应用程序中person "Jack"之类的对象引用返回到脚本的原因。如果没有 objectSpecifier 实现，脚本将收到无意义的引用。实现了这个方法，脚本才能够理解你的对象。
```
 - (NSScriptObjectSpecifier *)objectSpecifier
{
    NSScriptClassDescription* appDesc = (NSScriptClassDescription*)[NSApp classDescription];
    return [[NSNameSpecifier alloc] initWithContainerClassDescription:appDesc containerSpecifier:nil key:@"personsArray" name:self.name];
    //return [[NSUniqueIDSpecifier alloc] initWithContainerClassDescription:appDesc containerSpecifier:nil key:@"personsArray" uniqueID:[NSNumber numberWithInteger:self.cardID]];
}
```
    NSApp 是全局应用的对象；我们获取它的 classDescription。containerSpecifier 为 nil 指的是顶级（应用）的容器，key为 @"personsArray".name 或者 uniqueID 是设置该对象的唯一标识. 以ID 为索引，对应的code为'ID  ', 两个空格不能省略。
 让我们再次调用之前的AppleScript脚本试下吧
![B696ED0D-F2EC-4A20-86B7-DD96FC0142B2.png](https://upload-images.jianshu.io/upload_images/2144458-68abde8e0e6bae54.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![182D0804-EBE7-47FF-8439-29330C470361.png](https://upload-images.jianshu.io/upload_images/2144458-b4e002afed99c405.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

 
 让我们来创建一个新person
```
 tell application "CocoaScripting"
	
	 make new person  -- [<ViewController 0x600002c03700> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key personsArray.
	
end tell

```
 失败了，原因依然是没有实现new person 的方法，person在顶层是element 是一个数组，创建person的时候，默认是要加到数组里的，所以我们需要实现下
```
- (void)insertObject:(Person *)p inPersonsArrayAtIndex:(unsigned int)index;
- (void)insertInPersonsArray:(Person *)p;
```
而且也可以在创建时确定下要求下必须传入的参数，比如我们要求必须传入name和gender
```
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
```
调用AppleScript脚本进行验证：
```
tell application "CocoaScripting"
	
	make new person with properties {name:"Tom", gender:male}
end tell
```

接下来，对person进行配对，在OC代码ViewController里，这样实现
```
- (void)pair:(Person*)p1 with:(Person*)p2
{
    Pair *p = [[Pair alloc] init];
    p.person1 = p1;
    p.person2 = p2;
    p1.pair = p;
    p2.pair = p;
}
```

在AppleScript脚本中，我们希望通过 ***pair person1 to person2*** 这种形式来进行配对，那么pair 是一个动词（verb），在字典里就是命令（command），操作person1和person2两个person类，那么person1就是直接参数，person2是另外的参数。在Cocoa脚本中，动词(命令)以两种不同的方式实现。如果一个动词基本应用于单个对象，它可以作为对应于该对象的类的方法出现在Objective-C代码中。这称为对象优先分派。(另一种方法，即动词优先分派,本文没有做说明)。在字典中定义了该命令之后，在字典中可以指定任何类去作为该命令的直接对象的。所以字典会包含这个命令的定义:
![F796B565-269C-47F1-8670-D25595D5D483.png](https://upload-images.jianshu.io/upload_images/2144458-0c11f954f4cd58dc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![DB5F5371-9667-4BBB-AE24-B67DDCB4D034.png](https://upload-images.jianshu.io/upload_images/2144458-19e6ad816788576a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

在我们的 person 类的字典里这样写
![BC451D8E-4B9B-40E0-8B4F-F6120B49E849.png](https://upload-images.jianshu.io/upload_images/2144458-a95c5866e2eb6ec4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这意味着当用户调用pair命令时，一个消息scripterSaysPair:将被发送给代表该命令的直接对象的Person对象。这个方法的参数是一个NSScriptCommand对象，它的evaluatedArguments方法生成一个NSDictionary，其中包含command的附加参数，这些参数通过Cocoa Key进行访问。我们现在的情形下，只有一个额外的参数，它的Key 是 "otherPerson"。
```
//在Person类中调用
- (void)scripterSaysPair:(NSScriptCommand *)command
{
    Person* p1 = [command evaluatedReceivers];
    Person* p2 = [[command evaluatedArguments] valueForKey:@"otherPerson"];
    if (self != p1 || self == p2)
    {
        [self returnError:errOSACantAssign string:@"Invalid pairing."];
        return;
    }
    [self.master scripterWantsToPair:p1 with:p2];
}

// 在ViewController中调用
- (void)scripterWantsToPair:(Person *)firstPerson with: (Person *)secondPerson;
{
    if ([firstPerson pair] || [secondPerson pair])
    {
        [self returnError:errOSACantAssign string:@"Can't pair a person who is already paired."];
        return;
    }
    [self pair:firstPerson with:secondPerson];
}
```

当配对后，我们还想知道与之配对的person是哪个，我们已经在字典里加了 partner 属性，同样也在OC代码里实现对应的Key
```
- (id)personPartner
{
    Pair *myPair = [self pair];
    if (!myPair)
    {
        return [NSNull null]; // missing value
    }
    return (myPair.person1 == self ? myPair.person2 : myPair.person1);
}

- (void)setPersonPartner:(id)newPartner
{
    [self returnError:errOSACantAssign string:@"Partner property is read-only. To set a person's partner, pair the person with another person."];
}

- (BOOL)personPaired
{
    return ([self pair] != nil);
}

- (void)setPersonPaired:(BOOL)newPaired
{
    [self returnError:errOSACantAssign string:@"Paired property is read-only."];
}
```

让我们通过AppleScript脚本试一下吧

```
tell application "CocoaScripting"
	
	pair person 1 to person 2
	name of every person -- {"Mannie", "Jack", "Moe"}
	partner of person "Jack"
end tell
```
