# analysis_lints_plugin

Lint rules for Flutter and [bloc](https://pub.dev/packages/bloc) code, delivered as a native Dart
analyzer plugin (`analysis_server_plugin`). Diagnostics are reported by `dart analyze`,
`flutter analyze` and the IDE like built-in lints, and can be suppressed with `// ignore:`.

## Installation

The plugin is not a dependency: add it to `analysis_options.yaml` and the analysis server fetches it
from pub.dev. Lint rules are off by default, so list the ones you want under `diagnostics:`.

```yaml
plugins:
  analysis_lints_plugin:
    version: ^1.0.0
    diagnostics:
      avoid_cross_module_imports: true
      avoid_for_in_flex_children: true
      avoid_mutable_bloc_fields: true
      avoid_widget_returning_functions: true
      require_bloc_builder_build_when: true
      require_bloc_event_transformer: true
```

Instead of `true` a rule can take a severity: `error`, `warning` or `info` (`false` disables it).

Then run:

```bash
dart analyze
```

Requires Dart SDK `>=3.13.0`. Restart the analysis server in the IDE after changing the `plugins:`
block.

## Rules

| Rule                               | Bans                                                           |
|------------------------------------|----------------------------------------------------------------|
| `avoid_widget_returning_functions` | `Widget _buildX()`, `List<Widget> _buildX()`, widget getters   |
| `avoid_cross_module_imports`       | a package in `modules/` importing another one in `modules/`    |
| `avoid_mutable_bloc_fields`        | non-final instance fields in a `Bloc` / `Cubit`                |
| `require_bloc_event_transformer`   | `on<Event>()` without `transformer:`                           |
| `require_bloc_builder_build_when`  | `BlocBuilder` / `BlocConsumer` without `buildWhen:`            |
| `avoid_for_in_flex_children`       | a `for` element directly in `Column` / `Row` / `Flex` children |

### `avoid_widget_returning_functions`

Don't build UI in a function, method or getter in `lib/` that returns a `Widget` or a `List` /
`Iterable` of widgets, local functions included. Extract a `StatelessWidget` class and pass its data
through the constructor.

Allowed: `build`, `@override` members, and members that only look a widget up or pass one through
without constructing one (`InheritedWidget.of`, `get child`). `test/` is not checked.

```dart
// BAD
Widget _buildHeader() => Text(title);

// GOOD
class HeaderWidget extends StatelessWidget {
  const HeaderWidget({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Text(title);
}
```

### `avoid_cross_module_imports`

For monorepos where feature packages live in a `modules/` folder: a package in `modules/` must not
import or export another package in the same `modules/` folder. The check uses the resolved file
path of the imported library, so it catches `package:` and relative URIs alike, and ignores
dependencies outside the monorepo. Files outside a `modules/` folder are not checked.

Go through a shared package instead (an interface registered through DI, a shared entity).

```dart
// BAD, in modules/home/lib/...
import 'package:profile/profile.dart';
```

### `avoid_mutable_bloc_fields`

No non-final instance fields in a `Bloc` or `Cubit` (`package:bloc`). Keep UI data in the widget
state and send it to the bloc in the event.

```dart
// BAD
final class GamesBloc extends Bloc<GamesEvent, GamesState> {
  int _page = 1;
}

// GOOD — the widget owns `_page` and sends it
bloc.add(GetGamesEvent(page: _page));
```

### `require_bloc_event_transformer`

Every `on<Event>()` in a `Bloc` needs an explicit `transformer:` (`droppable()`, `restartable()`,
`sequential()`, … from [bloc_concurrency](https://pub.dev/packages/bloc_concurrency)).

```dart
// BAD
on<GetGamesEvent>(_getGamesHandler);

// GOOD
on<GetGamesEvent>(_getGamesHandler, transformer: droppable());
```

### `require_bloc_builder_build_when`

Every `BlocBuilder` / `BlocConsumer` (`package:flutter_bloc`) needs `buildWhen:`, so it rebuilds
only for the states it renders.

```dart
// GOOD
BlocBuilder<GamesBloc, GamesState>(
  buildWhen: (prev, curr) => curr is GetGamesState,
  builder: (context, state) => ...,
);
```

### `avoid_for_in_flex_children`

Don't put a `for` element directly in the `children` of `Column`, `Row` or `Flex`. A `for` inside an
`if` element or a spread in `children` is reported too.

```dart
// BAD
Column(children: [for (final item in items) ItemTile(item)]);

// GOOD
Column(children: items.map(ItemTile.new).toList());
Column(children: [const Header(), ...items.map(ItemTile.new)]);
Column(children: List.generate(items.length, (i) => ItemTile(items[i])));
```

## Suppressing a diagnostic

```dart
// ignore: analysis_lints_plugin/avoid_widget_returning_functions
```

or for a whole file:

```dart
// ignore_for_file: analysis_lints_plugin/avoid_widget_returning_functions
```

## Large workspaces

The analysis server builds the plugin once per analysis context. In a repository with many separate
packages that are not a [pub workspace](https://dart.dev/tools/pub/workspaces), every package is its
own context, and enabling the plugin in all of them at once can use a lot of memory in the IDE.
Prefer a pub workspace, or enable the plugin only where you run `dart analyze` in CI.

## Example

[`example/`](example/) has one BAD and one GOOD case per rule; run `dart analyze` there to see every
diagnostic.
