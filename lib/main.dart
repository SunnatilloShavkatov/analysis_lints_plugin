import 'package:analysis_lints_plugin/src/fixes/make_bloc_field_final.dart';
import 'package:analysis_lints_plugin/src/fixes/replace_for_with_map.dart';
import 'package:analysis_lints_plugin/src/rules/avoid_cross_module_imports.dart';
import 'package:analysis_lints_plugin/src/rules/avoid_for_in_flex_children.dart';
import 'package:analysis_lints_plugin/src/rules/avoid_mutable_bloc_fields.dart';
import 'package:analysis_lints_plugin/src/rules/avoid_widget_returning_functions.dart';
import 'package:analysis_lints_plugin/src/rules/require_bloc_builder_build_when.dart';
import 'package:analysis_lints_plugin/src/rules/require_bloc_event_transformer.dart';
import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

/// Entry point the Dart Analysis Server looks up when loading this plugin.
final plugin = AnalysisLintsPlugin();

class AnalysisLintsPlugin extends Plugin {
  @override
  String get name => 'analysis_lints_plugin';

  @override
  void register(PluginRegistry registry) {
    registry
      ..registerLintRule(AvoidCrossModuleImports())
      ..registerLintRule(AvoidForInFlexChildren())
      ..registerLintRule(AvoidMutableBlocFields())
      ..registerLintRule(AvoidWidgetReturningFunctions())
      ..registerLintRule(RequireBlocBuilderBuildWhen())
      ..registerLintRule(RequireBlocEventTransformer())
      ..registerFixForRule(AvoidForInFlexChildren.code, ReplaceForWithMap.new)
      ..registerFixForRule(AvoidMutableBlocFields.code, MakeBlocFieldFinal.new);
  }
}
