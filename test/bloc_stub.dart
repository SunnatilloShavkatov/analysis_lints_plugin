import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';

/// Adds minimal `package:bloc/bloc.dart` and `package:flutter_bloc/flutter_bloc.dart`
/// stubs to [test]. Needs `addFlutterStub` as well.
///
/// Must be called in `setUp`, before `super.setUp()`.
void addBlocStub(AnalysisRuleTest test) {
  test.newPackage('bloc').addFile('lib/bloc.dart', '''
typedef EventTransformer<E> = Stream<E> Function(Stream<E> events, Stream<E> Function(E) mapper);

abstract class BlocBase<S> {
  BlocBase(S initial);
}

abstract class Bloc<E, S> extends BlocBase<S> {
  Bloc(super.initial);

  void on<T extends E>(void Function(T event) handler, {EventTransformer<T>? transformer}) {}
}

abstract class Cubit<S> extends BlocBase<S> {
  Cubit(super.initial);
}
''');
  test.newPackage('flutter_bloc').addFile('lib/flutter_bloc.dart', '''
import 'package:flutter/widgets.dart';

export 'package:bloc/bloc.dart';

class BlocBuilder<B, S> extends Widget {
  const BlocBuilder({required Widget Function(BuildContext, S) builder, bool Function(S, S)? buildWhen});
}

class BlocConsumer<B, S> extends Widget {
  const BlocConsumer({
    required Widget Function(BuildContext, S) builder,
    required void Function(BuildContext, S) listener,
    bool Function(S, S)? buildWhen,
  });
}

class BlocListener<B, S> extends Widget {
  const BlocListener({required void Function(BuildContext, S) listener});
}
''');
}
