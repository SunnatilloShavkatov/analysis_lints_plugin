import 'package:analysis_lints_plugin/src/utils/package.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Reports `on<Event>(handler)` in a `Bloc` without an explicit `transformer:`.
///
/// BAD:
/// ```dart
/// on<GetGamesEvent>(_getGamesHandler);
/// ```
///
/// GOOD:
/// ```dart
/// on<GetGamesEvent>(_getGamesHandler, transformer: droppable());
/// ```
class RequireBlocEventTransformer extends AnalysisRule {
  new()
    : super(
        name: 'require_bloc_event_transformer',
        description: "Require an explicit 'transformer:' on every Bloc 'on<Event>()'.",
      );

  static const LintCode code = LintCode(
    'require_bloc_event_transformer',
    "Every 'on<Event>()' needs an explicit 'transformer:'.",
    correctionMessage: "Try adding 'transformer:' (for example 'droppable()', 'restartable()' or 'sequential()').",
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addMethodInvocation(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  new(this.rule);

  final AnalysisRule rule;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name != 'on') {
      return;
    }

    final element = node.methodName.element;
    if (element?.enclosingElement?.name != 'Bloc' || !isFromPackage(element, 'bloc')) {
      return;
    }

    final hasTransformer = node.argumentList.arguments.whereType<NamedArgument>().any(
      (argument) => argument.name.lexeme == 'transformer',
    );
    if (hasTransformer) {
      return;
    }

    rule.reportAtNode(node.methodName);
  }
}
