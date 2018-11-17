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
Category编译之后的底层结构是struct category_t
里面存储着分类的对象方法、类方法、属性、协议信息

在程序运行的时候，runtime会将Category的数据，合并到类信息中（类对象、元类对象中）
```

- Category和Class Extension的区别是什么？

```
Class Extension(类拓展)
- 在编译的时候，它的数据就已经包含在类信息中

Category(分类)
- 是在运行时，才会将数据合并到类信息中
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