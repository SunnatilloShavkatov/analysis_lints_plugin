## 1.0.0

* Initial release as a native Dart analyzer plugin.
* `avoid_widget_returning_functions`: no functions, methods or getters that return widgets.
* `avoid_cross_module_imports`: no imports between packages in a `modules/` folder.
* `avoid_mutable_bloc_fields`: no non-final instance fields in a `Bloc` / `Cubit`.
* `require_bloc_event_transformer`: every `on<Event>()` needs `transformer:`.
* `require_bloc_builder_build_when`: every `BlocBuilder` / `BlocConsumer` needs `buildWhen:`.
* `avoid_for_in_flex_children`: no `for` element directly in `Column` / `Row` / `Flex` children.
