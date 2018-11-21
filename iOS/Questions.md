# Questions

1. [OC语法](#OC语法)
2. [Runtime](#runtime)
3. [RunLoop](#runLoop)
4. [多线程](#多线程)
5. [内存管理](#内存管理)
6. [性能优化](#性能优化)
7. [设计模式与架构](#设计模式与架构)

## OC语法

- 一个NSObject对象占用多少内存？

```
系统分配了16个字节给NSObject对象
NSObject对象内部只使用了8个字节的空间, 用于存储isa指针
```

- 对象的isa指针指向哪里？

```
instance对象的isa指向class对象
class对象的isa指向meta-class对象
meta-class对象的isa指向基类的meta-class对象

从64bit开始，isa需要进行一次位运算(& ISA_MASK)，才能计算出真实地址
```

- OC的类信息存放在哪里？

```
OC对象主要分为3种:
- instance对象, 存放成员变量的具体值
- class对象, 存放对象方法、属性、成员变量、协议信息
- meta-class对象, 存放类方法

meta-class对象和class对象的内存结构是一样的, 都是struct objc_class
```

- iOS用什么方式实现对一个对象的KVO？(KVO的本质是什么？)

```
KVO的全称是Key-Value Observing，俗称“键值监听”，可以用于监听某个对象属性值的改变

1.利用RuntimeAPI动态生成一个子类
2.将当前对象的isa指向这个全新的子类
3.当修改当前对象对象的属性值时，会通过isa找到这个子类的set方法
4.set方法中会调用Foundation的_NSSetXXXValueAndNotify函数

_NSSetXXXValueAndNotify内部实现:
- willChangeValueForKey:
- 父类原来的setter
- didChangeValueForKey: 内部会触发监听器（Oberser）的监听方法(observeValueForKeyPath:ofObject:change:context:）
```

- 如何手动触发KVO？

```
手动调用willChangeValueForKey:和didChangeValueForKey:
```

- 直接修改成员变量会触发KVO么？

```
不会, KVO的触发是通过在set方法的内部中调用:
willChangeValueForKey和didChangeValueForKey
```

- 通过KVC修改属性会触发KVO么？

```
会触发
KVO的本质是通过运行时创建当前对象的子类, 将当前对象的isa指针指向这个子类, 
KVC的赋值过程中, 通过isa指针, 找到该子类中的set方法
这个子类在set方法中, 会赋值并通知观察者值的改变
```

- KVC的赋值和取值过程是怎样的？原理是什么？

```
KVC的全称是Key-Value Coding，俗称“键值编码”，可以通过一个key来访问某个属性

赋值过程:
1. 按照setKey, _setKey顺序查找方法, 找到直接调用方法
2. 没有找到, 判断是否允许直接访问成员变量 (accessInstanceVariablesDirectly, 该方法返回值默认为YES)
3. 不允许, 调用setValue:forUndefineKey:方法, 并抛出异常
4. 允许, 按照_key, _isKey, key, isKey 顺序查找成员变量, 找到直接赋值
5. 没有找到, 调用setValue:forUndefineKey:, 并抛出异常

取值过程:
1. 按照getKey, key, isKey, _key顺序查找方法, 找到直接调用方法
2. 没有找到, 判断是否允许直接访问成员变量
3. 不允许, 调用valueForUndefineKey:方法, 并抛出异常
4. 允许, 按照_key, _isKey, key, isKey顺序查找成员变量, 找到直接复制
5. 没有找到, 调用valueForUndefineKey:方法, 并抛出异常
```

- Category的使用场合是什么？

```
分类是用于给原有类添加方法的
分类只能添加方法, 不能直接添加成员变量
分类中的@property, 只会生成setter/getter方法的声明, 不会生成实现以及私有的成员变量
```

- Category的实现原理

```
Category编译之后, 生成了一个category_t结构体对象
里面存储着分类的对象方法、类方法、属性、协议

在程序运行的时候，通过runtime将分类中保存的数据，合并到类对象和元类对象中
```

- Category和Class Extension的区别是什么？

```
Class Extension(类拓展): 在编译的时候，它的数据就已经包含在类信息中
Category(分类): 是在运行时，才会将数据合并到类信息中
```

- Category中有load方法吗？load方法是什么时候调用的？load 方法能继承吗？

```
有load方法
load方法在runtime加载类、分类的时候调用
load是根据函数地址直接调用, 因此load方法不会被分类的覆盖

调用顺序:
- 先调用类的+load
	- 按照编译先后顺序调用（先编译，先调用）
	- 调用子类的+load之前会先调用父类的+load
- 再调用分类的+load
	- 按照编译先后顺序调用（先编译，先调用）

load方法可以继承，但是一般情况下不会主动去调用load方法，都是让系统自动调用
```

- load、initialize方法的区别什么？它们在category中的调用的顺序？以及出现继承时他们之间的调用过程？

```
load方法: 类加载进内存的时候调用
initialize方法: 类第一个接收到消息的时候调用

1.调用方式
1> load是根据函数地址直接调用
2> initialize是通过objc_msgSend调用

2.调用时刻
1> load是runtime加载类、分类的时候调用（只会调用1次）
2> initialize是类第一次接收到消息的时候调用，每一个类只会initialize一次（父类的initialize方法可能会被调用多次）

load、initialize的调用顺序？
1.load
1> 先调用类的load
a) 先编译的类，优先调用load
b) 调用子类的load之前，会先调用父类的load

2> 再调用分类的load
a) 先编译的分类，优先调用load

2.initialize
1> 先初始化父类
2> 再初始化子类（可能最终调用的是父类的initialize方法）
```

- Category能否添加成员变量？如果可以，如何给Category添加成员变量？

```
默认情况下，因为分类底层结构的限制，不能添加成员变量到分类中。
但可以通过关联对象来间接实现

关联对象并不是存储在被关联对象的内存中, 而是存储在一个全局统一的AssociationsManager中

通过设置关联对象为nil, 来移除关联对象
```

- block的原理是怎样的？本质是什么？

```
封装了函数, 以及函数调用环境的OC对象
继承自NSBlock
```

- block的属性修饰词为什么是copy？使用block有哪些使用注意？

```
Block如果没有进行copy操作, 就不会在堆上.
拷贝到堆上, 方便对block进行内存管理, 控制其生命周期进行

MRC中, block属性使用copy, 将栈上的block复制(copy)到堆上
ARC中, 被strong修饰的属性, 会自动拷贝到堆上, 因此ARC中block用copy或者strong都可以

使用注意:
当block被copy到堆中时, 会对block中强指针修饰的对象进行强引用
如果当前对象也强引用着该block, 会造成循环引用

解决循环引用:

使用以下修饰该对象类型的auto变量

ARC:
1.__weak：不会产生强引用，指向的对象销毁时，会自动让指针置为nil
2.__unsafe_unretained：不会产生强引用，不安全，指向的对象销毁时，指针存储的地址值不变

MRC:
__unsafe_unretained
```

- __block的作用是什么？有什么使用注意点？

```
__block可以用于解决block内部无法修改auto变量值的问题

__block本质是, 编译器会将__block修饰的变量包装成一个对象
该对象中保存了一个__forwarding指针
通过该指针找到对应的对象并修改变量值
```

- block在修改NSMutableArray，需不需要添加__block？

```
不需要.
block通过动态捕获, 保存的是数组对象的地址值
可以直接根据这个地址直接进行数组的添加删除操作
```

## 内存管理

- imageNamed:和imageWithContentsOfFile:区别

```
imageNamed: 通过文件名加载图片
- 通过传入的名字, 去文件夹中遍历查找对应的图片
- 将找到图片保存在内存缓存中, 方便下一次使用

imageWithContentsOfFile: 根据图片路径加载图片
- 图像数据不会被缓存

使用选择:
- 当图片文件较小, 使用比较频繁的时候那么使用imageNamed:
- 当该图片使用次数较少时, 可以考虑使用imageWithContentsOfFile:
```