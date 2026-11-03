import 'package:analysis_lints_plugin_example/rules/counter_bloc.dart';
import 'package:analysis_lints_plugin_example/rules/counter_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: BlocProvider(create: (_) => CounterBloc(), child: const CounterPage()),
  );
}
