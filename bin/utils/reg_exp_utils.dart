/// A class of utils for RegExp
abstract class RegExpUtils {
  /// Combines a list of string patterns into a RegExp
  static RegExp combinePatterns(List<String> patterns) {
    if (patterns.isNotEmpty) {
      var combinedPattern = '';
      for (var i = 0; i < patterns.length; i++) {
        if (patterns[i].isEmpty) {
          continue;
        }

        if (i != 0) {
          combinedPattern += '|';
        }
        combinedPattern += patterns[i];
      }

      return RegExp(combinedPattern);
    }

    return RegExp('');
  }
}
