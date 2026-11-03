import 'package:analysis_lints_plugin/src/utils/flutter.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Reports functions, methods and getters in `lib/` that return a Flutter
/// widget or a list of widgets and construct a widget in their body.
///
/// `build` and `@override` members are allowed: they implement a framework or
/// factory contract (`State.build`, `PageFactory.create`). Members that only
/// look a widget up or pass one through (`InheritedWidget.of`, `get child`)
/// don't build UI and are allowed too.
///
/// BAD:
/// ```dart
/// Widget _buildHeader() => Text(title);
/// List<Widget> _buildItems() => [for (final x in xs) Text(x)];
/// ```
///
/// GOOD:
/// ```dart
/// class HeaderWidget extends StatelessWidget {
///   const HeaderWidget({required this.title, super.key});
///   ...
/// }
/// ```
class AvoidWidgetReturningFunctions extends AnalysisRule {
  new()
    : super(
        name: 'avoid_widget_returning_functions',
        description: 'Avoid functions, methods and getters that return widgets.',
      );

  static const LintCode code = LintCode(
    'avoid_widget_returning_functions',
    "Don't return widgets from a function, method or getter: '{0}' builds UI outside a widget class.",
    correctionMessage:
        "Try extracting a 'StatelessWidget' class into 'widgets/' and passing its data through the constructor.",
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    if (!context.isInLibDir) {
      return;
    }

    final visitor = _Visitor(this);
    registry
      ..addFunctionDeclaration(this, visitor)
      ..addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  new(this.rule);

  final AnalysisRule rule;

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (node.externalKeyword != null) {
      return;
    }
    if (!isWidgetOrWidgetsType(node.declaredFragment?.element.returnType)) {
      return;
    }
    if (!_constructsWidget(node.functionExpression.body)) {
      return;
    }

    rule.reportAtToken(node.name, arguments: [node.name.lexeme]);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.body is EmptyFunctionBody || node.externalKeyword != null || node.isSetter) {
      return;
    }
    if (node.name.lexeme == 'build') {
      return;
    }

    final element = node.declaredFragment?.element;
    if (element == null || element.metadata.hasOverride) {
      return;
    }
    if (!isWidgetOrWidgetsType(element.returnType)) {
      return;
    }
    if (!_constructsWidget(node.body)) {
      return;
    }

    rule.reportAtToken(node.name, arguments: [node.name.lexeme]);
  }
}

/// Whether [body] constructs a Flutter widget anywhere, nested closures included.
bool _constructsWidget(FunctionBody body) {
  final finder = _WidgetCreationFinder();
  body.accept(finder);
  return finder.found;
}

class _WidgetCreationFinder extends RecursiveAstVisitor<void> {
  bool found = false;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (isWidgetOrWidgetsType(node.staticType)) {
      found = true;
      return;
    }
    super.visitInstanceCreationExpression(node);
  }
}
