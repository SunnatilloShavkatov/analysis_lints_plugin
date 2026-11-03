import 'package:analysis_lints_plugin/src/utils/package.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';

/// Whether [node] constructs one of the Flutter classes named in [classNames].
///
/// Matches by class name and requires the class to come from the `flutter`
/// package, so same-named classes from other packages are ignored.
bool isFlutterWidget(InstanceCreationExpression node, Set<String> classNames) {
  final element = node.constructorName.type.element;
  if (element == null || !classNames.contains(element.name)) {
    return false;
  }

  return isFromPackage(element, 'flutter');
}

/// Whether [type] is a Flutter `Widget`, or a `List` / `Iterable` of widgets.
bool isWidgetOrWidgetsType(DartType? type) {
  if (type is! InterfaceType) {
    return false;
  }
  if ((type.isDartCoreList || type.isDartCoreIterable) && type.typeArguments.length == 1) {
    return isWidgetOrWidgetsType(type.typeArguments.single);
  }
  return isSubtypeOf(type.element, 'Widget', 'flutter');
}
