//: [Previous](@previous)
import UIKit
import RxSwift
import RxCocoa


// Start coding here


// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
  static func make() -> TimelineView<E> {
    return TimelineView(width: 400, height: 100)
  }
  public func on(_ event: Event<E>) {
    switch event {
    case .next(let value):
      add(.next(String(describing: value)))
    case .completed:
      add(.completed())
    case .error(_):
      add(.error())
    }
  }
}
/// Copyright (c) 2020 Razeware LLC
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

let elementsPerSecond = 1
let maxElements = 58
let replayedElements = 1
let replayDelay: TimeInterval = 3

//let sourceObservable = Observable<Int>.create { observer in
//  var value = 1
//  let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
//    if value <= maxElements {
//      observer.onNext(value)
//      value += 1
//    }
//  }
//  return Disposables.create {
//    timer.suspend()
//  }
//}//.replay(replayedElements)
//  .replayAll() // all buffered elements emitted instantly upon the second subscription

let sourceObservable = Observable<Int>.interval(.milliseconds(Int(1000.0 / Double(elementsPerSecond))), scheduler: MainScheduler.instance).replay(replayedElements)


let sourceTimeline = TimelineView<Int>.make()
let replayedTimeline = TimelineView<Int>.make()

let stack = UIStackView.makeVertical([
  UILabel.makeTitle("replay"),
  UILabel.make("Emit \(elementsPerSecond) per second:"),
  sourceTimeline,
  UILabel.make("Replay \(replayedElements) after \(replayDelay) sec:"),
  replayedTimeline
])

_ = sourceObservable.subscribe(sourceTimeline)

DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
  _ = sourceObservable.subscribe(replayedTimeline)
}

//Note: Connectable observables are a special class of observables. Regardless of their number of subscribers, they won‘t start emitting items until you call their connect() method. While this is beyond the scope of this chapter, remember that a few operators return ConnectableObservable<E>, not Observable<E>. These operators are:
//replay(_:)
//replayAll()
//multicast(_:)
//publish()
//Replay operators are covered in this chapter. The last two operators are advanced, and only touched on briefly in this book. They allow sharing a single subscription to an observable, regardless of the number of observers.

_ = sourceObservable.connect()

let hostView = setupHostView()
hostView.addSubview(stack)
hostView
//: [Next](@next)
