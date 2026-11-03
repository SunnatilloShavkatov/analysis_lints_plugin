import 'package:flutter/widgets.dart';

// Rule: avoid_for_in_flex_children.

class ItemTile extends StatelessWidget {
  const ItemTile(this.item, {super.key});

  final String item;

  @override
  Widget build(BuildContext context) => Text(item);
}

// GOOD: children built with `map` / a spread.
class ItemList extends StatelessWidget {
  const ItemList({required this.items, super.key});

  final List<String> items;

  @override
  Widget build(BuildContext context) => Column(
    children: [const Text('Items'), ...items.map(ItemTile.new)],
  );
}

// BAD: a `for` element directly in `Column` / `Row` children.
class BadItemList extends StatelessWidget {
  const BadItemList({required this.items, super.key});

  final List<String> items;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      // LINT: avoid_for_in_flex_children
      for (final item in items) ItemTile(item),
      Row(
        children: [
          // LINT: avoid_for_in_flex_children
          if (items.isNotEmpty) for (final item in items) Text(item),
        ],
      ),
    ],
  );
}
