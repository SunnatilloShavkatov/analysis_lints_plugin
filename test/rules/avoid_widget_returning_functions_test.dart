// ignore_for_file: non_constant_identifier_names — test_reflective_loader requires the `test_` prefix

import 'package:analysis_lints_plugin/src/rules/avoid_widget_returning_functions.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../flutter_stub.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidWidgetReturningFunctionsTest);
  });
}

@reflectiveTest
class AvoidWidgetReturningFunctionsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    addFlutterStub(this);
    rule = AvoidWidgetReturningFunctions();
    super.setUp();
  }

  Future<void> test_method() async {
    const code = '''
import 'package:flutter/widgets.dart';

class A {
  Widget _buildHeader() => const Text('a');
  Widget f() => _buildHeader();
}
''';
    await assertDiagnostics(code, [lint(code.indexOf('_buildHeader'), 12)]);
  }

  Future<void> test_nullableWidgetSubtype() async {
    const code = '''
import 'package:flutter/widgets.dart';

class A {
  Text? title(String? t) => t == null ? null : Text(t);
}
''';
    await assertDiagnostics(code, [lint(code.indexOf('title'), 5)]);
  }

  Future<void> test_listOfWidgets() async {
    const code = '''
import 'package:flutter/widgets.dart';

List<Widget> items(List<String> xs) => [for (final x in xs) Text(x)];
''';
    await assertDiagnostics(code, [lint(code.indexOf('items'), 5)]);
  }

  Future<void> test_getter() async {
    const code = '''
import 'package:flutter/widgets.dart';

extension on String {
  Widget get text => Text(this);
}
''';
    await assertDiagnostics(code, [lint(code.indexOf('text =>'), 4)]);
  }

  Future<void> test_localFunction() async {
    const code = '''
import 'package:flutter/widgets.dart';

class A extends StatelessWidget {
  const A();

  @override
  Widget build(BuildContext context) {
    item(String x) => Text(x);
    return item('a');
  }
}
''';
    await assertDiagnostics(code, [lint(code.indexOf('item(String'), 4)]);
  }

  Future<void> test_buildOverride() async {
    await assertNoDiagnostics('''
import 'package:flutter/widgets.dart';

class A extends StatelessWidget {
  const A();

  @override
  Widget build(BuildContext context) => const Text('a');
}
''');
  }

  Future<void> test_factoryOverride() async {
    await assertNoDiagnostics('''
import 'package:flutter/widgets.dart';

abstract interface class PageFactory {
  Widget create();
}

final class HomePageFactory implements PageFactory {
  @override
  Widget create() => const Text('home');
}
''');
  }

  Future<void> test_inheritedWidgetOf() async {
    await assertNoDiagnostics('''
import 'package:flutter/widgets.dart';

class Provider extends InheritedWidget {
  const Provider({required super.child});

  static Provider? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Provider>();

  @override
  bool updateShouldNotify(Provider oldWidget) => false;
}
''');
  }

  Future<void> test_passThrough() async {
    await assertNoDiagnostics('''
import 'package:flutter/widgets.dart';

class A {
  A(this._child);

  final Widget _child;

  Widget get child => _child;
}
''');
  }

  Future<void> test_nonWidget() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/widgets.dart';

List<String> names(List<Widget> widgets) => [for (final w in widgets) '$w'];
''');
  }

  Future<void> test_testDirectory() async {
    final path = convertPath('$testPackageRootPath/test/a_test.dart');
    newFile(path, '''
import 'package:flutter/widgets.dart';

Widget buildSubject() => const Text('a');
''');
    await assertNoDiagnosticsInFile(path);
  }
}
