import Foundation
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

/** Creating observables */

example(of: "just, of, from") {
  let one = 1
  let two = 2
  let three = 3
  
  let observable = Observable<Int>.just(one)
  let observable2 = Observable.of(one, two, three)
  let observable3 = Observable.of([one, two, three])
  let observable4 = Observable.from([one, two, three])
}

/** Subscribing to observables */

example(of: "subscribe") {
  let one = 1
  let two = 2
  let three = 3
  
  let observable = Observable.of(one, two, three)
  
//    observable.subscribe { event in
//      print(event)
//    }
  
  //  observable.subscribe { event in
  //    if let element = event.element {
  //      print(element)
  //    }
  //  }
  
  observable.subscribe(onNext: { element in
    print(element)
  })
}

// What use is an empty observable?
// They’re handy when you want to
// - return an observable that immediately terminates
// - or intentionally has zero values.
example(of: "empty") {
  let observable = Observable<Void>.empty()
  
  observable.subscribe(
    onNext: { element in
      print(element)
    },
    onCompleted: {
      print("Completed")
    }
  )
}

example(of: "never") {
  let observable = Observable<Void>.never()
  
  observable.subscribe(
    onNext: { element in
      print(element)
    },
    onCompleted: {
      print("Completed")
    }
  )
}

example(of: "never - challenge") {
  let disposeBag = DisposeBag()
  
  let observable = Observable<Void>.never()
  
  observable
    .do(
      onNext: { element in print("onNext: \(element)") },
      afterNext: { element in print("afterNext: \(element)") },
      onError: { error in print("onError: \(error)") },
      afterError: { error in print("afterError: \(error)") },
      onCompleted: { print("onCompleted") },
      afterCompleted: { print("afterCompleted") },
      onSubscribe: { print("onSubscribe") },
      onSubscribed: { print("onSubscribed") },
      onDispose: { print("onDispose") }
    )
      .subscribe(
        onNext: { element in
          print(element)
        },
        onCompleted: {
          print("Completed")
        },
        onDisposed: {
          print("Disposed")
        }
      )
      .disposed(by: disposeBag)
      }

example(of: "never - challenge - 2") {
  let disposeBag = DisposeBag()
  
  let observable = Observable<Void>.never()
  
  observable
    .debug("never-challenge-2")
    .subscribe(
      onNext: { element in
        print(element)
      },
      onCompleted: {
        print("Completed")
      },
      onDisposed: {
        print("Disposed")
      }
    )
    .disposed(by: disposeBag)
}

example(of: "range") {
  let observable = Observable.range(start: 1, count: 10)
  
  observable.subscribe(
    onNext: { i in
      let n = Double(i)
      let fibonacci = Int(
        ((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded()
      )
      print(fibonacci)
    }
  )
}

/** Disposing and terminating */
example(of: "dispose") {
  // 1 - Create an observable of strings
  let observable = Observable.of("A", "B", "C")
  // 2 - Subscribe to the observable, saving the returned Disposable as a local constant
  let subscription = observable.subscribe { event in
    // 3 - Print each emitted event in the handler
    print(event)
  }
  // 4 - to explicitly cancel a subscription
  subscription.dispose()
}

/**
 *
 * 1 - If you forget to add a subscription to a dispose bag,
 * 2 - or forget to manually call dispose on it when you’re done with the subscription,
 * 3 - or in some other way cause the observable to terminate at some point,
 * you will probably leak memory
 *
 * Don’t worry if you forget; the Swift compiler should warn you about unused disposables
 *
 */
example(of: "DisposeBag") {
  // 1 - create a dispose bag
  let disposeBag = DisposeBag()
  // 2 - create an observable
  Observable.of("A", "B", "C")
  // 3 - subscribe to the observable and print out the emitted events using the default argument name $0.
    .subscribe {
      print($0)
      // 4 - add the returned Disposable from subscribe to the dispose bag
    }.disposed(by: disposeBag)
}

example(of: "create") {
  enum MyError: Error {
    case anError
  }
  let disposeBag = DisposeBag()
  
  Observable<String>.create { observer in
    // defines all the events that will be emitted to subscribers
    
    // 1 - add a next event onto the observer
    // onNext(_:) is a convenience method for on(.next(_:))
    observer.onNext("1")
    // 5 - add an error to the observer
    observer.onError(MyError.anError)
    // 2 - add a completed event onto the observer
    // onCompleted is a convenience method for on(.completed)
    observer.onCompleted()
    // 3 - add another next event onto the observer
    observer.onNext("?")
    // 4 - return a disposable,
    // defining what happens when your observable is terminated or disposed of
    // in this case, no cleanup is needed so you return an empty disposable
    return Disposables.create()
  }
  .subscribe(
    onNext: { print($0) },
    onError: { print($0) },
    onCompleted: { print("Completed") },
    onDisposed: { print("Disposed") }
  )
  .disposed(by: disposeBag)
}

/**
 *
 * Creating observable factories
 *
 */
example(of: "deferred") {
  let disposeBag = DisposeBag()
  
  // 1 - create a Bool flag to flip which observable to return
  var flip = false
  
  // 2 - create an observable of Int factory using the deferred operator
  let factory: Observable<Int> = Observable.deferred {
    
    // 3 - toggle flip
    // happens each time factory is subscribed to
    flip.toggle()
    
    // 4 - return different observables based on whether flip is true or false
    if flip {
      return Observable.of(1, 2, 3)
    } else {
      return Observable.of(4, 5, 6)
    }
  }
  
  for _ in 0...3 {
    factory.subscribe(
      onNext: {
        print($0, terminator: "")
      }
    ).disposed(by: disposeBag)
    
    print()
  }
}

/** Using Traits */

/**
 *
 * There are three kinds of traits in RxSwift: Single, Maybe and Completable
 *
 * Singles will emit either a success(value) or error(error) event. success(value) is actually a combination of the next and completed events. This is useful for one-time processes that will either succeed and yield a value or fail, such as when downloading data or loading it from disk.
 *
 * A Completable will only emit a completed or error(error) event. It will not emit any values. You could use a completable when you only care that an operation completed successfully or failed, such as a file write.
 *
 * Maybe is a mashup of a Single and Completable. It can either emit a success(value), completed or error(error). If you need to implement an operation that could either succeed or fail, and optionally return a value on success, then Maybe is your ticket.
 *
 */
example(of: "Single") {
  // 1 - create a dispose bag to use later.
  let disposeBag = DisposeBag()
  
  // 2 - define an Error enum to model some possible errors that can occur in reading data from a file on disk
  enum FileReadError: Error {
    case fileNotFound, unreadable, encodingFailed
  }
  
  // 3 - implement a function to load text from a file on disk that returns a Single
  func loadText(from name: String) -> Single<String> {
    // 4 - create and return a Single
    return Single.create { single in
      // 4.1 - create a Disposable, because the subscribe closure of create expects it as its return type
      let disposable = Disposables.create()
      
      // 4.2 - get the path for the filename, or else add a file not found error onto the Single and return the disposable you created
      guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
        single(.error(FileReadError.fileNotFound))
        return disposable
      }
      
      // 4.3 - get the data from the file at that path, or add an unreadable error onto the Single and return the disposable
      guard let data = FileManager.default.contents(atPath: path) else {
        single(.error(FileReadError.unreadable))
        return disposable
      }
      
      // 4.4 - convert the data to a string; otherwise, add an encoding failed error onto the Single and return the disposable
      guard let contents = String(data: data, encoding: .utf8) else {
        single(.error(FileReadError.encodingFailed))
        return disposable
      }
      
      // 4.5 - add the contents onto the Single as a success, and return the disposable
      single(.success(contents))
      return disposable
    }
  }
  
  // 5 - call loadText(from:) and pass the root name of the text file
  loadText(from: "Copyright")
  // 5.1 - subscribe to the Single it returns
    .subscribe {
      // 5.2 - switch on the event and print the string if it was successful, or print the error if not
      switch $0 {
      case .success(let string):
        print(string)
      case .error(let error):
        print(error)
      }
    }
    .disposed(by: disposeBag)
}

//: [Next](@next)
