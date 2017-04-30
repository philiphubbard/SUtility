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

import Foundation

// An animation defined as a sequence of segments.  Each segment provides ease-in-ease-out
// interpolation between a starting and ending value.  A "detour" animation can be created at a
// any point in an original animation, providing a smooth transition to a new ending value.

// TODO: Ideally this struct would be a generic, but there does not seem to be any protocol in the 
// Swift Standard Library that supports the operations involving "cos" in the Segment.evaluate() 
// function (e.g., not Arithmetic or FloatingPoint).

public struct Animation {
    
    // A segment in the animation.
    
    public struct Segment {
        public let val0: Float
        public let val1: Float
        public let duration: TimeInterval
        public let onEvaluate: (Float) -> Void
        
        public init (val0: Float, val1: Float, duration: TimeInterval, onEvaluate: @escaping (Float) -> Void) {
            self.val0 = val0
            self.val1 = val1
            self.duration = duration
            self.onEvaluate = onEvaluate
        }
        
        fileprivate func contains(t: TimeInterval) -> Bool {
            return ((0 <= t) && (t < duration))
        }
        
        fileprivate func value(t: TimeInterval) -> Float {
            if t < 0 {
                return val0
            } else if t >= duration {
                return val1
            }
            let u = (1 - cos(t / duration * TimeInterval.pi)) / 2.0
            let val = val0 + Float(u) * (val1 - val0)
            return val
        }
        
        fileprivate func derivative(t: TimeInterval) -> Float {
            if (t < 0) || (t >= duration) {
                return 0
            }
            return Float(0.5 * sin(t / duration * TimeInterval.pi) * TimeInterval.pi / duration)
        }
        
        fileprivate func evaluate(t: TimeInterval) {
            onEvaluate(value(t: t))
        }
        
        fileprivate func detour(t: TimeInterval, val1MagnitudeDetour: Float, durationDetour: TimeInterval) -> (Segment, TimeInterval)? {
            // To make the transition to the detour as smooth as possible, it should have the same 
            // derivative as the current segment at t.
            
            let deriv = derivative(t: t)
            
            // Set the formula for the derivative (using the detour duration) equal to the current 
            // segment's derivative and solve for t, which we call tDetour.  The t0 for the detour 
            // animation will be the current time minus this tDetour.
            
            let s = 2 * durationDetour * TimeInterval(deriv) / TimeInterval.pi
            var tDetour: TimeInterval
            if (-1.0 <= s) && (s <= 1.0) {
                tDetour = durationDetour / TimeInterval.pi * asin(s)
            } else {
                
                // But if the detour cannot match the segment's derivative, just use the midpoint.
                
                tDetour = durationDetour / 2
            }
            
            // The detour is meant to continue in the direction of the current segment, so negate 
            // the detour's val1 if necessary.

            let val = value(t: t)
            let val1Detour = ((val1 < val) && (val1MagnitudeDetour > val)) ? -val1MagnitudeDetour : val1MagnitudeDetour

            // To find the val0 for the detour animation's segment, set the formula for the value 
            // (using the detour duration) equal to the current segment's value at t and solve for 
            // val0.
            
            let u = Float(1 - cos(tDetour / durationDetour * TimeInterval.pi)) / 2.0
            
            // For u to be 1, cos(tDetour / durationDetour * pi) must be -1.  So 
            // tDetour / durationDetour must be 1.  So, looking at the definition of tDetour above, 
            // asin(s) / pi must be 1.  So asin(s) must be pi.  But by definition, asin(s) is 
            // between -pi/2 and pi/2.  So The following case should never occur.
            
            if u == 1 {
                return nil
            }

            let val0Detour = (val - u * val1Detour) / (1 - u)

            return (Segment(val0: val0Detour, val1: val1Detour, duration: durationDetour, onEvaluate: onEvaluate), tDetour)
        }
    }
    
    // The overall animation.
    
    public let t0: TimeInterval
    public let duration: TimeInterval
    public let repeating: Bool

    public init(segments: [Segment], repeating: Bool = true, t0: TimeInterval = CACurrentMediaTime()) {
        self.t0 = t0
        self.segments = segments
        self.duration = segments.reduce(0, { result, segment in result + segment.duration })
        self.repeating = repeating
    }
    
    public func finished(t: TimeInterval = CACurrentMediaTime()) -> Bool {
        if repeating {
            return false
        }
        return t > t0 + duration
    }
    
    // If t < t0, does nothing.
    // If t > t0 + S where S is the sum of the durations of all segments, then:
    // - if repeating is false, returns val1 of the last segment
    // - if repeating is true, ...
    public func evaluate(t: TimeInterval = CACurrentMediaTime()) {
        if let (segment, tEval) = segmentContaining(t: t) {
            segment.evaluate(t: tEval)
        }
    }

    public func detour(t: TimeInterval = CACurrentMediaTime(), endMagnitude val1MagnitudeDetour: Float, duration durationDetour: TimeInterval) -> Animation? {
        if let (segment, tEval) = segmentContaining(t: t) {
            if let (segmentDetour, tDetour) = segment.detour(t: tEval, val1MagnitudeDetour: val1MagnitudeDetour, durationDetour: durationDetour) {
                let newAnimation = Animation(segments: [segmentDetour], repeating: false, t0: t - tDetour)
                return newAnimation
            }
        }
        
        return nil
    }

    private func segmentContaining(t: TimeInterval) -> (Segment, TimeInterval)? {
        var tEval = t - t0
        if repeating {
            tEval = tEval.truncatingRemainder(dividingBy: duration)
        }
        var t0Segment = 0.0
        for segment in segments {
            let tEvalSegment = tEval - t0Segment
            if segment.contains(t: tEvalSegment) {
                return (segment, tEvalSegment)
            }
            t0Segment += segment.duration
        }
        
        // Make sure to really evaluate the final value of a non-repeating animation.
        if (!repeating) && (tEval > 0) {
            if let segment = segments.last {
                return (segment, tEval)
            }
        }
        
        return nil
    }
    
    private let segments: [Segment]
}
