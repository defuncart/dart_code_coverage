import 'dart:io';

import 'package:args/args.dart';

import 'utils/reg_exp_utils.dart';

const _lcovPath = 'coverage/lcov.info';
const _emptyString = '';

void main(List<String> arguments) async {
  File file;
  RegExp regExp;

  // setup parser
  final parser = ArgParser()
    ..addSeparator('Removes files with given patterns from lcov.info.')
    ..addOption('file',
        abbr: 'f', help: 'The lcov.info file to edit. Defaults to coverage/lcov.info.', valueHelp: 'FILE')
    ..addMultiOption('remove',
        abbr: 'r', splitCommas: true, help: 'A regexp pattern of paths to remove.', valueHelp: 'PATTERN')
    ..addFlag('help', abbr: 'h', negatable: false, defaultsTo: false, help: 'Displays help.');
  final args = parser.parse(arguments);

  // process arguments
  if (args['help']) {
    exit(0);
  } else {
    final lcovFilepath = args['file'] ?? _lcovPath;
    file = File(lcovFilepath);
    if (!file.existsSync()) {
      print('Error! No lcov file found at $lcovFilepath');
      exit(0);
    }

    if ((args['remove'] as List<String>).isNotEmpty) {
      if (args['remove'].contains(_emptyString)) {
        print('Error! No spaces should be in pattern list: ${args['remove']}');
        exit(0);
      }
      regExp = RegExpUtils.combinePatterns(args['remove']);
    } else {
      print('Error! No regexp given. Nothing to remove.');
      exit(0);
    }
  }

  // edit file
  await _editLcov(file, regExp);

  print('Edited ${file.path}.');
}

Future<void> _editLcov(File file, RegExp regExpFilesRemove) async {
  // determine file contents
  final contents = await file.readAsLines();

  // split report entries into a list of lists
  final entries = <List<String>>[];
  while (contents.isNotEmpty) {
    final index = contents.indexWhere((element) => element.contains('end_of_record'));
    if (index != null) {
      final entry = contents.sublist(0, index + 1);
      contents.removeRange(0, index + 1);
      entries.add(entry);
    }
  }

  // determine entries to remove
  final entriesToRemove = <List<String>>[];
  for (final entry in entries) {
    if (regExpFilesRemove.hasMatch(entry.first)) {
      entriesToRemove.add(entry);
    }
  }

  if (entriesToRemove.isEmpty) {
    print('Error! No entries found to remove.');
    exit(0);
  }

  // remove entries
  for (final entry in entriesToRemove) {
    entries.remove(entry);
  }

  // determine new content and write to disk
  final newContents =
      entries.reduce((value, element) => [...value, ...element]).reduce((value, element) => value + '\n' + element);
  file.writeAsStringSync(newContents);
}
