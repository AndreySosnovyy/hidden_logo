## 1.3.2

* Restore the original README sections and practical tips with current usage and compatibility information.

## 1.3.1

* Simplify README to package usage and compatibility; move development instructions to CONTRIBUTING.md.
* Trim the example guide and update the device support guide and documentation checks.
* Clarify capture timing in API documentation; runtime behavior is unchanged.

## 1.3.0

* Add documentation and manifest consistency checks, including native asset references
* Correct the CocoaPods license declaration to match the existing BSD-3-Clause license
* Compile and run the README usage example in CI; provide its missing app route
* Add minimum/current SDK CI builds for Web, Linux, Windows and macOS examples
* Clarify lifecycle-dependent capture behavior and document the example build workflow
* Add support for iPhone 18 Pro and iPhone 18 Pro Max (StixHub, #17)
* Inset the new Dynamic Island logo area by 1 pt after simulator mask verification
* Inset older Dynamic Island presets by 1 pt to remove faint edge leakage; add
  independently measured mask fixtures and pixel regressions for every supported model
* Adapt logo constraints and Dynamic Island top padding to iOS Display Zoom (StixHub, #18)
* Preserve app state and navigation when the identifier resolves or orientation changes
* Enforce logo bounds and clipping; make the overlay decorative and noninteractive
* Keep decorative logos out of keyboard focus and activation
* Recover from transient platform channel failures with bounded retries
* Add the missing iPhone X identifier iPhone10,3
* Reduce iPhone 12/12 Pro/12 Pro Max and 12 mini logo height after notch mask verification
* Update the Android example build tools and add minimum/current SDK build checks
* Disable unnecessary Jetifier transforms and increase the Android example Gradle heap
* Fix a signedness warning treated as an error in the Windows example
* Restore empty macOS and Linux example scaffold files
* Update web example initialization and include the Cupertino icon font
* Explicitly leave iPhone Duo without a logo and document the compatibility limit
* Verify Swift Package Manager on Flutter 3.27.0 and current stable; document
  that the overall Flutter 3.24.0 minimum uses CocoaPods on stable

## 1.2.0

**BREAKING: minimum iOS deployment target raised to 13.0 and minimum Flutter SDK to 3.24.0**

* Add Swift Package Manager support for iOS (closes #15)
* Restructure iOS native files: moved from `ios/Classes/` to `ios/hidden_logo/Sources/hidden_logo/`
* CocoaPods users: run `cd ios && pod install` after upgrading to refresh native source paths
* Add web to the supported platforms (no-op stub, like other non-iOS platforms)
* Avoid rebuilding the wrapped subtree on lifecycle changes unless the logo visibility actually changes
* Retry the device identifier lookup if the platform channel fails at early startup instead of caching the failure

## 1.1.0

* Add support for iPhone 17e
* Fix initial foreground state detection on app startup
* Fix race condition in device info caching
* Improve switch exhaustiveness in parser for safer new device additions
* Improve test determinism and reliability

## 1.0.0

**BREAKING: Converted from package to plugin** (no migration needed)

Removed `device_info_plus` dependency - plugin now uses native platform channels

* Added native iOS implementation with simulators support 
* Refactored internal parsing logic
* Lowered minimum Dart SDK to 3.0.0 from 3.7.0
* Updated tests to match new API

## 0.2.0

* Updated dependencies
* Add support for iPhone 17 series: iPhone 17, iPhone Air, iPhone 17 Pro, iPhone 17 Pro Max
* Optimize layout logic
* Update README typos
* Add more documentation
* Add more tests

## 0.1.2

* Updated README

## 0.1.1

* Added iPhone 16e support
* Updated dependencies

## 0.1.0

**BREAKING!**

* Rename parameter `isShown` → `isVisible`
* Rename parameter `showType` → `visibilityMode`
* Rename enum `LogoShowType` → `LogoVisibilityMode`

 ---

* Add parser and wrapper tests
* Update device_info_plus dependency version
* Fix minor parsing issue
* Refactor internals 
* Update README

## 0.0.8

* Adjust Dynamic Island logo constraints

## 0.0.7+1

* Fix analysis issues

## 0.0.7

* Fix parsing issues
* Migrate gradle in example

## 0.0.6

* Update README
* Fix black screen in case device_info_plus plugin fails
* Update analysis rules and add documentation

## 0.0.5

* Add support for new iPhones: 16, 16 Plus, 16 Pro, 16 Pro Max
* Refactor internals
* Update README
* Update dependencies
* Add older Flutter versions support
* Add device orientation check

## 0.0.4

* Update dependencies

## 0.0.3

* Fix README and add topics

## 0.0.2

* Fix analysis issues

## 0.0.1

* Initial release
