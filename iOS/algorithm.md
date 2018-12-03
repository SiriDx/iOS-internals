# algorithm

- 爬楼梯

```
N级台阶（比如100级），每次可走1步或者2步，求总共有多少种走法？
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

