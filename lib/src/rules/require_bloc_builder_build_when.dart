import 'package:analysis_lints_plugin/src/utils/package.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Reports a `BlocBuilder` or `BlocConsumer` without `buildWhen:`.
///
/// Without it the widget rebuilds on every state of the bloc, including the
/// states of unrelated operations.
///
/// BAD:
/// ```dart
/// BlocBuilder<GamesBloc, GamesState>(builder: (context, state) => ...);
/// ```
///
/// GOOD:
/// ```dart
/// BlocBuilder<GamesBloc, GamesState>(
///   buildWhen: (prev, curr) => curr is GetGamesState,
///   builder: (context, state) => ...,
/// );
/// ```
class RequireBlocBuilderBuildWhen extends AnalysisRule {
  new()
    : super(
        name: 'require_bloc_builder_build_when',
        description: "Require 'buildWhen:' on every BlocBuilder and BlocConsumer.",
      );

  static const LintCode code = LintCode(
    'require_bloc_builder_build_when',
    "'{0}' needs a 'buildWhen:'.",
    correctionMessage: "Try adding 'buildWhen: (prev, curr) => curr is <Operation>State'.",
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addInstanceCreationExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  new(this.rule);

  final AnalysisRule rule;

  static const _builders = {'BlocBuilder', 'BlocConsumer'};

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final element = node.constructorName.type.element;
    if (!_builders.contains(element?.name) || !isFromPackage(element, 'flutter_bloc')) {
      return;
    }

    final hasBuildWhen = node.argumentList.arguments.whereType<NamedArgument>().any(
      (argument) => argument.name.lexeme == 'buildWhen',
    );
    if (hasBuildWhen) {
      return;
    }

    rule.reportAtNode(node.constructorName, arguments: [element!.name!]);
  }
}
