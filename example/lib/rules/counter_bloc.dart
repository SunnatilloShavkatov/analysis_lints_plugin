import 'package:bloc/bloc.dart';

// Rules: avoid_mutable_bloc_fields, require_bloc_event_transformer.

sealed class CounterEvent {
  const CounterEvent();
}

final class IncrementEvent extends CounterEvent {
  const IncrementEvent();
}

final class ResetEvent extends CounterEvent {
  const ResetEvent();
}

/// Processes events one at a time; stands in for `sequential()` from `bloc_concurrency`.
EventTransformer<E> sequential<E>() => (events, mapper) => events.asyncExpand(mapper);

// GOOD: only final fields, every `on<Event>()` has a transformer.
final class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<IncrementEvent>(_incrementHandler, transformer: sequential());
    on<ResetEvent>(_resetHandler, transformer: sequential());
  }

  void _incrementHandler(IncrementEvent event, Emitter<int> emit) => emit(state + 1);

  void _resetHandler(ResetEvent event, Emitter<int> emit) => emit(0);
}

// BAD: a mutable field and an `on<Event>()` without a transformer.
final class BadCounterBloc extends Bloc<CounterEvent, int> {
  BadCounterBloc() : super(0) {
    // LINT: require_bloc_event_transformer
    on<IncrementEvent>(_incrementHandler);
  }

  // LINT: avoid_mutable_bloc_fields
  int _clicks = 0;

  void _incrementHandler(IncrementEvent event, Emitter<int> emit) {
    _clicks++;
    emit(_clicks);
  }
}

// BAD: a mutable field in a Cubit.
final class BadCounterCubit extends Cubit<int> {
  BadCounterCubit() : super(0);

  // LINT: avoid_mutable_bloc_fields
  int step = 1;

  void increment() => emit(state + step);
}
