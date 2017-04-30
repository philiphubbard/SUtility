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

// Tests of Animation.swift.

class TestAnimation: XCTestCase {
    
    func equal<T: FloatingPoint>(_ x: T, _ y: T, eps: T) -> Bool {
        return (abs(x - y) < eps)
    }
    
    static var evalResult: Float? = nil
    let eval = { val in evalResult = val }
    
    func testValuesNotRepeating() {
        let val0A: Float = -5.0
        let val1A: Float =  5.0
        let val0B: Float = val1A
        let val1B: Float = 25.0
        
        let durationA: TimeInterval = 12.3
        let durationB: TimeInterval = 45.6
        let segments = [
            Animation.Segment(val0: val0A, val1: val1A, duration: durationA, onEvaluate: eval),
            Animation.Segment(val0: val0B, val1: val1B, duration: durationB, onEvaluate: eval)
        ]
        let t0: TimeInterval = 7.8
        let animation = Animation(segments: segments, repeating: false, t0: t0)
        
        XCTAssertFalse(animation.finished(t: t0 - 1.0))
        TestAnimation.evalResult = nil
        animation.evaluate(t: t0 - 1.0)
        XCTAssertNil(TestAnimation.evalResult)
        
        XCTAssertFalse(animation.finished(t: t0 + durationA * 0.25))
        TestAnimation.evalResult = nil
        animation.evaluate(t: t0 + durationA * 0.25)
        XCTAssertNotNil(TestAnimation.evalResult)
        XCTAssertGreaterThan(TestAnimation.evalResult!, val0A)
        XCTAssertLessThan(TestAnimation.evalResult!, val1A)

        XCTAssertFalse(animation.finished(t: t0 + durationA + durationB * 0.75))
        TestAnimation.evalResult = nil
        animation.evaluate(t: t0 + durationA + durationB * 0.75)
        XCTAssertNotNil(TestAnimation.evalResult)
        XCTAssertGreaterThan(TestAnimation.evalResult!, val0B)
        XCTAssertLessThan(TestAnimation.evalResult!, val1B)

        XCTAssertTrue(animation.finished(t: t0 + durationA + durationB + 1.0))
        TestAnimation.evalResult = nil
        animation.evaluate(t: t0 + durationA + durationB + 1.0)
        XCTAssertNotNil(TestAnimation.evalResult)
        XCTAssertEqual(TestAnimation.evalResult!, val1B)
    }

    func testValuesRepeating() {
        let val0A: Float = 100
        let val1A: Float = 200
        let val0B: Float = val1A
        let val1B: Float = val0A
        
        let durationA: TimeInterval = 10.9
        let durationB: TimeInterval = 8.7
        let segments = [
            Animation.Segment(val0: val0A, val1: val1A, duration: durationA, onEvaluate: eval),
            Animation.Segment(val0: val0B, val1: val1B, duration: durationB, onEvaluate: eval)
        ]
        let t0: TimeInterval = 6.5
        let animation = Animation(segments: segments, repeating: true, t0: t0)
        
        XCTAssertFalse(animation.finished(t: t0 - 1.0))
        TestAnimation.evalResult = nil
        animation.evaluate(t: t0 - 1.0)
        XCTAssertNil(TestAnimation.evalResult)
        
        XCTAssertFalse(animation.finished(t: t0 + durationA * 0.6))
        TestAnimation.evalResult = nil
        animation.evaluate(t: t0 + durationA * 0.6)
        XCTAssertNotNil(TestAnimation.evalResult)
        XCTAssertGreaterThan(TestAnimation.evalResult!, val0A)
        XCTAssertLessThan(TestAnimation.evalResult!, val1A)
        
        XCTAssertFalse(animation.finished(t: t0 + durationA + durationB * 0.3))
        TestAnimation.evalResult = nil
        animation.evaluate(t: t0 + durationA + durationB * 0.3)
        XCTAssertNotNil(TestAnimation.evalResult)
        XCTAssertLessThan(TestAnimation.evalResult!, val0B)
        XCTAssertGreaterThan(TestAnimation.evalResult!, val1B)
        
        XCTAssertFalse(animation.finished(t: t0 + durationA + durationB + 1.0))
        TestAnimation.evalResult = nil
        animation.evaluate(t: t0 + durationA + durationB + 1.0)
        XCTAssertNotNil(TestAnimation.evalResult)
        XCTAssertGreaterThan(TestAnimation.evalResult!, val0A)
        XCTAssertLessThan(TestAnimation.evalResult!, val1A)
    }
    
    func testEaseInOut() {
        var vals: Array<Float> = []
        let evalArray = { val in vals.append(val) }
        
        let duration: TimeInterval = 10.0
        let t0: TimeInterval = 0.0
        let segments = [Animation.Segment(val0: 0.0, val1: 9.0, duration: duration, onEvaluate: evalArray)]
        let animation = Animation(segments: segments, t0: t0)
        
        let n = 20
        let deltaT = duration / TimeInterval(n)
        var ts: Array<TimeInterval> = []
        for i in 0..<n {
            ts.append(t0 + TimeInterval(i) * deltaT)
        }
        for t in ts {
            animation.evaluate(t: t)
        }
        
        var intervals: Array<Float> = []
        var valPrev: Float? = nil
        for val in vals {
            if let valPrev = valPrev {
                intervals.append(val - valPrev)
            }
            valPrev = val
        }
        
        let mid = intervals.count / 2
        let firstHalf = intervals.prefix(upTo: mid)
        let secondHalf = intervals.suffix(from: mid)
        
        var intervalPrev: Float? = nil
        for interval in firstHalf {
            if let intervalPrev = intervalPrev {
                XCTAssertGreaterThan(interval, intervalPrev)
            }
            intervalPrev = interval
        }
        
        intervalPrev = nil
        for interval in secondHalf {
            if let intervalPrev = intervalPrev {
                XCTAssertLessThan(interval, intervalPrev)
            }
            intervalPrev = interval
        }
    }
    
    func assertDetourTransition(animation: Animation, detour: Animation, t: TimeInterval) {
        let tDelta = 1e-4
        
        TestAnimation.evalResult = nil
        animation.evaluate(t: t - tDelta)
        XCTAssertNotNil(TestAnimation.evalResult)
        let valA = TestAnimation.evalResult!
        
        TestAnimation.evalResult = nil
        animation.evaluate(t: t)
        XCTAssertNotNil(TestAnimation.evalResult)
        let valB = TestAnimation.evalResult!
        
        let change = valB - valA
        
        TestAnimation.evalResult = nil
        detour.evaluate(t: t)
        XCTAssertNotNil(TestAnimation.evalResult)
        let detourValA = TestAnimation.evalResult!
        
        TestAnimation.evalResult = nil
        detour.evaluate(t: t + tDelta)
        XCTAssertNotNil(TestAnimation.evalResult)
        let detourValB = TestAnimation.evalResult!
        
        let detourChange = detourValB - detourValA
        
        XCTAssertTrue(equal(change, detourChange, eps: 1e-4))
    }
    
    func assertDetourValues(animation: Animation, detour: Animation, detourEndMagnitude: Float, t: TimeInterval) {
        TestAnimation.evalResult = nil
        animation.evaluate(t: t)
        XCTAssertNotNil(TestAnimation.evalResult)
        let val = TestAnimation.evalResult!
        
        TestAnimation.evalResult = nil
        detour.evaluate(t: t)
        XCTAssertNotNil(TestAnimation.evalResult)
        let valDetour = TestAnimation.evalResult!
        
        XCTAssertTrue(equal(val, valDetour, eps: 1e-4))
        
        TestAnimation.evalResult = nil
        detour.evaluate(t: detour.t0 + detour.duration)
        XCTAssertNotNil(TestAnimation.evalResult)
        let val1Detour = TestAnimation.evalResult!
        
        XCTAssertTrue(equal(val1Detour, detourEndMagnitude, eps: 1e-4))
    }
    
    func testDetourIdentical() {
        let val0: Float = 9
        let val1: Float = 8
        let duration: TimeInterval = 7
        let segments = [Animation.Segment(val0: val0, val1: val1, duration: duration, onEvaluate: eval)]
        let t0: TimeInterval = 6
        let animation = Animation(segments: segments, repeating: false, t0: t0)
        
        let tDetour = t0 + duration / 3
        let detourEndMagnitude: Float = val1
        let detourDuration: TimeInterval = duration
        let detour = animation.detour(t: tDetour, endMagnitude: detourEndMagnitude, duration: detourDuration)
        XCTAssertNotNil(detour)
        
        assertDetourValues(animation: animation, detour: detour!, detourEndMagnitude: detourEndMagnitude, t: tDetour)

        assertDetourTransition(animation: animation, detour: detour!, t: tDetour)
    }

    func testDetour() {
        let val0: Float = 5
        let val1: Float = 6
        let duration: TimeInterval = 7
        let segments = [Animation.Segment(val0: val0, val1: val1, duration: duration, onEvaluate: eval)]
        let t0: TimeInterval = 8
        let animation = Animation(segments: segments, repeating: false, t0: t0)
        
        let tDetour = t0 + duration / 3
        let detourEndMagnitude: Float = 9
        let detourDuration: TimeInterval = duration / 2
        let detour = animation.detour(t: tDetour, endMagnitude: detourEndMagnitude, duration: detourDuration)
        XCTAssertNotNil(detour)
        
        assertDetourValues(animation: animation, detour: detour!, detourEndMagnitude: detourEndMagnitude, t: tDetour)

        assertDetourTransition(animation: animation, detour: detour!, t: tDetour)
    }

    func testDetourTooEarly() {
        let val0: Float = 123
        let val1: Float = 456
        let duration: TimeInterval = 789
        let segments = [Animation.Segment(val0: val0, val1: val1, duration: duration, onEvaluate: eval)]
        let t0: TimeInterval = 10
        let animation = Animation(segments: segments, t0: t0)
        
        let tDetour = t0 - 1
        let detourEndMagnitude: Float = 2
        let detourDuration: TimeInterval = 3
        let detour = animation.detour(t: tDetour, endMagnitude: detourEndMagnitude, duration: detourDuration)
        XCTAssertNil(detour)
    }

    func testDetourTooSlow() {
        let val0: Float = 123
        let val1: Float = 456
        let duration: TimeInterval = 789
        let segments = [Animation.Segment(val0: val0, val1: val1, duration: duration, onEvaluate: eval)]
        let t0: TimeInterval = 10
        let animation = Animation(segments: segments, t0: t0)
        
        let tDetour = t0 + duration / 2
        let detourEndMagnitude: Float = val0 + (val1 - val0) / 2
        let detourDuration = duration
        let detour = animation.detour(t: tDetour, endMagnitude: detourEndMagnitude, duration: detourDuration)
        XCTAssertNotNil(detour)
        
        assertDetourValues(animation: animation, detour: detour!, detourEndMagnitude: detourEndMagnitude, t: tDetour)
    }

}
