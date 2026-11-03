import 'package:analysis_server_plugin/edit/change_builder/change_builder.dart';
import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analysis_server_plugin/edit/fix/fix.dart';
import 'package:analysis_server_plugin/edit/range_factory.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

/// Fix for `avoid_mutable_bloc_fields`: adds `final` to a field that is never
/// reassigned.
///
/// Applies only when every variable of the declaration is private, has an
/// initializer and is never written in its library, so `final` can't break the
/// code. A field that is reassigned has to move out of the bloc by hand.
class MakeBlocFieldFinal extends ResolvedCorrectionProducer {
  new({required super.context});

  static const FixKind _fixKind = FixKind(
    'analysis_lints_plugin.fix.makeBlocFieldFinal',
    DartFixKindPriority.standard,
    "Make the field 'final'",
  );

  static const FixKind _multiFixKind = FixKind(
    'analysis_lints_plugin.fix.makeBlocFieldFinal.multi',
    DartFixKindPriority.inFile,
    "Make the unassigned bloc fields 'final' everywhere in the file",
  );

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.automatically;

  @override
  FixKind get fixKind => _fixKind;

  @override
  FixKind get multiFixKind => _multiFixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final list = node.parent;
    final declaration = list?.parent;
    if (list is! VariableDeclarationList || declaration is! FieldDeclaration) {
      return;
    }
    if (declaration.covariantKeyword != null ||
        declaration.abstractKeyword != null ||
        declaration.externalKeyword != null) {
      return;
    }

    final fields = <Element>{};
    for (final variable in list.variables) {
      final element = variable.declaredFragment?.element;
      if (element == null || element.isPublic || variable.initializer == null) {
        return;
      }
      fields.add(element);
    }

    final writes = _WriteFinder(fields);
    for (final unit in libraryResult.units) {
      unit.unit.accept(writes);
    }
    if (writes.found) {
      return;
    }

    final keyword = list.keyword;
    final type = list.type;
    await builder.addDartFileEdit(file, (builder) {
      if (keyword != null) {
        // `var` (`const` and `final` aren't reported).
        builder.addSimpleReplacement(range.token(keyword), 'final');
      } else if (type != null) {
        builder.addSimpleInsertion(type.offset, 'final ');
      }
    });
  }
}

/// Finds an assignment, `++` / `--` or `for`-`in` write to any of [fields].
class _WriteFinder extends RecursiveAstVisitor<void> {
  new(this.fields);

  final Set<Element> fields;

  bool found = false;

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    _check(node.writeElement);
    super.visitAssignmentExpression(node);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    _check(node.writeElement);
    super.visitPrefixExpression(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    _check(node.writeElement);
    super.visitPostfixExpression(node);
  }

  @override
  void visitForEachPartsWithIdentifier(ForEachPartsWithIdentifier node) {
    _check(node.identifier.element);
    super.visitForEachPartsWithIdentifier(node);
  }

  void _check(Element? element) {
    final written = element is PropertyAccessorElement ? element.variable : element;
    if (written != null && fields.contains(written.baseElement)) {
      found = true;
    }
  }
}
