import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

/// Reports an import or export of a library from another module of the same
/// monorepo, where modules are the packages in a `modules/` folder.
///
/// The check uses the resolved file paths, so it catches `package:` and
/// relative URIs alike, and ignores dependencies outside the monorepo.
///
/// BAD (in `modules/home/lib/...`):
/// ```dart
/// import 'package:vocabulary/vocabulary.dart';
/// ```
///
/// GOOD: go through a shared package (`ModuleInteractor`, `PageFactory`,
/// `WidgetFactory`, a shared entity).
class AvoidCrossModuleImports extends AnalysisRule {
  new()
    : super(name: 'avoid_cross_module_imports', description: "Avoid imports between packages in a 'modules/' folder.");

  static const LintCode code = LintCode(
    'avoid_cross_module_imports',
    "Module '{0}' must not import module '{1}'.",
    correctionMessage:
        'Try depending on a shared package instead: a ModuleInteractor (usecase), PageFactory (screen), '
        'WidgetFactory (widget) or a shared entity, registered through DI.',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final module = _Module.of((context.currentUnit ?? context.definingUnit).file.path);
    if (module == null) {
      return;
    }

    final visitor = _Visitor(this, module);
    registry
      ..addImportDirective(this, visitor)
      ..addExportDirective(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  new(this.rule, this.module);

  final AnalysisRule rule;
  final _Module module;

  @override
  void visitImportDirective(ImportDirective node) => _check(node, node.libraryImport?.importedLibrary);

  @override
  void visitExportDirective(ExportDirective node) => _check(node, node.libraryExport?.exportedLibrary);

  void _check(UriBasedDirective node, LibraryElement? library) {
    if (library == null) {
      return;
    }

    final other = _Module.of(library.firstFragment.source.fullName);
    if (other == null || other.root != module.root || other.name == module.name) {
      return;
    }

    rule.reportAtNode(node.uri, arguments: [module.name, other.name]);
  }
}

/// A package at `<root>/modules/<name>/`.
class _Module {
  const new(this.root, this.name);

  final String root;
  final String name;

  /// Greedy `(.*)` picks the innermost `modules/` folder of the path.
  static final _pattern = RegExp(r'^(.*)[/\\]modules[/\\]([^/\\]+)[/\\]');

  static _Module? of(String path) {
    final match = _pattern.firstMatch(path);
    return match == null ? null : _Module(match.group(1)!, match.group(2)!);
  }
}
