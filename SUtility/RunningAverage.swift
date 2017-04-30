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

import QuartzCore

// A class to compute the running average of the last N values in a sequence.  If the previous
// values are old enough that they are outside a time window, then they are ignored, to avoid bias.

public class RunningAverage<T: FloatingPoint> {
    public private(set) var capacity: Int
    public private(set) var window: TimeInterval
    
    public init(capacity: Int, window: TimeInterval = 0.5) {
        self.capacity = capacity
        self.window = window
        reset()
    }
    
    public func add(value: T) {
        let now = CACurrentMediaTime()
        if now - timeOfLastAdd > window {
            reset()
        }
        timeOfLastAdd = now
        
        values[tail] = value
        tail = (tail + 1) % capacity
        count = min(count + 1, capacity)
    }
    
    public func value() -> T {
        guard count > 0 else {
            return 0
        }
        
        var result: T = 0
        for i in 0..<count {
            result += values[i]
        }
        return result / T(count)
    }
    
    private func reset() {
        values = Array<T>(repeating: 0, count: capacity)
        count = 0
        tail = 0
    }

    private var values: [T] = []
    private var count: Int = 0
    private var tail: Int = 0
    private var timeOfLastAdd: CFTimeInterval = 0
}
