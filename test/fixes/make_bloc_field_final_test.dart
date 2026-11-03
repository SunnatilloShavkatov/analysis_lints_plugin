// ignore_for_file: non_constant_identifier_names — test_reflective_loader requires the `test_` prefix

import 'package:analysis_lints_plugin/src/fixes/make_bloc_field_final.dart';
import 'package:analysis_lints_plugin/src/rules/avoid_mutable_bloc_fields.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../bloc_stub.dart';
import '../fix_helper.dart';
import '../flutter_stub.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MakeBlocFieldFinalTest);
  });
}

@reflectiveTest
class MakeBlocFieldFinalTest extends AnalysisRuleTest {
  @override
  void setUp() {
    addFlutterStub(this);
    addBlocStub(this);
    rule = AvoidMutableBlocFields();
    super.setUp();
  }

  Future<void> test_typedField() async {
    const code = '''
import 'package:bloc/bloc.dart';

final class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  int _step = 1;

  int next(int value) => value + _step;
}
''';
    await assertDiagnostics(code, [lint(code.indexOf('_step'), 5)]);
    await assertFix(MakeBlocFieldFinal.new, '''
import 'package:bloc/bloc.dart';

final class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  final int _step = 1;

  int next(int value) => value + _step;
}
''');
  }

  Future<void> test_varAndLateFields() async {
    const code = r'''
import 'package:bloc/bloc.dart';

final class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  var _step = 1;
  late String _label = '$_step';
}
''';
    await assertDiagnostics(code, [lint(code.indexOf('_step'), 5), lint(code.indexOf('_label'), 6)]);
    await assertFix(MakeBlocFieldFinal.new, r'''
import 'package:bloc/bloc.dart';

final class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  final _step = 1;
  late final String _label = '$_step';
}
''');
  }

  Future<void> test_reassigned_noFix() async {
    const code = '''
import 'package:bloc/bloc.dart';

final class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  int _clicks = 0;
  int _total = 0;

  void click() {
    _clicks++;
    this._total += 1;
  }
}
''';
    await assertDiagnostics(code, [lint(code.indexOf('_clicks'), 7), lint(code.indexOf('_total'), 6)]);
    await assertNoFix(MakeBlocFieldFinal.new);
  }

  Future<void> test_publicOrUninitialized_noFix() async {
    const code = '''
import 'package:bloc/bloc.dart';

final class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  int step = 1;
  int? _last;
}
''';
    await assertDiagnostics(code, [lint(code.indexOf('step'), 4), lint(code.indexOf('_last'), 5)]);
    await assertNoFix(MakeBlocFieldFinal.new);
  }
}
