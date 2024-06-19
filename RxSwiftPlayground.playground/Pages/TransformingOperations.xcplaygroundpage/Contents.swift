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

example(of: "toArray") {
  let disposeBag = DisposeBag()
  // Create a finite observable of letters
  Observable.of("A", "B", "C")
    // Use toArray to transform the individual elements into an array
    .toArray()
    .subscribe(
      onSuccess: {
        print($0)
      }
    )
    .disposed(by: disposeBag)
}

// result
// --- Example of: toArray ---
// ["A", "B", "C"]

example(of: "map") {
  let disposeBag = DisposeBag()
  // create a number formatter to spell out each number
  let formatter = NumberFormatter()
  formatter.numberStyle = .spellOut
  // create an observable of Int
  Observable<Int>.of(123, 4, 56)
    // use map, passing a closure that gets and returns the result of using the formatter to return the number’s spelled out string — or an empty string if that operation returns nil
    .map {
      formatter.string(for: $0) ?? ""
    }
    .subscribe(
      onNext: {
        print($0)
      }
    )
    .disposed(by: disposeBag)
}

// result
// --- Example of: map ---
// one hundred twenty-three
// four
// fifty-six

example(of: "enumerated and map") {
  let disposeBag = DisposeBag()
  // Create an observable of integers
  Observable.of(1, 2, 3, 4, 5, 6)
    // Use enumerated to produce tuple pairs of each element and its index
    .enumerated()
    // Use map, and destructure the tuple into individual arguments. If the element’s index is greater than 2, multiply it by 2 and return it; else, return it as-is
    .map { index, integer in
      index > 2 ? integer * 2 : integer
    }
    // Subscribe and print elements as they’re emitted
    .subscribe(
      onNext: {
        print($0)
      }
    )
    .disposed(by: disposeBag)
}

// Result
// --- Example of: enumerated and map ---
// 1
// 2
// 3
// 8
// 10
// 12

/**  The compactMap operator is a combination of the map and filter operators that specifically filters out nil values */

example(of: "compactMap") {
  let disposeBag = DisposeBag()
  // Create an observable of String?, which the of operator infers from the values
  Observable.of("To", "be", nil, "or", "not", "to", "be", nil)
    // Use the compactMap operator to retrieve unwrapped value, and filter out nils
    .compactMap {
      $0
    }
    // Use toArray to convert the observable into a Single that emits an array of all its values
    .toArray()
    // Use map to join the values together, separated by a space
    .map {
      $0.joined(separator: " ")
    }
    .subscribe(
      onSuccess: {
        // Print the result in the subscription
        print($0)
      }
    )
    .disposed(by: disposeBag)
}

// Result
// --- Example of: compactMap ---
// To be or not to be

/**
 *
 * Transforming inner observables
 *
 */

struct Student {
  let score: BehaviorSubject<Int>
}

/** flatMap projects and transforms an observable value of an observable, and then flattens it down to a target observable */

example(of: "flatMap") {
  let disposeBag = DisposeBag()
  // create two instances of Student, laura and charlotte
  let laura = Student(score: BehaviorSubject(value: 80))
  let charlotte = Student(score: BehaviorSubject(value: 90))
  // create a source subject of type Student
  let student = PublishSubject<Student>()
  
  student
    // use flatMap to reach into the student subject and project its score
    .flatMap {
      $0.score
    }
    // print out next event elements in the subscription
    .subscribe(
      onNext: {
        print($0)
      }
    )
    .disposed(by: disposeBag)
  
    
  student.onNext(laura) // 80
  
  laura.score.onNext(85) // 85
  
  student.onNext(charlotte) // 90
  // flatMap keeps up with each and every observable it creates
  laura.score.onNext(95) // 95
  
  charlotte.score.onNext(100) // 100
}

// Result
// --- Example of: flatMap ---
// 80
// 85
// 90
// 95
// 100

/** when you only want to keep up with the latest element in the source observable, use the flatMapLatest operator */

/**
 * The flatMapLatest operator is actually a combination of two operators: map and switchLatest
 */

/**
 * What makes flatMapLatest different is that it will automatically switch to the latest observable and unsubscribe from the previous one
 */

example(of: "flatMapLatest") {
  let disposeBag = DisposeBag()
  
  let laura = Student(score: BehaviorSubject(value: 80))
  let charlotte = Student(score: BehaviorSubject(value: 90))
  
  let student = PublishSubject<Student>()
  
  student
    .flatMapLatest {
      $0.score
    }
    .subscribe(
      onNext: {
        print($0)
      }
    )
    .disposed(by: disposeBag)
  
  student.onNext(laura) // 80
  laura.score.onNext(85) // 85
  student.onNext(charlotte) // 90
  // Changing laura’s score here will have no effect
  laura.score.onNext(95)
  charlotte.score.onNext(100) // 100
}

// Result
// --- Example of: flatMapLatest ---
// 80
// 85
// 90
// 100

/**
 * Observing events
 */

// when you do not have control over an observable that has observable properties, and you want to handle error events to avoid terminating outer sequences

example(of: "materialize and dematerialize") {
  // Create an error type
  enum MyError: Error {
    case anError
  }
  
  let disposeBag = DisposeBag()
  
  // Create two instances of Student and a student behavior subject with the first student laura as its initial value
  let laura = Student(score: BehaviorSubject(value: 80))
  let charlotte = Student(score: BehaviorSubject(value: 100))
  
  let student = BehaviorSubject(value: laura)
  // Create a studentScore observable using flatMapLatest to reach into the student observable and access its score observable property
  let studentScore = student.flatMapLatest {
//    $0.score
    $0.score.materialize() // studentScore is type of Observable<Event<Int>>
  }
  // Subscribe to and print out each score when it is emitted
  studentScore
    // Print and filter out any errors
    .filter {
      guard $0.error == nil else {
        print($0.error!)
        return false
      }
      return true
    }
    // Use dematerialize to return the studentScore observable to its original form, emitting scores and stop events, not events of scores and stop events
    .dematerialize()
    .subscribe(
      onNext: {
        print($0)
      }
    )
    .disposed(by: disposeBag)
  // Add a score, error, and another score onto the current student
  laura.score.onNext(85)
  laura.score.onError(MyError.anError)
  laura.score.onNext(90)
  // Add the second student charlotte onto the student observable. Because you used flatMapLatest, this will switch to this new student and subscribe to her score
  student.onNext(charlotte)
  
}

// Result
// --- Example of: materialize and dematerialize ---
// 80
// 85
// anError
// 100
//: [Next](@next)
