SUtility: Swift Utility Code
============================

By Philip M. Hubbard, 2017

Overview
--------

The SUtility framework implements some utility functionality in Swift.  Currently, its focus is the needs of the [FacetiousIOS](http://github.com/philiphubbard/FacetiousIOS) app: simple animation with ease-in-ease-out timing, and running averages of a sequence of sample values.

Implementation
--------------

The basic element of an animation is the `Segment` struct.  A `Segment` has initial and final values, a duration, and a closure to call when the segment is evaluated a particular moment in time.  Evaluation interpolates between the initial and final values, using a cosine-based ease-in-ease-out approach.  Ideally, `Segment` would be a generic, so the values could have any type conforming to a protocol; but no protocol in the Swift Standard Library supports the operations needed for the cosine-based interpolation, so the type of a value is `Float`.

The `Animation` struct takes an array of `Segment` instances and an initial time (which defaults to the value of `CACurrentMediaTime`).  Each `Segment` is treated as starting immediately after the previous one in the array, and evaluation of the `Animation` at a moment in time evaluates the `Segment` in the sequence containing that time.  An `Animation` can be initialized as "repeating," in which case evaluation at a time greater than the sum of all the `Segment` durations wraps around to the beginning.

An `Animation` can generate another `Animation` known as a "detour."  This `Animation` has a single `Segment` with a specified ending value, and matches the derivative of the original `Animation` at the particular moment in time when it was created.  An application thus can make a smooth transition to a detour when a user interactively interrupts an established `Animation` to enter a new state.  The [FacetiousIOS](http://github.com/philiphubbard/FacetiousIOS) app uses a detour to flip the geometry when the user changes cameras.

The SUtility framework also provides the `RunningAverage` class.  Its `value` method returns the average of the last *N* values that have been passed to it with the `add` method, where *N* is known as its "capacity".  It also supports a time "window", and when a new value is added any values old enough to be outside the time window are discarded, to reduce bias.  The `RunningAverage` class is a generic, and the values being averaged should conform to the `FloatingPoint` protocol from the Swift Standard Library.  The [FacetiousIOS](http://github.com/philiphubbard/FacetiousIOS) app uses `RunningAverage` to reduce the jitter in its face tracking.

Testing
-------

The unit tests for SUtility are based on the XCTest framework and run in Xcode in the standard way.  Currently, the tests have about 94% code coverage.

Building
--------

SUtility is a framework to facilitate reuse.  The simplest way to use it as part of an app is to add its project file to an Xcode workspace that includes the app project.  Some of the steps in getting a custom framework to work with an app on a device are subtle, but the following steps work:

1. Close the SUtility project if it is open in Xcode.
2. Open the workspace.
3. In the Project Navigator panel on the left side of Xcode, right-click and choose "Add Files to <workspace name>..."
4. In the dialog, from the "SUtility" folder choose "SUtility.xcodeproj" and press "Add".
5. Select the app project in the Project Navigator, and in the "General" tab’s "Linked Frameworks and Libraries", press the "+" button.
6. In the dialog, from the "Workspace" folder choose "SUtility.framework" and press "Add".
7. In the "Build Phase" tab, press the "+" button (top left) and choose "New Copy Files Phase."  This phase will install the framework when the app is installed on a device.
8. In the "Copy Files" area, change the "Destination" to "Frameworks".
9. Drag into this "Copy Files" area the "SUtility.framework" file from the "Products" folder for SUtility in the Project Navigator.  Note that it is important to *drag* the framework from the "Products" folder: the alternative---pressing the "+" button in the "Copy Files" area and choosing any of the "SUtility.framework" items listed---will appear to work but will fail at run time.
10. In the dialog that appears after dragging, use the default settings (i.e., only "Create folder references" is checked) and press "Finish".

SUtility does not depend on any other libraries, other than system libraries that appear by default in Xcode.  The specific version of Xcode used to develop SUtility was 8.3.
