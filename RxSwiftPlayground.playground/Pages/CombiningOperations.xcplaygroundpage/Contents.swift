//: [Previous](@previous)
/// Copyright (c) 2024 Justin.S.Wang
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import RxSwift

/** The startWith(_:) operator prefixes an observable sequence with the given initial value */
example(of: "startWith") {
  // Create a sequence of numbers
  let numbers = Observable.of(2, 3, 4)
  
  // Create a sequence starting with the value 1, then continue with the original sequence of numbers
  let observable = numbers.startWith(1)
  _ = observable.subscribe(
    onNext: { value in
      print(value)
    }
  )
  
  // We purposely don‘t keep the Disposable returned by the subscription, because the Observable here immediately completes after emitting its two items. Therefore, our subscription will automatically end. You will use this form in further examples when it‘s safe to do so.
}

// The Observable.concat(_:) static method takes either an ordered collection of observables (i.e. an array), or a variadic list of observables. It subscribes to the first sequence of the collection, relays its elements until it completes, then moves to the next one. The process repeats until all the observables in the collection have been used. If at any point an inner observable emits an error, the concatenated observable in turn emits the error and terminates.
example(of: "Observable.concat") {
  // 1
  let first = Observable.of(1, 2, 3)
  let second = Observable.of(4, 5, 6)
  
  // 2
  let observable = Observable.concat([first, second])
  
  observable.subscribe(onNext: { value in
    print(value)
  })
}

// It waits for the source observable to complete, then subscribes to the parameter observable. Aside from instantiation, it works just like Observable.concat(_:).
example(of: "concat") {
  let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
  let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")
  
  let observable = germanCities.concat(spanishCities)
  _ = observable.subscribe(onNext: { value in
    print(value)
  })
  
  // Note: Observable sequences are strongly typed. You can only concatenate sequences whose elements are of the same type!
  
  // If you try to concatenate sequences of different types, brace yourself for compiler errors. The Swift compiler knows when one sequence is an Observable<String> and the other an Observable<Int> so it will not allow you to mix them.
}

example(of: "concatMap") {
  // 1 Prepares two sequences producing German and Spanish city names.
  let sequences = [
    "German cities": Observable.of("Berlin", "Münich", "Frankfurt"),
    "Spanish cities": Observable.of("Madrid", "Barcelona", "Valencia")
  ]
  
  // 2 Has a sequence emit country names, each in turn mapping to a sequence emitting city names for this country.
  let observable = Observable.of("German cities", "Spanish cities")
    .concatMap { country in
      sequences[country] ?? .empty()
    }
  
  // 3 Outputs the full sequence for a given country before starting to consider the next one.
  _ = observable.subscribe(onNext: { string in
    print(string)
  })
}

example(of: "merge") {
  // 1
  let left = PublishSubject<String>()
  let right = PublishSubject<String>()
  
  // 2
  let source = Observable.of(left.asObserver(), right.asObserver())
  
  // 3
  let observable = source.merge()
  _ = observable.subscribe(onNext: { value in
    print(value)
  })
  
  // 4
  var leftValues = ["Berlin", "Münich", "Frankfurt"]
  var rightValues = ["Madrid", "Barcelona", "Valencia"]
  
  repeat {
    switch Bool.random() {
    case true where !leftValues.isEmpty:
      left.onNext("Left: \(leftValues.removeFirst())")
    case false where !rightValues.isEmpty:
      right.onNext("Right: \(rightValues.removeFirst())")
    default:
      break
    }
  } while !leftValues.isEmpty || !rightValues.isEmpty
  
  // 5
  left.onCompleted()
  right.onCompleted()
  
  // A merge() observable subscribes to each of the sequences it receives and emits the elements as soon as they arrive — there’s no predefined order.
  
  
  // merge() completes after its source sequence completes and all inner sequences have completed.
  // The order in which the inner sequences complete is irrelevant.
  // If any of the sequences emit an error, the merge() observable immediately relays the error, then terminates.
  
  // To limit the number of sequences subscribed to at once, you can use merge(maxConcurrent:). This variant keeps subscribing to incoming sequences until it reaches the maxConcurrent limit. After that, it puts incoming observables in a queue. It will subscribe to them in order, as soon as one of the active sequences completes.
  
  // Note: You might end up using this limiting variant less often than merge() itself. Keep it in mind, though, as it can be handy in resource-intensive situations. You could use it in scenarios such as when making a lot of network requests to limit the number of concurrent outgoing connections.
}

example(of: "combineLatest") {
  let left = PublishSubject<String>()
  let right = PublishSubject<String>()
  
  // 1
  let observable = Observable.combineLatest(left, right) {
    lastLeft, lastRight in
    "\(lastLeft) \(lastRight)"
  }
  
  _ = observable.subscribe(onNext: { value in
    print(value)
  })
  
  // 2
  print("> Sending a value to left")
  left.onNext("Hello,")
  print("> Sending a value to right")
  right.onNext("world")
  print("> Sending another value to Right")
  right.onNext("RxSwift")
  print("> Sending another value to Left")
  left.onNext("Have a good day.")
  
  left.onCompleted()
  right.onCompleted()
  
  // You combine observables using a closure receiving the latest value of each sequence as arguments. In this example, the combination is the concatenated string of both left and right values. It could be anything else that you need, as the type of the elements the combined observable emits is the return type of the closure. In practice, this means you can combine sequences of heterogeneous types. It is one of the rare core operators that permit this, the other being withLatestFrom(_:) you‘ll learn about in a short while.
  
  // Nothing happens until each of the observables emit one value. After that, each time one emits a new value, the closure receives the latest value of each of the observables and produces its result.
  
  // Note: Remember that combineLatest(_:_:resultSelector:) waits for all its observables to emit one element before starting to call your closure. It’s a frequent source of confusion and a good opportunity to use the startWith(_:) operator to provide an initial value for the sequences which may not immediately delive a value.
}

example(of: "combine user choice and value") {
  let choice: Observable<DateFormatter.Style> = Observable.of(.short, .long)
  let dates = Observable.of(Date())
  
  let observable = Observable.combineLatest(choice, dates) { format, when -> String in
    let formatter = DateFormatter()
    formatter.dateStyle = format
    return formatter.string(from: when)
  }
  
  _ = observable.subscribe(onNext: { value in
    print(value)
  })
  
  // This example demonstrates automatic updates of on-screen values when the user settings change. Think about all the manual updates you’ll remove with such patterns!
  
  // A final variant of the combineLatest family takes a collection of observables and a combining closure, which receives latest values in an array. Since it’s a collection, all observables carry elements of the same type.
  
  // Since it’s less flexible than the multiple parameter variants, it is seldom-used but still handy to know about The string observable in your first combineLatest(_:_:resultSelector:) example could be rewritten as:
  
  // 1
//  let observable = Observable.combineLatest([left, right]) {
//    strings in strings.joined(separator: " ")
//  }
  
  // Note: Last but not least, combineLatest completes only when the last of its inner sequences completes. Before that, it keeps sending combined values. If some sequences terminate, it uses the last value emitted to combine with new values from other sequences.

}

example(of: "zip") {
  enum Weather {
    case cloudy
    case sunny
  }
  
  let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
  let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")
  
  let observable = Observable.zip(left, right) { weather, city in
    return "It's \(weather) in \(city)"
  }
  _ = observable.subscribe(onNext: { value in
    print(value)
  })
}

example(of: "withLatestFrom") {
  // 1
  let button = PublishSubject<Void>()
  let textField = PublishSubject<String>()
  
  // 2
  let observable = button.withLatestFrom(textField)
  _ = observable.subscribe(onNext: { value in
    print(value)
  })
  
  // 3
  textField.onNext("Par")
  textField.onNext("Pari")
  textField.onNext("Paris")
  button.onNext(())
  button.onNext(())
}

// A close relative to withLatestFrom(_:) is the sample(_:) operator.
example(of: "sample") {
  // 1
  let button = PublishSubject<Void>()
  let textField = PublishSubject<String>()
  
  // 2
  let observable = textField.sample(button)
  _ = observable.subscribe(onNext: { value in
    print(value)
  })
  
  // 3
  textField.onNext("Par")
  textField.onNext("Pari")
  textField.onNext("Paris")
  button.onNext(())
  button.onNext(())
  
  // You could have achieved the same behavior by adding a distinctUntilChanged() to the withLatestFrom(_:) observable, but smallest possible operator chains are the Zen of Rx.
  
  // MARK: Note: Don’t forget that withLatestFrom(_:) takes the data observable as a parameter, while sample(_:) takes the trigger observable as a parameter. This can easily be a source of mistakes — so be careful!
}

example(of: "amb") {
  let left = PublishSubject<String>()
  let right = PublishSubject<String>()
  
  // 1
  let observable = left.amb(right)
  _ = observable.subscribe(onNext: { value in
    print(value)
  })
  
  // 2
  left.onNext("Lisbon")
  right.onNext("Copenhagen")
  left.onNext("London")
  left.onNext("Madrid")
  right.onNext("Vienna")
  
  left.onCompleted()
  right.onCompleted()
  
  // The amb(_:) operator subscribes to the left and right observables. It waits for any of them to emit an element, then unsubscribes from the other one. After that, it only relays elements from the first active observable.
  
}

// A more popular option is the switchLatest() operator
example(of: "switchLatest") {
  // 1
  let one = PublishSubject<String>()
  let two = PublishSubject<String>()
  let three = PublishSubject<String>()
  
  let source = PublishSubject<Observable<String>>()
  
  // 2
  let observable = source.switchLatest()
  let disposable = observable.subscribe(onNext: { value in
    print(value)
  })
  
  // 3
  source.onNext(one)
  one.onNext("Some text from sequence one")
  two.onNext("Some text from sequence two")
  
  source.onNext(two)
  two.onNext("More text from sequence two")
  one.onNext("and also from sequence one")
  
  source.onNext(three)
  two.onNext("Why don't you see me?")
  one.onNext("I'm alone, help me")
  three.onNext("Hey it's three. I win.")
  
  source.onNext(one)
  one.onNext("Nope. It's me, one!")

  disposable.dispose()
}

example(of: "reduce") {
  let source = Observable.of(1, 3, 5, 7, 9)
  
  // 1
//  let observable = source.reduce(0, accumulator: +)
  // or
  let observable = source.reduce(0) { summary, newValue in
    return summary + newValue
  }
  _ = observable.subscribe(onNext: { value in
    print(value)
  })
  
  // Note: reduce(_:_:) produces its summary (accumulated) value only when the source observable completes. Applying this operator to sequences that never complete won’t emit anything. This is a frequent source of confusion and hidden problems.
  
}

// A close relative to reduce(_:_:) is the scan(_:accumulator:) operator.
example(of: "scan") {
  let source = Observable.of(1, 3, 5, 7, 9)
  
  let observable = source.scan(0, accumulator: +)
  _ = observable.subscribe(onNext: { value in
    print(value)
  })
  
  // The range of use cases for scan(_:accumulator:) is quite large; you can use it to compute running totals, statistics, states and so on.
  
  // Encapsulating state information within a scan(_:accumulator:) observable is a good idea; you won’t need to use local variables, and it goes away when the source observable completes. You’ll see a couple of neat examples of scan in action in Chapter 20, “RxGesture.”
}






//: [Next](@next)
