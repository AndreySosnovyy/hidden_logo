## 1.0.0

**BREAKING: Converted from package to plugin** (no migration needed)

Removed `device_info_plus` dependency - plugin now uses native platform channels

* Added native iOS implementation with simulators support 
* Refactored internal parsing logic
* Lowered minimum Dart SDK to 3.0.0 from 3.7.0
* Updated tests to match new API

---

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