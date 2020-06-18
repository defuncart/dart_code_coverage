# dart_code_coverage

A package with helpers for generating and editing code coverage reports in dart.

Inspired by [remove_from_coverage](https://pub.dev/packages/remove_from_coverage) and [dart_coverage_helper](https://stackoverflow.com/questions/54602840/how-can-i-generate-test-coverage-of-untested-files-on-my-flutter-tests).

## Getting Started

### generate_dart_file

Generates a dart file of all project files which should be covered by unit tests.

| option | abbreviation | info                                                                      |
|--------|--------------|---------------------------------------------------------------------------|
| output | -o           | A path to save output file. Defaults to `test/coverage_report_test.dart`. |
| remove | -r           | A regexp pattern of paths to exclude. Optional.                           |
| help   | -h           | Displays help.                                                            |

```sh
flutter pub run dart_code_coverage:generate_dart_file -r ".*\.g\.dart","localizations.dart"
```

### edit_lcov

Removes files with given patterns from lcov.info

| option | abbreviation | info                                                          |
|--------|--------------|---------------------------------------------------------------|
| file   | -f           | The lcov.info file to edit. Defaults to `coverage/lcov.info`. |
| remove | -r           | A regexp pattern of paths to exclude. Must be given.          |
| help   | -h           | Displays help.                                                |

```sh
flutter pub run dart_code_coverage:edit_lcov -r ".*\.g\.dart","localizations.dart"
```

## Example

```sh
# generate dart file of all files to be covered by unit tests
flutter pub run dart_code_coverage:generate_dart_file -r ".*\.g\.dart","localizations.dart"

# generate lcov
flutter test --coverage

# edit lcov
flutter pub run dart_code_coverage:edit_lcov -r ".*\.g\.dart","localizations.dart"

# generate report
genhtml coverage/lcov.info -o coverage/html
```