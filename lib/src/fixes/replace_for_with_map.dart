import 'package:analysis_server_plugin/edit/change_builder/change_builder.dart';
import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analysis_server_plugin/edit/fix/fix.dart';
import 'package:analysis_server_plugin/edit/range_factory.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/precedence.dart';

/// Fix for `avoid_for_in_flex_children`: replaces
/// `for (final item in items) ItemTile(item)` with
/// `...items.map((item) => ItemTile(item))`.
///
/// Applies only to a plain `for`-`in` with a declared loop variable and a
/// single expression as its body; `await for`, C-style `for`, patterns and
/// nested collection elements are left for a manual fix.
class ReplaceForWithMap extends ResolvedCorrectionProducer {
  new({required super.context});

  static const FixKind _fixKind = FixKind(
    'analysis_lints_plugin.fix.replaceForWithMap',
    DartFixKindPriority.standard,
    "Replace the 'for' element with '...map()'",
  );

  static const FixKind _multiFixKind = FixKind(
    'analysis_lints_plugin.fix.replaceForWithMap.multi',
    DartFixKindPriority.inFile,
    "Replace the 'for' elements with '...map()' everywhere in the file",
  );

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.automatically;

  @override
  FixKind get fixKind => _fixKind;

  @override
  FixKind get multiFixKind => _multiFixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final element = node;
    if (element is! ForElement || element.awaitKeyword != null) {
      return;
    }

    final parts = element.forLoopParts;
    final body = element.body;
    if (parts is! ForEachPartsWithDeclaration || body is! Expression) {
      return;
    }

    final variable = parts.loopVariable;
    final type = variable.type;
    final parameter = type == null ? variable.name.lexeme : '${utils.getNodeText(type)} ${variable.name.lexeme}';

    final iterable = parts.iterable;
    final iterableText = utils.getNodeText(iterable);
    final receiver = iterable.precedence < Precedence.postfix ? '($iterableText)' : iterableText;

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        range.node(element),
        '...$receiver.map(($parameter) => ${utils.getNodeText(body)})',
      );
    });
  }
}
