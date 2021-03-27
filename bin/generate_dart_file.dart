import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

import 'utils/reg_exp_utils.dart';

const _outputPath = 'test/coverage_report_test.dart';

void main(List<String> arguments) async {
  late String filepath;
  late RegExp regExp;

  // setup parser
  final parser = ArgParser()
    ..addSeparator('Generates a dart file of all project files which should be covered by unit tests.')
    ..addOption('output',
        abbr: 'o', help: 'A path to save output file. Defaults to test/coverage_report_test.dart.', valueHelp: 'FILE')
    ..addMultiOption('remove',
        abbr: 'r', splitCommas: true, help: 'A regexp pattern of paths to exclude.', valueHelp: 'PATTERN')
    ..addFlag('help', abbr: 'h', negatable: false, defaultsTo: false, help: 'Displays help.');
  final args = parser.parse(arguments);

  // process arguments
  if (args['help']) {
    exit(0);
  } else {
    filepath = args['output'] ?? _outputPath;

    if ((args['remove'] as List<String>).isNotEmpty) {
      regExp = RegExpUtils.combinePatterns(args['remove']);
    }
  }

  // generate file
  await _createCoverageReportDartFile(filepath, regExp);
}

const _pubspecPath = 'pubspec.yaml';

Future<void> _createCoverageReportDartFile(String filepath, RegExp regExpFilesIgnore) async {
  // dtermine contents of pubspec
  var file = File(_pubspecPath);
  if (!file.existsSync()) {
    print('Error! Pubspec not found. Please run from project root. Exiting.');
    exit(0);
  }
  final contents = file.readAsStringSync();

  // determine project name
  final regExp = RegExp(r'(name: )(\w*)');
  final matches = regExp.allMatches(contents).first;
  final projectName = matches.groupCount >= 2 ? matches.group(2) : null;
  if (projectName == null) {
    print('Error! Cannot determine project name. Exiting.');
    exit(0);
  }

  // determine all paths for valid files
  final paths = await _listDir('lib', regExp: regExpFilesIgnore);

  // determine output content
  final sb = StringBuffer();
  sb.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  sb.writeln();
  sb.writeln('// **************************************************************************');
  sb.writeln('// All files which should be covered by tests');
  sb.writeln('// **************************************************************************');
  sb.writeln();
  sb.writeln('// ignore_for_file: unused_import');
  for (final path in paths) {
    sb.writeln('import \'package:$projectName/${path.replaceAll('lib/', '')}\';');
  }
  sb.writeln();
  sb.writeln('void main() {}');

  // write to disk
  file = File(filepath);
  if (!await file.exists()) {
    await file.create(recursive: true);
  }
  file.writeAsStringSync(sb.toString());

  print('Generated $filepath.');
}

/// Lists all files (recursively) in a given folder
///
/// [regExp] is an optional RegExp for files to ignore
Future<List<String>> _listDir(String folderPath, {RegExp? regExp}) async {
  final paths = <String>[];
  final directory = Directory(folderPath);
  if (await directory.exists()) {
    await for (FileSystemEntity entity in directory.list(recursive: true, followLinks: false)) {
      var type = await FileSystemEntity.type(entity.path);
      if (type == FileSystemEntityType.file) {
        if (!_isDartFile(entity)) {
          continue;
        }

        if (regExp != null) {
          if (regExp.hasMatch(entity.path)) {
            continue;
          }
        }

        paths.add(entity.path);
      }
    }
    return paths;
  }

  return paths;
}

/// Determines if a [FileSystemEntity] is a dart file
bool _isDartFile(FileSystemEntity entity) {
  const dartFileExtension = '.dart';
  return extension(entity.path).toLowerCase() == dartFileExtension;
}
