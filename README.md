# ConlangBuilder

A native macOS app for creating a constructed language.
Currently very much a work in progress, with no features complete yet, though some UI work is done.
The schema may change in breaking ways while in development.
Understand that saved documents may not be openable by different verions (until an official release is available).

This project is build primarily in SwiftUI and SwiftData, though some UI does drop down to AppKit to get better perforamnce.
Still trying to understand how best to work with SwiftData from within AppKit.

The long-term goal for this project is to be able to support the full development of constructed langauges (conlangs).
Currently only words and definitions can be added, though in the future there will be support for parts of speech, conjucations, and more.

To build, simply open in Xcode (only tested with Xcodee 16.3) and build – no additional setup should be required (though signing may need to be altered).
