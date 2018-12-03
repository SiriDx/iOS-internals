# algorithm

- 爬楼梯

```
假设你正在爬楼梯，需要n步你才能到达顶部。但每次你只能爬一步或者两步，你能有多少种不同的方法爬到楼顶部？
```

```swift
class ChairClimb: NSObject {
    
    private var total:Int = 0
    
    func numOfWalkways(_ stair:Int) -> Int {
        if stair == 1 || stair == 2 {
            total = stair
        } else {
            total = numOfWalkways(stair - 1) + numOfWalkways(stair - 2)
        }
        return total
    }
}
```

