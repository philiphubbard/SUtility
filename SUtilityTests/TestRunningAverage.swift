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
    
    func testWindow() {
        let eps: Double = 1e-8
        
        let capacity = 5
        let window: TimeInterval = 0.3
        let avg = RunningAverage<Double>(capacity: capacity, window: window)
        
        let firstValue: Double = -12345.6
        
        for _ in 1...(2 * capacity) {
            avg.add(value: firstValue)
            XCTAssertTrue(equal(avg.value(), firstValue, eps: eps))
        }
        
        let period = UInt32(5.0 * window)
        sleep(period)
        
        let secondValue: Double = 98765.4
        
        avg.add(value: secondValue)
        XCTAssertTrue(equal(avg.value(), secondValue, eps: eps))
    }

}
