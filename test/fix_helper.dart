import 'package:analysis_server_plugin/edit/change_builder/change_builder.dart';
import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:test/test.dart';

typedef FixGenerator = CorrectionProducer Function({required CorrectionProducerContext context});

/// Fix assertions for an [AnalysisRuleTest], run after `assertDiagnostics`.
///
/// Like `dart fix --apply`, [fix] runs for every lint in the last resolved
/// file and all its edits are applied together.
extension FixAssertions on AnalysisRuleTest {
  /// Asserts that [fix] turns the last resolved code into [expected].
  Future<void> assertFix(FixGenerator fix, String expected) async {
    expect(await _applyFix(fix), expected);
  }

  /// Asserts that [fix] doesn't change the last resolved code.
  Future<void> assertNoFix(FixGenerator fix) async {
    expect(await _applyFix(fix), result.content);
  }

  Future<String> _applyFix(FixGenerator fix) async {
    final library = await result.session.getResolvedLibrary(result.path) as ResolvedLibraryResult;
    final builder = ChangeBuilder(session: result.session);
    for (final diagnostic in result.diagnostics.where((d) => d.diagnosticCode is LintCode)) {
      final context = CorrectionProducerContext.createResolved(
        libraryResult: library,
        unitResult: result,
        diagnostic: diagnostic,
        selectionOffset: diagnostic.offset,
        selectionLength: diagnostic.length,
      );
      await fix(context: context).compute(builder);
    }

    // Edits use offsets in the original code, so apply them from the end.
    final edits = [for (final fileEdit in builder.sourceChange.edits) ...fileEdit.edits]
      ..sort((a, b) => b.offset.compareTo(a.offset));
    var code = result.content;
    for (final edit in edits) {
      code = code.replaceRange(edit.offset, edit.offset + edit.length, edit.replacement);
    }
    return code;
  }
}
