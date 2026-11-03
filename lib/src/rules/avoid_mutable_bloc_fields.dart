import 'package:analysis_lints_plugin/src/utils/package.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Reports a non-final instance field in a `Bloc` or `Cubit`.
///
/// UI data belongs in the page state (or its mixin) and comes from the
/// emitted states; the bloc keeps only its final dependencies.
///
/// BAD:
/// ```dart
/// final class GamesBloc extends Bloc<GamesEvent, GamesState> {
///   int _page = 1;
/// }
/// ```
class AvoidMutableBlocFields extends AnalysisRule {
  new() : super(name: 'avoid_mutable_bloc_fields', description: 'Avoid non-final instance fields in a Bloc or Cubit.');

  static const LintCode code = LintCode(
    'avoid_mutable_bloc_fields',
    "Don't keep mutable state in a Bloc or Cubit: '{0}' is not final.",
    correctionMessage: 'Try moving the field to the page state or its mixin and passing it in the event.',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addFieldDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  new(this.rule);

  final AnalysisRule rule;

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (node.isStatic || node.fields.isFinal || node.fields.isConst) {
      return;
    }

    final enclosingClass = node.thisOrAncestorOfType<ClassDeclaration>()?.declaredFragment?.element;
    if (!isSubtypeOf(enclosingClass, 'BlocBase', 'bloc')) {
      return;
    }

    for (final variable in node.fields.variables) {
      rule.reportAtToken(variable.name, arguments: [variable.name.lexeme]);
    }
  }
}
