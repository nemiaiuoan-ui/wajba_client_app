import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/providers.dart';
import '../../shared/models/models.dart';
import '../home/presentation/widgets/restaurant_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _query = '';

  final _recent = ['Couscous', 'Pizza Royale', 'Shawarma', 'Burger'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() { _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final filter = RestaurantFilter(search: _query.isNotEmpty ? _query : null);
    final restaurantsAsync = _query.isNotEmpty ? ref.watch(restaurantsProvider(filter)) : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _ctrl,
          focusNode: _focus,
          onChanged: (v) => setState(() => _query = v.trim()),
          decoration: InputDecoration(
            hintText: 'Restaurants, plats, cuisine...',
            hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: WajbaColors.grey400),
            border: InputBorder.none,
            filled: false,
            suffixIcon: _query.isNotEmpty
                ? IconButton(icon: const Icon(Icons.close, size: 18, color: WajbaColors.grey400), onPressed: () { _ctrl.clear(); setState(() => _query = ''); })
                : null,
          ),
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
        ),
      ),
      body: _query.isEmpty
          ? _SearchIdle(recent: _recent, onTap: (v) { _ctrl.text = v; setState(() => _query = v); })
          : restaurantsAsync!.when(
              loading: () => const Center(child: CircularProgressIndicator(color: WajbaColors.primary)),
              error: (e, _) => Center(child: Text('Erreur: $e')),
              data: (results) => results.isEmpty
                  ? Center(child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text('Aucun résultat pour "$_query"', style: const TextStyle(fontSize: 15, color: WajbaColors.grey500, fontFamily: 'Cairo')),
                      ],
                    ))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => RestaurantCard(
                        restaurant: results[i],
                        onTap: () => context.push('/restaurant/${results[i].id}'),
                      ),
                    ),
            ),
    );
  }
}

class _SearchIdle extends StatelessWidget {
  final List<String> recent;
  final ValueChanged<String> onTap;
  const _SearchIdle({required this.recent, required this.onTap});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      if (recent.isNotEmpty) ...[
        Row(
          children: [
            const Text('Recherches récentes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
            const Spacer(),
            TextButton(onPressed: () {}, child: const Text('Effacer', style: TextStyle(color: WajbaColors.grey400, fontSize: 12, fontFamily: 'Cairo'))),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: recent.map((r) => GestureDetector(
            onTap: () => onTap(r),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: WajbaColors.grey100, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history, size: 14, color: WajbaColors.grey400),
                  const SizedBox(width: 6),
                  Text(r, style: const TextStyle(fontSize: 13, fontFamily: 'Cairo', color: WajbaColors.grey700)),
                ],
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 24),
      ],
      const Text('Tendances 🔥', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
      const SizedBox(height: 12),
      ...['Couscous traditionnel', 'Pizza 4 fromages', 'Shawarma mixte', 'Bourek', 'Jus frais'].map(
        (item) => ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: const Text('🔥', style: TextStyle(fontSize: 20)),
          title: Text(item, style: const TextStyle(fontSize: 14, fontFamily: 'Cairo')),
          trailing: const Icon(Icons.north_east, size: 14, color: WajbaColors.grey300),
          onTap: () => onTap(item),
        ),
      ),
    ],
  );
}
