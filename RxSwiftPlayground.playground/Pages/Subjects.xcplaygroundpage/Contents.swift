//: [Previous](@previous)
import Foundation
// Remember check the RxRelay Scheme and build it
import RxRelay
import RxSwift

/// Copyright (c) 2024 Justin
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

example(of: "PublishSubject") {
  // it will receive information and then publish it to subscribers
  let subject = PublishSubject<String>()
  // This puts a new string onto the subject.
  subject.on(.next("Is anyone listening?"))
  // You created a subscription to subject just like in the last chapter, printing next events
  let subscriptionOne = subject.subscribe(onNext: { string in
    print(string)
  })
  // a PublishSubject only emits to current subscribers. So if you weren’t subscribed to it when an event was added to it, you won’t get it when you do subscribe
  subject.on(.next("1"))
  // onNext(_:) does the same thing as on(.next(_)). It’s just a bit easier on the eyes.
  subject.onNext("2")
  
  let subscriptionTwo = subject.subscribe { event in
    print("2),", event.element ?? event)
  }
  
  subject.onNext("3")
  
  subscriptionOne.dispose()
  
  subject.onNext("4")
  // Add a completed event onto the subject, using the convenience method for on(.completed). This terminates the subject’s observable sequence.
  subject.onCompleted()
  // Add another element onto the subject. This won’t be emitted and printed, though, because the subject has already terminated.
  subject.onNext("5")
  // Dispose of the subscription.
  subscriptionTwo.dispose()
  
  let disposeBag = DisposeBag()
  // Subscribe to the subject, this time adding its disposable to a dispose bag.
  subject.subscribe {
    print("3),", $0.element ?? $0)
  }.disposed(by: disposeBag)
  
  subject.onNext("?")
}

// Subjects act as both an observable and an observer
// - PublishSubject: Starts empty and only emits new elements to subscribers.
// - BehaviorSubject: Starts with an initial value and replays it or the latest element to new subscribers.
// - ReplaySubject: Initialized with a buffer size and will maintain a buffer of elements up to that size and replay it to new subscribers.
// - AsyncSubject: Emits only the last next event in the sequence, and only when the subject receives a completed event. This is a seldom used kind of subject, and you won’t use it in this book. It’s listed here for the sake of completeness.
// PublishRelay and BehaviorRelay
// These wrap their respective subjects, but only accept and relay next events.
//  You cannot add a completed or error event onto relays at all, so they’re great for non-terminating sequences

// Actually, subjects, once terminated, will re-emit their stop event to future subscribers
// Publish subjects don’t replay values to new subscribers. This makes them a good choice to model events such as “user tapped something” or “notification just arrived.”

/**  Working with behavior subjects */

// Behavior subjects work similarly to publish subjects, except they will replay the latest next event to new subscribers.

// Define an error type to use in upcoming examples.
enum MyError: Error {
  case anError
}

// create a helper function to print the element if there is one, an error if there is one, or else the event itself.
func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
  print(label, (event.element ?? event.error) ?? event)
}

// Start a new example.
// Because BehaviorSubject always emits its latest element, you can’t create one without providing an initial value. If you can’t provide an initial value at creation time, that probably means you need to use a PublishSubject instead, or model your element as an Optional
example(of: "BehaviorSubject") {
  // Create a new BehaviorSubject instance. Its initializer takes an initial value
  let subject = BehaviorSubject(value: "Initial value")
  let disposeBag = DisposeBag()
  
  subject.onNext("X")
  
  subject
    .subscribe {
      print(label: "1)", event: $0)
    }
    .disposed(by: disposeBag)
  
  // Add an error event onto the subject.
  subject.onError(MyError.anError)
  
  // Create a new subscription to the subject.
  subject
    .subscribe {
      print(label: "2)", event: $0)
    }
    .disposed(by: disposeBag)
}

/** Working with replay subjects **/
// Keep in mind, when using a replay subject, that this buffer is held in memory. You can definitely shoot yourself in the foot here, such as if you set a large buffer size for a replay subject of some type whose instances each take up a lot of memory, like images.
// Another thing to watch out for is creating a replay subject of an array of items. Each emitted element will be an array, so the buffer size will buffer that many arrays. It would be easy to create memory pressure here if you’re not careful.

example(of: "ReplaySubject") {
  // Create a new replay subject with a buffer size of 2. Replay subjects are initialized using the type method create(bufferSize:).
  let subject = ReplaySubject<String>.create(bufferSize: 2)
  let disposeBag = DisposeBag()
  // Add three elements onto the subject.
  subject.onNext("1")
  subject.onNext("2")
  subject.onNext("3")
  // Create two subscriptions to the subject.
  subject
    .subscribe {
      print(label: "1)", event: $0)
    }
    .disposed(by: disposeBag)
  
  subject
    .subscribe {
      print(label: "2)", event: $0)
    }
    .disposed(by: disposeBag)
  
  subject.onNext("4")
  subject.onError(MyError.anError)
  // Explicitly calling dispose() on a replay subject like this isn’t something you generally need to do. already has got a dispose bag
  subject.dispose()
  
  // without subject.dispose, the buffer is also still hanging around, so it gets replayed to new subscribers as well, before the stop event is re-emitted, get 3, 4, error
  // By explicitly calling dispose() on the replay subject beforehand, new subscribers will only receive an error event indicating that the subject was already disposed.
  subject
    .subscribe {
      print(label: "3)", event: $0)
    }
    .disposed(by: disposeBag)
  
}

/** Working with relays **/
// add a value onto a relay by using the accept(_:) method. In other words, you don’t use onNext(_:). This is because relays can only accept values, i.e., you cannot add an error or completed event onto them.
// A PublishRelay wraps a PublishSubject and a BehaviorRelay wraps a BehaviorSubject.
// never terminate

example(of: "PublishRelay") {
  let relay = PublishRelay<String>()
  
  let disposeBag = DisposeBag()
  //  use the accept(_:) method
  relay.accept("Knock knock, anyone home?")
  
  relay
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
  
  relay.accept("1")
  
  // There is no way to add an error or completed event onto a relay. Any attempt to do so such as the following will generate a compiler error (don’t add this code to your playground, it won’t work)
//  relay.accept(MyError.anError)
//  relay.onCompleted()
}

/** BehaviorRelay **/
example(of: "BehaviorRelay") {
  // create a behavior relay with an initial value. The relay’s type is inferred, but you could also explicitly declare the type as BehaviorRelay<String>(value: "Initial value")
  let relay = BehaviorRelay(value: "Initial value")
  let disposeBag = DisposeBag()
  // Add a new element onto the relay
  relay.accept("New initial value")
  // Subscribe to the relay
  relay
    .subscribe {
      print(label: "1)", event: $0)
    }
    .disposed(by: disposeBag)
  // Add a new element onto the relay.
  relay.accept("1")
  // Create a new subscription to the relay.
  relay
    .subscribe {
      print(label: "2)", event: $0)
    }
    .disposed(by: disposeBag)
  // Add another new element onto the relay.
  relay.accept("2")
  // Remember, behavior relays let you directly access their current value.
  print(relay.value)
}
//: [Next](@next)
