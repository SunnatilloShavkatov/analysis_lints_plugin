// ignore_for_file: non_constant_identifier_names — test_reflective_loader requires the `test_` prefix

import 'package:analysis_lints_plugin/src/fixes/replace_for_with_map.dart';
import 'package:analysis_lints_plugin/src/rules/avoid_for_in_flex_children.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../fix_helper.dart';
import '../flutter_stub.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ReplaceForWithMapTest);
  });
}

@reflectiveTest
class ReplaceForWithMapTest extends AnalysisRuleTest {
  @override
  void setUp() {
    addFlutterStub(this);
    rule = AvoidForInFlexChildren();
    super.setUp();
  }

  Future<void> test_forIn() async {
    const code = '''
import 'package:flutter/widgets.dart';

Widget f(List<String> xs) => Column(children: [Text('a'), for (final x in xs) Text(x)]);
''';
    await assertDiagnostics(code, [lint(code.indexOf('for'), 3)]);
    await assertFix(ReplaceForWithMap.new, '''
import 'package:flutter/widgets.dart';

Widget f(List<String> xs) => Column(children: [Text('a'), ...xs.map((x) => Text(x))]);
''');
  }

  Future<void> test_typedVariableAndLowPrecedenceIterable() async {
    const code = '''
import 'package:flutter/widgets.dart';

Widget f(List<String>? a, List<String> b) => Row(children: [for (final String x in a ?? b) Text(x)]);
''';
    await assertDiagnostics(code, [lint(code.indexOf('for'), 3)]);
    await assertFix(ReplaceForWithMap.new, '''
import 'package:flutter/widgets.dart';

Widget f(List<String>? a, List<String> b) => Row(children: [...(a ?? b).map((String x) => Text(x))]);
''');
  }

  Future<void> test_insideIf() async {
    const code = '''
import 'package:flutter/widgets.dart';

Widget f(bool c, List<String> xs) => Column(children: [if (c) for (final x in xs) Text(x)]);
''';
    await assertDiagnostics(code, [lint(code.indexOf('for'), 3)]);
    await assertFix(ReplaceForWithMap.new, '''
import 'package:flutter/widgets.dart';

Widget f(bool c, List<String> xs) => Column(children: [if (c) ...xs.map((x) => Text(x))]);
''');
  }

  Future<void> test_bodyIsCollectionElement_noFix() async {
    const code = '''
import 'package:flutter/widgets.dart';

Widget f(List<String> xs) => Column(children: [for (final x in xs) if (x.isNotEmpty) Text(x)]);
''';
    await assertDiagnostics(code, [lint(code.indexOf('for'), 3)]);
    await assertNoFix(ReplaceForWithMap.new);
  }

  Future<void> test_cStyleFor_noFix() async {
    const code = '''
import 'package:flutter/widgets.dart';

Widget f(List<String> xs) => Column(children: [for (var i = 0; i < xs.length; i++) Text(xs[i])]);
''';
    await assertDiagnostics(code, [lint(code.indexOf('for'), 3)]);
    await assertNoFix(ReplaceForWithMap.new);
  }
}
