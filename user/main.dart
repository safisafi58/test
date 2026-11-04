import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const firebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyBbLn0_NN2gghyaZpy2FPBCjUYz8LGUkgc',
  appId: '1:915531372851:android:7198fe96a0cf0c7bce4646',
  messagingSenderId: '915531372851',
  projectId: 'romptgo',
  databaseURL: 'https://romptgo-default-rtdb.firebaseio.com',
);
const promptCategories = <String>[
  'All', 'New', 'Trending', 'Video Prompt', 'Kids', 'DP Maker',
  'Game', 'Cinematic', 'Anime & Cartoon',
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const PromptGoUser());
}

class PromptGoUser extends StatelessWidget {
  const PromptGoUser({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PromptGo',
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.system,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff6750a4)), scaffoldBackgroundColor: const Color(0xfff7f7fa)),
    darkTheme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffb9a5ff), brightness: Brightness.dark), scaffoldBackgroundColor: const Color(0xff101014)),
    home: const PromptGoSplash(),
  );
}

class PromptGoSplash extends StatefulWidget {
  const PromptGoSplash({super.key});
  @override
  State<PromptGoSplash> createState() => _PromptGoSplashState();
}
class _PromptGoSplashState extends State<PromptGoSplash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PromptLibrary()));
    });
  }
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.auto_awesome_rounded, size: 78, color: Theme.of(context).colorScheme.primary),
    const SizedBox(height: 12),
    const Text('PromptGo', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
    const SizedBox(height: 6),
    Text('IDEAS INTO ACTION', style: TextStyle(letterSpacing: 3, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    const SizedBox(height: 24), const CircularProgressIndicator(),
  ])));
  }

class PromptLibrary extends StatefulWidget {
  const PromptLibrary({super.key});
  @override
  State<PromptLibrary> createState() => _PromptLibraryState();
}
class _PromptLibraryState extends State<PromptLibrary> {
  final searchController = TextEditingController();
  final Set<String> favoriteIds = <String>{};
  String selectedCategory = 'All';
  bool showFavoritesOnly = false;

  @override
  void initState() { super.initState(); _loadFavorites(); }
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => favoriteIds.addAll(prefs.getStringList('promptgo_favorites') ?? []));
  }
  Future<void> _toggleFavorite(String id) async {
    setState(() { if (!favoriteIds.add(id)) favoriteIds.remove(id); });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('promptgo_favorites', favoriteIds.toList());
  }
  @override
  void dispose() { searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('prompts');
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.auto_awesome_rounded), SizedBox(width: 9), Text('PromptGo', style: TextStyle(fontWeight: FontWeight.w900))]),
        actions: [
          IconButton(tooltip: 'Favorites', onPressed: () => setState(() => showFavoritesOnly = !showFavoritesOnly), icon: Icon(showFavoritesOnly ? Icons.favorite : Icons.favorite_border)),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Could not load prompts: ${snapshot.error}')));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final raw = snapshot.data!.snapshot.value;
          final List<Map<String, dynamic>> prompts = [];
          if (raw is Map) {
            for (final entry in raw.entries) {
              if (entry.value is! Map) continue;
              final data = Map<dynamic, dynamic>.from(entry.value as Map);
              prompts.add({
                'id': entry.key.toString(),
                'title': (data['title'] ?? 'Untitled').toString(),
                'category': (data['category'] ?? 'Video Prompt').toString(),
                'content': (data['content'] ?? '').toString(),
                'createdAt': data['createdAt'],
                'isTrending': data['isTrending'] == true,
              });
            }
          }
          prompts.sort((a, b) => (b['createdAt'] is num ? b['createdAt'] as num : 0).compareTo(a['createdAt'] is num ? a['createdAt'] as num : 0));
          final query = searchController.text.trim().toLowerCase();
          final visible = prompts.where((p) {
            final created = p['createdAt'] is num ? (p['createdAt'] as num).toInt() : 0;
            final isNew = created > 0 && DateTime.now().millisecondsSinceEpoch - created <= const Duration(days: 7).inMilliseconds;
            final categoryMatch = switch (selectedCategory) {
              'All' => true,
              'New' => isNew,
              'Trending' => p['isTrending'] == true,
              _ => p['category'] == selectedCategory,
            };
            final favoriteMatch = !showFavoritesOnly || favoriteIds.contains(p['id']);
            final searchMatch = query.isEmpty || p.values.any((v) => v.toString().toLowerCase().contains(query));
            return categoryMatch && favoriteMatch && searchMatch;
          }).toList();

          return Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search prompts...', prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isEmpty ? null : IconButton(onPressed: () { searchController.clear(); setState(() {}); }, icon: const Icon(Icons.close)),
                filled: true, fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              ),
            )),
            SizedBox(height: 46, child: ListView.separated(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: promptCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = promptCategories[index];
                return ChoiceChip(label: Text(category), selected: selectedCategory == category, onSelected: (_) => setState(() => selectedCategory = category));
              },
            )),
            const SizedBox(height: 10),
            Expanded(child: visible.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(showFavoritesOnly ? Icons.favorite_border : Icons.search_off, size: 54, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(showFavoritesOnly ? 'No favorites yet' : 'No prompts found', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final p = visible[index];
                    final id = p['id'] as String;
                    final favorite = favoriteIds.contains(id);
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _showDetails(context, p),
                        child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(p['title'] as String, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
                            IconButton(onPressed: () => _toggleFavorite(id), icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: favorite ? Colors.pink : null)),
                          ]),
                          Wrap(spacing: 7, children: [
                            _tag(context, p['category'] as String),
                            if (p['isTrending'] == true) _tag(context, 'Trending'),
                          ]),
                          const SizedBox(height: 12),
                          Text(p['content'] as String, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(height: 1.45, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 12),
                          Align(alignment: Alignment.centerRight, child: Text('View & copy  →', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))),
                        ])),
                      ),
                    );
                  },
                ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _tag(BuildContext context, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onPrimaryContainer)),
  );

  Future<void> _showDetails(BuildContext context, Map<String, dynamic> p) async {
    final id = p['id'] as String;
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true, showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(22, 8, 22, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
        child: SafeArea(child: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p['category'] as String, style: TextStyle(color: Theme.of(sheetContext).colorScheme.primary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(p['title'] as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            SelectableText(p['content'] as String, style: const TextStyle(fontSize: 16, height: 1.6)),
            const SizedBox(height: 22),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () async { await _toggleFavorite(id); if (sheetContext.mounted) Navigator.pop(sheetContext); },
                icon: Icon(favoriteIds.contains(id) ? Icons.favorite : Icons.favorite_border),
                label: Text(favoriteIds.contains(id) ? 'Saved' : 'Favorite'),
              )),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: p['content'] as String));
                  if (!sheetContext.mounted) return;
                  ScaffoldMessenger.of(sheetContext).showSnackBar(const SnackBar(content: Text('Prompt copied')));
                },
                icon: const Icon(Icons.copy), label: const Text('Copy prompt'),
              )),
            ]),
          ],
        ))),
      ),
    );
  }
}
