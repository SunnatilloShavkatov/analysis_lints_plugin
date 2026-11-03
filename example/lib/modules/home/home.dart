// Rule: avoid_cross_module_imports.

// BAD: module `home` imports module `profile`.
// LINT: avoid_cross_module_imports
import 'package:analysis_lints_plugin_example/modules/profile/profile.dart';

// GOOD: imports from outside `modules/` are allowed.
import 'package:analysis_lints_plugin_example/rules/counter_bloc.dart';

String greeting(Profile profile, CounterBloc bloc) => 'Hello, ${profile.name}: ${bloc.state}';
