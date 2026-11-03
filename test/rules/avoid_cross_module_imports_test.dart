// ignore_for_file: non_constant_identifier_names — test_reflective_loader requires the `test_` prefix

import 'package:analysis_lints_plugin/src/rules/avoid_cross_module_imports.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/package_config_file_builder.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidCrossModuleImportsTest);
  });
}

@reflectiveTest
class AvoidCrossModuleImportsTest extends AnalysisRuleTest {
  @override
  String get testPackageRootPath => '$workspaceRootPath/modules/home';

  String get _vocabularyPath => '$workspaceRootPath/modules/vocabulary';

  String get _corePath => '$workspaceRootPath/packages/core';

  @override
  void setUp() {
    rule = AvoidCrossModuleImports();
    super.setUp();
    newFile('$_vocabularyPath/lib/vocabulary.dart', 'class Word {}');
    newFile('$_corePath/lib/core.dart', 'class Entity {}');
    newFile('$testPackageRootPath/lib/src/home.dart', 'class Home {}');
  }

  // Relative URIs from `lib/` resolve against the `package:` URI and can't leave the package, so a
  // real cross-module import is always a `package:` one; register the other packages for it.
  @override
  void writeTestPackageConfig2({PackageConfigFileBuilder? config, String? languageVersion}) {
    final builder = (config ?? PackageConfigFileBuilder()).copy()
      ..add(name: 'vocabulary', rootFolder: getFolder(convertPath(_vocabularyPath)))
      ..add(name: 'core', rootFolder: getFolder(convertPath(_corePath)));
    super.writeTestPackageConfig2(config: builder, languageVersion: languageVersion);
  }

  Future<void> test_importAnotherModule() async {
    const code = '''
import 'package:vocabulary/vocabulary.dart';

Word? word;
''';
    await assertDiagnostics(code, [lint(code.indexOf("'"), 36)]);
  }

  Future<void> test_exportAnotherModule() async {
    const code = '''
export 'package:vocabulary/vocabulary.dart';
''';
    await assertDiagnostics(code, [lint(code.indexOf("'"), 36)]);
  }

  Future<void> test_ownModule() async {
    await assertNoDiagnostics('''
import 'src/home.dart';

Home? home;
''');
  }

  Future<void> test_sharedPackage() async {
    await assertNoDiagnostics('''
import 'package:core/core.dart';

Entity? entity;
''');
  }
}
