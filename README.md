<p align="center">
    <img width="200" height="193" src="Logo.png" />
</p>


<h1><a href="https://github.com/SerhiyButz/Mitra">Mitra</a></h1>

The *Mitra* package provides a *shared-memory* synchronization manager (*Shared Manager*) that implements a [*mutex-to-operation* strategy](https://SerhiyButz.github.io/swift-shared-memory-manager/#mutex-to-operation-strategy) (as opposed to the traditional [*mutex-to-memory* strategy](https://SerhiyButz.github.io/swift-shared-memory-manager/#mutex-to-memory-strategy)). It can be thought of as an efficient automatically provided *safety net* for *shared-memory* operations, and is a breeze to work with.


<p>
    <img src="https://img.shields.io/badge/Swift-5.1-orange" alt="Swift" />
    <img src="https://img.shields.io/badge/platform-macOS%20|%20iOS-orange.svg" alt="Platform" />
    <img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-orange" alt="SPM" />
    <a href="https://github.com/SerhiyButz/Mitra/blob/master/LICENSE">
        <img src="https://img.shields.io/badge/licence-MIT-orange" alt="License" />
    </a>
</p>



## Contents

- [Intro](#intro)
- [Advantages](#Advantages)
- [Usage](#Usage)
  - [Example #1](#example-1)
  - [Example #2](#example-2)
- [Installation](#Installation)
- [License](#License)


TODO: Mention that this is one of the ways to provide local reasoning:
Being able to look at the function and know certain things without having to go look at other parts of the program is what we call local reasoning.



## Intro

The predominant approach to achieving safe access to [*shared memory*](https://en.wikipedia.org/wiki/Shared_memory) is based on the use of a program object, a [*mutex*](https://en.wikipedia.org/wiki/Mutual_exclusion), which, if used correctly, guarantees that concurrent execution threads will not simultaneously enter a [*critical section*](https://en.wikipedia.org/wiki/Critical_section) of code that operates on the shared memory region. Despite its simplicity, this approach requires a lot of effort from the programmer to use it properly because not only will the compiler not report an error at compile time, but such errors can occur in very mysterious exotic situations when the code is already in production and this brings the trickiness of using mutexes to a critical level. Maintaining mutexes is not only very distracting for the programmer from his application domain, but also quite tedious due to the triviality of the mutex concept itself. To somehow mitigate the problematic situation, the folks developed a simple methodology – associating mutexes with a specific memory location (the [*mutex-to-memory strategy*](https://serhiybutz.github.io/swift-shared-memory-manager/#mutex-to-memory-strategy)), the habit of following which greatly alleviates the burden on the programmer. 

However, it became clear over time that the *mutex-to-memory* strategy is far from a panacea and has a bunch of drawbacks, the main point of which is that this tool itself simply does not get along with the process of logical transformations by the program of its state. More refined memory synchronization patterns and means have been developed and adopted both in the form of program objects that solve their specific domain of synchronization problems, such as readers-writer locks, condition variables, turnstiles etc., and as properties of higher-level program constructs, such as monitors, run loops, dispatch queues, actors etc. These or other constructs give certain guarantees, provided that one follows their semantics and greatly ease the programmer's burden of taking care of such often tedious thing as, for example, strictly maintaining [*critical sections*](https://en.wikipedia.org/wiki/Critical_section) in the code, or [memory ordering](https://en.wikipedia.org/wiki/Memory_ordering).

Another alternative strategy is implemented in *Mitra* – the [*mutex to operation strategy*](https://serhiybutz.github.io/swift-shared-memory-manager/#mutex-to-operation-strategy). In this strategy, the association of a particular mutex with a particular memory location is not static, but dynamic – the duration of mutex association corresponds to the duration of a particular *state operation*. As in other approaches, each *state operation* is a *critical section*, but the fundamental difference is that in this approach the *mutex* concept is *explicitly* tied to the *state operation*, and here the delineation of access to a particular memory location depends on whether or not it is used in other *operations* at the moment, and this delineation occurs dynamically. Carrying out of this strategy is a rather tedious process to burden the programmer with it, so the full control of this process is done by *Mitra*'s *Shared Manager*. 

For more information, see [here](https://serhiybutz.github.io/swift-shared-memory-manager/).



## Advantages

* It's efficient

* It's easy to use

* It relies on *Swift* compiler to control usage errors

* It fits naturally into the process of memory sharing

  

## Usage

The workhorse of the package is the `SharedManager` class, an instance of which is needed to perform synchronization of inter-thread memory accesses:

```swift
let sharedManager = SharedManager()
```

In a program, *Shared Manager* can be either embedded as a singleton or dependency-injected into appropriate program components. 

To perform its tasks, *Shared Manager* must be able to identify shared memory locations (hereafter, *program properties*) it operates on. To this end, each property must be wrapped in a `Property` wrapper: 

```swift
let foo = Property(value: 0)
let bar = Property(value: "bla-bla-bla")
```

Each state operation, as already mentioned, is a *critical section* and, for the duration of its execution *borrows* the memory locations (e.g. *program properties*) it needs to access:

```swift
func add(_ v: Int) {
    sharedManager.borrow(foo.rw) {
        $0.value += v
    }
}
func report() {
    sharedManager.borrow(foo.ro, bar.ro) { foo, bar in
        print(foo.value, bar.value)
    }
}
```

The code above demonstrates 2 operations `add(_:)` and `report()`, where the first modifies the state by adding the passed value `v` to the `foo` *property*, and the second prints out the current state. The *properties* are accessed with *accessors*, which are provided in the *access block* (aka *critical section*) for each borrowed *property* in the corresponding order (in the `report` operation above, the accessor names in the access block *shadow* the borrowed property names.) For each borrowed property its *access semantics*, either *read-only* [`.ro`] or *read-write* [`.rw`], is necessarily declared. The *accessor* UI has a terminal property `value` to access directly the value of the *program property*. The `value` property carries the declared access semantics of the *program property* and, worth mentioning, the *Swift* compiler will not allow modification of a *program property* value with read-only semantics at *compile time*. When operations are executed in parallel threads, if both their time intervals overlap and sets of used properties overlap, *Shared Manager* comes into action and in case of conflict, it delays the latter operation until the first one finishes execution. In this way, the integrity of the whole program state is maintained. *Note: accesses conflict when they overlap in time and when at least one of them is a modification.*

To get a real idea of the *mutex-to-operation strategy* with *Mitra* in practice, here are 2 examples. 



### Example #1<a id="example-1"></a>

The code below contains an implementation of `TrafficAccount` structure, which is a simple use case – contrived traffic consumption accounting. It contains 2 properties: `balance` (account balance) and `traffic` (traffic consumed by the user) which must be accessed synchronously in a multithreaded program. The `TrafficAccount` struct has the following *UI*: command operations `topUp(for:)` (account balance replenishment operation), `consume(_:_:)` (traffic consumption operation), and query operations `currentBalance`, `currentTraffic` and `summury` (gets 2 properties simultaneously for reporting):

```swift
struct TrafficAccount {
    let sharedManager = SharedManager()

    // MARK: - Properties (State)
  
    private let balance = Property<Double>(value: 0) // remaining money
    private let traffic = Property<Double>(value: 0) // traffic consumed

    // MARK: - Queries
  
    public var currentBalance: Double {
        sharedManager.borrow(balance.ro) { $0.value }
    }
    public var currentTraffic: Double {
        sharedManager.borrow(traffic.ro) { $0.value }
    }
    public var summary: (balance: Double, traffic: Double) {
        sharedManager.borrow(balance.ro, traffic.ro) { (balance: $0.value, traffic: $1.value) }
    }

    // MARK: - Commands
  
    public func topUp(for amount: Double) {
        sharedManager.borrow(balance.rw) { $0.value += amount }
    }
    public func consume(_ gb: Double, at costPerGb: Double) -> Double {
        sharedManager.borrow(balance.rw, traffic.rw) { balance, traffic in
            let cost = gb * costPerGb
            let spent = balance.value < cost ? balance.value : cost
            balance.value -= spent
            let consumed = spent / costPerGb
            traffic.value += consumed
            return consumed
        }
    }
}
```



### Example #2<a id="example-2"></a>

There are operations that work with *ranges* of shared properties instead of individual properties, when rather than enumerating all properties, you specify the whole range. For this, *Mitra* offers `ArraySliceProperty`, an array slice property, which allows you to reference properties through *Swift*'s collection slices that have lower and upper *bounds* to delimit the slice range.

The below code illustrates a contrived device `Contraption` which has a bunch of sensors whose readings come asynchronously from different threads through calls to `updateSensor(_:_:)` method. The device periodically updates the average value of the sensors into the `average` *property* using the `updateAverage()` operation:

```swift
struct Contraption {
    let sharedManager = SharedManager()

    // MARK: - Properties (State)

    private let sensorReadings = [Property(value: 0),
                                  Property(value: 0),
                                  Property(value: 0)]
    private let average = Property<Double>(value: 0.0)

    // MARK: - UI

    func updateSensor(_ i: Int, value: Int) {
        sharedManager.borrow(ArraySliceProperty(sensorReadings[i...i]).rw) { sensor in
            sensor.first!.value = value
        }
    }
    @discardableResult
    func updateAvarage() -> Double {
        sharedManager.borrow(ArraySliceProperty(sensorReadings[...]).ro, average.rw) { readings, average in
            average.value = Double(readings.map { $0.value }.reduce(0, +)) / Double(readings.count)
            // Alternatively:
            // average.value = Double(readings[0].value + readings[1].value + readings[2].value) / Double(readings.count)
            return average.value
        }
    }
}
```

The `updateSensor(_:_:)` operation dynamically specifies the required sensor element index for esclusive borrowing in the sensor array, using the array slice bounds. And the `updateAvarage()` operation, by means of an unbounded range slice, specifies the entire sensor readings array for non-exclusive access borrowing. Notice how proper abstraction increases the flexibility of the *UI*.

Now you have seen how concise the code for implementing shared memory synchronization with *Mitra* is.



## Installation

### Swift Package as dependency in Xcode 11+

1. Go to "File" -> "Swift Packages" -> "Add Package Dependency"
2. Paste *Mitra* repository URL into the search field:

`https://github.com/SerhiyButz/Mitra.git`

3. Click "Next"

4. Ensure that the "Rules" field is set to something like this: "Version: Up To Next Major: 0.8.0"

5. Click "Next" to finish

For more info, check out [here](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).



## License

This project is licensed under the MIT license.
