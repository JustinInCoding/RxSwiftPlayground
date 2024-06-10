//: [Previous](@previous)

import Foundation
import RxSwift

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

/** Ignoring operators */
// ignoreElements will ignore all next events

example(of: "ignoreElements") {
  // Create a strikes subject.
  let strikes = PublishSubject<String>()
  
  let disposeBag = DisposeBag()
  
  strikes
    // Subscribe to all strikes’ events, but ignore all next events by using ignoreElements.
    .ignoreElements()
    .subscribe { _ in
      print("You're out!")
    }
    .disposed(by: disposeBag)
  
  strikes.onNext("X")
  strikes.onNext("X")
  strikes.onNext("X")
  strikes.onCompleted()
}

// ignoreElements actually returns a Completable, which makes sense because it will only emit a completed or error event.

/** elementAt */
example(of: "elementAt") {
  // create a subject
  let strikes = PublishSubject<String>()
  // subscribe to the next events, ignoring all but the 3rd next event, found at index 2.
  let disposeBag = DisposeBag()
  
  strikes
    .elementAt(2)
    .subscribe(
      onNext: { _ in
        print("You're out!")
      }
    )
    .disposed(by: disposeBag)
  
  strikes.onNext("X")
  strikes.onNext("X")
  strikes.onNext("X")
}

// As soon as an element is emitted at the provided index, the subscription is terminated.

/*** filter */
example(of: "filter") {
  let disposeBag = DisposeBag()
  // create an observable of some predefined integers
  Observable.of(1, 2, 3, 4 ,5, 6)
    // use the filter operator to apply a conditional constraint to prevent odd numbers from getting through.
    .filter { $0.isMultiple(of: 2) }
    // subscribe and print out the elements that pass the filter predicate
    .subscribe(
      onNext: {
        print($0)
      }
    )
    .disposed(by: disposeBag)
}

/** skip **/
//  use the skip operator. It lets you ignore the first n elements, where n is the number you pass as its parameter
example(of: "skip") {
  let disposeBag = DisposeBag()
  // Create an observable of letters
  Observable.of("A", "B", "C", "D", "E", "F")
    // Use skip to skip the first 3 elements and subscribe to next events
    .skip(3)
    .subscribe(
      onNext: {
        print($0)
      }
    )
    .disposed(by: disposeBag)
}

// skipWhile only skips up until something is not skipped, and then it lets everything else through from that point on.
// with skipWhile, returning true will cause the element to be skipped, and returning false will let it through
example(of: "skipWhile") {
  let disposeBag = DisposeBag()
  // Create an observable of integers
  Observable.of(2, 2, 3, 4, 4)
    // Use skipWhile with a predicate that skips elements until an odd integer is emitted.
    .skipWhile { $0.isMultiple(of: 2) }
    .subscribe(
      onNext: {
        print($0)
      }
    )
    .disposed(by: disposeBag)
}

// skipUntil, which will keep skipping elements from the source observable — the one you’re subscribing to — until some other trigger observable emits
example(of: "skipUntil") {
  let disposeBag = DisposeBag()
  // Create a subject to model the data you want to work with, and another subject to act as a trigger.
  let subject = PublishSubject<String>()
  let trigger = PublishSubject<String>()
  // Use skipUntil and pass the trigger subject. When trigger emits, skipUntil stops skipping.
  subject
    .skipUntil(trigger)
    .subscribe(
      onNext: {
        print($0)
      }
    )
    .disposed(by: disposeBag)
  
  subject.onNext("A")
  subject.onNext("B")
  
  trigger.onNext("X")
  
  subject.onNext("C")
}

/** Taking operators */
// take the first of the number of elements you specified
example(of: "take") {
  let disposeBag = DisposeBag()
  // Create an observable of integers
  Observable.of(1, 2, 3, 4, 5, 6)
    // Take the first 3 elements using take
    .take(3)
    .subscribe(
      onNext: {
        print($0)
      }
    )
    .disposed(by: disposeBag)
}

// takeWhile

example(of: "takeWhile") {
  let disposeBag = DisposeBag()
  // Create an observable of integers
  Observable.of(2, 2, 4, 4, 6, 6)
    // Use the enumerated operator to get tuples containing the index and value of each element emitted.
    .enumerated()
    // Use the takeWhile operator, and destructure the tuple into individual arguments.
    .takeWhile { index, integer in
      // Pass a predicate that will take elements until the condition fails
      integer.isMultiple(of: 2) && index < 3
    }
    // Use map — which works just like the Swift Standard Library map — to reach into the tuple returned from takeWhile and get the element.
    .map(\.element)
    // Subscribe to and print out next elements.
    .subscribe(
      onNext: {
        print($0)
      }
    )
    .disposed(by: disposeBag)
}

/** takeUntil operator that will take elements until the predicate is met */
//  It also takes a behavior argument for its first parameter that specifies if you want to include or exclude the last element matching the predictate
// takeUntil(.inclusive)
example(of: "takeUntil") {
  let disposeBag = DisposeBag()
  // Create an Observable of sequential integers
  Observable.of(1, 2, 3, 4, 5)
    // Use the takeUntil operator with inclusive behavior
    .takeUntil(.inclusive) { $0.isMultiple(of: 4) }
//    .takeUntil(.exclusive) { $0.isMultiple(of: 4) }
    .subscribe(
      onNext: {
        print($0)
      }
    )
    .disposed(by: disposeBag)
}

//--- Example of: takeUntil ---
//1
//2
//3
//4

example(of: "takeUntil trigger") {
  let disposeBag = DisposeBag()
  // Create a primary subject and a trigger subject
  let subject = PublishSubject<String>()
  let trigger = PublishSubject<String>()
  
  subject
    // Use takeUntil, passing the trigger that will cause takeUntil to stop taking once it emits.
    .takeUntil(trigger)
    .subscribe(
      onNext: {
        print($0)
      }
    )
    .disposed(by: disposeBag)
  // Add a couple of elements onto subject
  subject.onNext("1")
  subject.onNext("2")
  
  trigger.onNext("X")
  
  subject.onNext("3")
}

// In the above code, the deallocation of self is the trigger that causes takeUntil to stop taking, where self is typically a view controller or view model
// with RxCocoa

//_ = someObservable
//  .takeUntil(self.rx.deallocated)
//  .subscribe(onNext: {
//    print($0)
//  })

/** Distinct operators */
// prevent duplicate contiguous items from getting through

// distinctUntilChanged only prevents duplicates that are right next to each other
example(of: "distinctUntilChanged") {
  let disposeBag = DisposeBag()
  // Create an observable of letters
  Observable.of("A", "A", "B", "B", "A")
    // Use distinctUntilChanged to prevent sequential duplicates from getting through
    .distinctUntilChanged()
    .subscribe(
      onNext: {
        print($0)
      }
    )
    .disposed(by: disposeBag)
}

//--- Example of: distinctUntilChanged ---
//A
//B
//A

// However, you can optionally use distinctUntilChanged(_:) to provide your own custom logic to test for equality; the parameter you pass is a comparer.
example(of: "distinctUntilChanged(_:)") {
  let disposeBag = DisposeBag()
  // Create a number formatter to spell out each number
  let formatter = NumberFormatter()
  formatter.numberStyle = .spellOut
  // Create an observable of NSNumbers instead of Ints, so that you don’t have to convert integers when using the formatter next
  Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
    // Use distinctUntilChanged(_:), which takes a predicate closure that receives each sequential pair of elements
    .distinctUntilChanged { a, b in
      // Use guard to conditionally bind the element’s components separated by an empty space, or else return false
      guard let aWords = formatter.string(from: a)?.components(separatedBy: " "),
            let bWords = formatter.string(from: b)?.components(separatedBy: " ") else {
              return false
            }
      
//      print("---")
//      print("===== a:", a, "---")
//      print("===== b:", b, "---")
//      print("===== aWords:", aWords, "---")
//      print("===== bWords:", bWords, "---")
//      print("\n")
      
      var containsMatch = false
      // Iterate every word in the first array and see if its contained in the second array
      for aWord in aWords where bWords.contains(aWord) {
        containsMatch = true
        break
      }
      
      return containsMatch
    }
    // Subscribe and print out elements that are considered distinct based on the comparing logic you provided
    .subscribe(
      onNext: {
        print($0)
      }
    )
    .disposed(by: disposeBag)
}

//--- Example of: distinctUntilChanged(_:) ---
//10
//20
//200


//: [Next](@next)
