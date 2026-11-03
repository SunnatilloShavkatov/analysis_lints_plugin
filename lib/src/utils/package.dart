import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

/// Whether [element] is declared in a library of [package].
bool isFromPackage(Element? element, String package) =>
    element?.library?.uri.toString().startsWith('package:$package/') ?? false;

/// Whether [element] is the class [className] from [package] or a subtype of it.
bool isSubtypeOf(InterfaceElement? element, String className, String package) {
  if (element == null) {
    return false;
  }

  bool matches(InterfaceElement e) => e.name == className && isFromPackage(e, package);

  return matches(element) || element.allSupertypes.map((InterfaceType t) => t.element).any(matches);
}
