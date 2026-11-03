// Rule: avoid_cross_module_imports.
//
// The rule treats every `<root>/modules/<name>/` folder as a module, so `lib/modules/home` and
// `lib/modules/profile` stand in for two module packages of a monorepo.

class Profile {
  const Profile(this.name);

  final String name;
}
