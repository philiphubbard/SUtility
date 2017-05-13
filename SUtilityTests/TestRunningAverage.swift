// Copyright (c) 2017 Philip M. Hubbard
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
// NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// http://opensource.org/licenses/MIT

import XCTest
@testable import SUtility

// Tests of RunningAverage.swift.

class TestRunningAverage: XCTestCase {
    
    func equal<T: FloatingPoint>(_ x: T, _ y: T, eps: T) -> Bool {
        return (abs(x - y) < eps)
    }
    
    func testAdd() {
        let eps: Float = 1e-4
        
        let capacity = 3
        let avg = RunningAverage<Float>(capacity: capacity)
        
        let firstValue: Float = 123.4
        
        for _ in 1...(2 * capacity) {
            avg.add(value: firstValue)
            XCTAssertTrue(equal(avg.value(), firstValue, eps: eps))
        }
        
        let secondValue: Float = 987.6
        
        for _ in 1...(2 * capacity) {
            avg.add(value: secondValue)
            XCTAssertGreaterThan(avg.value(), firstValue)
        }
        
        for _ in 1...(2 * capacity) {
            avg.add(value: secondValue)
            XCTAssertTrue(equal(avg.value(), secondValue, eps: eps))
        }
    }
 
    func testWindow1() {
        let capacity = 5
        let window: TimeInterval = 1.0
        let avg1 = RunningAverage<Double>(capacity: capacity, window: window)
        
        let values = [10.0, 20.0, 30.0]
        
        for value in values {
            avg1.add(value: value)
        }
        let expected = avg1.value()
        
        let avg2 = RunningAverage<Double>(capacity: capacity, window: window)

        avg2.add(value: 123456.7)
        sleep(UInt32(2.0 * window))

        for value in values {
            avg2.add(value: value)
        }
        let actual = avg2.value()

        let eps: Double = 1e-8
        XCTAssertTrue(equal(actual, expected, eps: eps))
    }
    
    func testWindow2() {
        let values = [-11.1, 22.2, -33.3]
        
        let capacity = 5
        let window: TimeInterval = TimeInterval(values.count)
        let avg1 = RunningAverage<Double>(capacity: capacity, window: window)
        
        for value in values {
            avg1.add(value: value)
        }
        let expected = avg1.value()
        
        let avg2 = RunningAverage<Double>(capacity: capacity, window: window)
        
        avg2.add(value: 1234.5)
        avg2.add(value: 2345.6)
        avg2.add(value: 3456.7)
        sleep(1)
        
        avg2.add(value: 4567.8)
        avg2.add(value: 5678.9)
        sleep(1)

        for value in values {
            avg2.add(value: value)
            sleep(1)
        }
        let actual = avg2.value()
        
        let eps: Double = 1e-8
        XCTAssertTrue(equal(actual, expected, eps: eps))
    }
    
}
