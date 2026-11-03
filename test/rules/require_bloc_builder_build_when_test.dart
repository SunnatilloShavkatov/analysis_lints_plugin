// ignore_for_file: non_constant_identifier_names — test_reflective_loader requires the `test_` prefix

import 'package:analysis_lints_plugin/src/rules/require_bloc_builder_build_when.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../bloc_stub.dart';
import '../flutter_stub.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RequireBlocBuilderBuildWhenTest);
  });
}

@reflectiveTest
class RequireBlocBuilderBuildWhenTest extends AnalysisRuleTest {
  @override
  void setUp() {
    addFlutterStub(this);
    addBlocStub(this);
    rule = RequireBlocBuilderBuildWhen();
    super.setUp();
  }

  Future<void> test_blocBuilderWithoutBuildWhen() async {
    const code = r'''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget f() => BlocBuilder<Object, int>(builder: (context, state) => Text('$state'));
''';
    await assertDiagnostics(code, [lint(code.indexOf('BlocBuilder<'), 24)]);
  }

  Future<void> test_blocConsumerWithoutBuildWhen() async {
    const code = r'''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget f() => BlocConsumer<Object, int>(listener: (context, state) {}, builder: (context, state) => Text('$state'));
''';
    await assertDiagnostics(code, [lint(code.indexOf('BlocConsumer<'), 25)]);
  }

  Future<void> test_withBuildWhen() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget f() => BlocBuilder<Object, int>(
  buildWhen: (prev, curr) => curr.isEven,
  builder: (context, state) => Text('$state'),
);
''');
  }

  Future<void> test_blocListener() async {
    await assertNoDiagnostics('''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget f() => BlocListener<Object, int>(listener: (context, state) {});
''');
  }
}
