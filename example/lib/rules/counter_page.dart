import 'package:analysis_lints_plugin_example/rules/counter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Rules: require_bloc_builder_build_when, avoid_widget_returning_functions.

// GOOD: `buildWhen:` is set, the title is its own widget class.
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const CounterTitle(title: 'Counter')),
    body: Center(
      child: BlocBuilder<CounterBloc, int>(
        buildWhen: (prev, curr) => prev != curr,
        builder: (context, count) => Text('$count'),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => context.read<CounterBloc>().add(const IncrementEvent()),
      child: const Icon(Icons.add),
    ),
  );
}

class CounterTitle extends StatelessWidget {
  const CounterTitle({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Text(title);
}

// BAD: no `buildWhen:`, UI built in a method and a getter.
class BadCounterPage extends StatelessWidget {
  const BadCounterPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: _buildTitle()),
    body: Center(
      // LINT: require_bloc_builder_build_when
      child: BlocBuilder<CounterBloc, int>(builder: (context, count) => Text('$count')),
    ),
    floatingActionButton: _addButton,
  );

  // LINT: avoid_widget_returning_functions
  Widget _buildTitle() => const Text('Counter');

  // LINT: avoid_widget_returning_functions
  Widget get _addButton => const Icon(Icons.add);
}
