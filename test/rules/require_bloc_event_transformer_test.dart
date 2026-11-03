// ignore_for_file: non_constant_identifier_names — test_reflective_loader requires the `test_` prefix

import 'package:analysis_lints_plugin/src/rules/require_bloc_event_transformer.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../bloc_stub.dart';
import '../flutter_stub.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RequireBlocEventTransformerTest);
  });
}

@reflectiveTest
class RequireBlocEventTransformerTest extends AnalysisRuleTest {
  @override
  void setUp() {
    addFlutterStub(this);
    addBlocStub(this);
    rule = RequireBlocEventTransformer();
    super.setUp();
  }

  Future<void> test_withoutTransformer() async {
    const code = '''
import 'package:bloc/bloc.dart';

final class CounterBloc extends Bloc<int, int> {
  CounterBloc() : super(0) {
    on<int>(_incrementHandler);
  }

  void _incrementHandler(int event) {}
}
''';
    await assertDiagnostics(code, [lint(code.indexOf('on<int>'), 2)]);
  }

  Future<void> test_withTransformer() async {
    await assertNoDiagnostics('''
import 'package:bloc/bloc.dart';

final class CounterBloc extends Bloc<int, int> {
  CounterBloc() : super(0) {
    on<int>(_incrementHandler, transformer: (events, mapper) => events);
  }

  void _incrementHandler(int event) {}
}
''');
  }

  Future<void> test_otherOnMethod() async {
    await assertNoDiagnostics('''
class Emitter {
  void on<T>(void Function(T) handler) {}
}

void f(Emitter emitter) => emitter.on<int>((_) {});
''');
  }
}
