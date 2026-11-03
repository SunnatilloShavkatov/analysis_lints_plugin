// ignore_for_file: non_constant_identifier_names — test_reflective_loader requires the `test_` prefix

import 'package:analysis_lints_plugin/src/rules/avoid_mutable_bloc_fields.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../bloc_stub.dart';
import '../flutter_stub.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidMutableBlocFieldsTest);
  });
}

@reflectiveTest
class AvoidMutableBlocFieldsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    addFlutterStub(this);
    addBlocStub(this);
    rule = AvoidMutableBlocFields();
    super.setUp();
  }

  Future<void> test_mutableFieldInBloc() async {
    const code = '''
import 'package:bloc/bloc.dart';

final class CounterBloc extends Bloc<int, int> {
  CounterBloc() : super(0);

  int _page = 1, _size = 20;
  late String _query;
}
''';
    await assertDiagnostics(code, [
      lint(code.indexOf('_page'), 5),
      lint(code.indexOf('_size'), 5),
      lint(code.indexOf('_query'), 6),
    ]);
  }

  Future<void> test_mutableFieldInCubit() async {
    const code = '''
import 'package:bloc/bloc.dart';

final class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  int _page = 1;
}
''';
    await assertDiagnostics(code, [lint(code.indexOf('_page'), 5)]);
  }

  Future<void> test_finalAndStaticFields() async {
    await assertNoDiagnostics(r'''
import 'package:bloc/bloc.dart';

final class CounterBloc extends Bloc<int, int> {
  CounterBloc(this._step) : super(0);

  static int instances = 0;
  final int _step;
  late final String _query = '$_step';
}
''');
  }

  Future<void> test_notABloc() async {
    await assertNoDiagnostics('''
class Counter {
  int value = 0;
}
''');
  }
}
