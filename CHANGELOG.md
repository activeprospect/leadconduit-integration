# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [0.5.0] - 2019-02-28
### Added
- added `stripMetadata()` to strip non-lead, non-appended data from `vars`

## [0.4.1] - 2016-11-08
### Fixed
- fixed `calculateTimeout()` to return minimum of 1 (not 0)

## [0.4.0] - 2016-10-31
### Added
- Added utility function `calculateTimeout()`

## [0.3.1] - 2016-08-11
### Removed
- Moved `cake(task)` to its own module (leadconduit-cakefile) after all, so `coffee-script` et al don't have to be full dependencies

## [0.3.0] - 2016-08-11
### Added
- Add `cake(task)` export to handle build tools (including PDF generation and linting) for integrations

## [0.1.0] - 2016-01-20
### Added
- Initial creation
