import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_coverage/test_coverage.dart';

void main() {
  String stubPath = path.join(Directory.current.path, 'test', 'stub_package');
  Directory stubRoot = new Directory(stubPath);
  group('findTestFiles', () {
    test('finds only test files', () {
      final result = findTestFiles(stubRoot);
      expect(result, hasLength(2));
      final filenames =
          result.map((f) => f.path.split(path.separator).last).toList();
      expect(filenames, contains('a_test.dart'));
      expect(filenames, contains('b_test.dart'));
      expect(filenames, isNot(contains('c.dart')));
    });
  });

  group('generateMainScript', () {
    final file = new File(path.join(stubPath, 'test', '.test_coverage.dart'));

    setUp(() {
      if (file.existsSync()) {
        file.deleteSync();
      }
      expect(file.existsSync(), isFalse);
    });

    test('creates main script', () {
      final files = findTestFiles(stubRoot);
      generateMainScript(stubRoot, files);
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content, contains("a_test.main();"));
      expect(content, contains("nested_b_test.main();"));
    });
  });

  group('$TestFileInfo', () {
    test('for file', () {
      final a = new File(path.join(stubPath, 'test', 'a_test.dart'));
      final info = new TestFileInfo.forFile(a);
      expect(info.alias, 'a_test');
      expect(info.import, "import 'a_test.dart' as a_test;");
      expect(info.testFile, a);
    });

    test('for nested file', () {
      final b = new File(path.join(stubPath, 'test', 'nested', 'b_test.dart'));
      final info = new TestFileInfo.forFile(b);
      expect(info.alias, 'nested_b_test');
      expect(info.import, "import 'nested/b_test.dart' as nested_b_test;");
      expect(info.testFile, b);
    });
  });
}
