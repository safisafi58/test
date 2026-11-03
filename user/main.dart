import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const firebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyDJ5MIO3mJDu3mJDuP1-0GQ3xiHMI7XR1htO2Kw',
  appId: '1:451486689188:android:5e9553bce575e168ef8331',
  messagingSenderId: '451486689188',
  projectId: 'pashto-poetry-new-2c4ba',
  databaseURL: 'https://pashto-poetry-new-2c4ba-default-rtdb.firebaseio.com',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const PromptGoUser());
}

class PromptGoUser extends StatelessWidget {
  const PromptGoUser({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PromptGo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7FA),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB9A5FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101014),
      ),
      home: const PromptGoSplash(),
    );
  }
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
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const PromptLibrary()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 52,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'PromptGo',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            Text(
              'IDEAS INTO ACTION',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 3,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}

class PromptLibrary extends StatefulWidget {
  const PromptLibrary({super.key});

  @override
  State<PromptLibrary> createState() => _PromptLibraryState();
}

class _PromptLibraryState extends State<PromptLibrary> {
  final TextEditingController searchController = TextEditingController();
  final Set<String> favoriteIds = <String>{};
  String selectedCategory = 'All';
  bool showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      favoriteIds.addAll(prefs.getStringList('promptgo_favorites') ?? []);
    });
  }

  Future<void> _toggleFavorite(String id) async {
    setState(() {
      if (!favoriteIds.add(id)) {
        favoriteIds.remove(id);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('promptgo_favorites', favoriteIds.toList());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promptsRef = FirebaseDatabase.instance.ref('prompts');

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded),
            SizedBox(width: 9),
            Text(
              'PromptGo',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            onPressed: () {
              setState(() {
                showFavoritesOnly = !showFavoritesOnly;
              });
            },
            icon: Icon(
              showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
            ),
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: promptsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load prompts: ${snapshot.error}'),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rawValue = snapshot.data!.snapshot.value;
          final List<Map<String, String>> prompts = [];

          if (rawValue is Map) {
            for (final entry in rawValue.entries) {
              if (entry.value is! Map) continue;
              final data = Map<dynamic, dynamic>.from(entry.value as Map);
              prompts.add({
                'id': entry.key.toString(),
                'title': (data['title'] ?? 'Untitled').toString(),
                'category': (data['category'] ?? 'General').toString(),
                'content': (data['content'] ?? '').toString(),
              });
            }
          }

          prompts.sort(
            (a, b) => a['title']!.toLowerCase().compareTo(
                  b['title']!.toLowerCase(),
                ),
          );

          final categorySet = <String>{};
          for (final prompt in prompts) {
            categorySet.add(prompt['category']!);
          }
          final categories = ['All', ...categorySet.toList()..sort()];

          final query = searchController.text.trim().toLowerCase();
          final visiblePrompts = prompts.where((prompt) {
            final matchesCategory = selectedCategory == 'All' ||
                prompt['category'] == selectedCategory;
            final matchesFavorite = !showFavoritesOnly ||
                favoriteIds.contains(prompt['id']);
            final matchesSearch = query.isEmpty ||
                prompt.values.any(
                  (value) => value.toLowerCase().contains(query),
                );
            return matchesCategory && matchesFavorite && matchesSearch;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search prompts...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ChoiceChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      onSelected: (_) {
                        setState(() => selectedCategory = category);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: visiblePrompts.isEmpty
                    ? _buildEmptyState(context, query)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: visiblePrompts.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 11),
                        itemBuilder: (context, index) {
                          final prompt = visiblePrompts[index];
                          final id = prompt['id']!;
                          final isFavorite = favoriteIds.contains(id);

                          return Card(
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                _showPromptDetails(context, prompt);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            prompt['title']!,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Favorite',
                                          onPressed: () =>
                                              _toggleFavorite(id),
                                          icon: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isFavorite
                                                ? Colors.pink
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        prompt['category']!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      prompt['content']!,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        height: 1.45,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.copy_rounded,
                                          size: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'View & copy',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String query) {
    final message = showFavoritesOnly
        ? 'No favorites yet'
        : query.isEmpty
            ? 'No prompts yet'
            : 'No results found';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            showFavoritesOnly ? Icons.favorite_border : Icons.search_off,
            size: 52,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            showFavoritesOnly
                ? 'Tap the heart to save prompts.'
                : 'Try another search or check back later.',
          ),
        ],
      ),
    );
  }

  Future<void> _showPromptDetails(
    BuildContext context,
    Map<String, String> prompt,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final id = prompt['id']!;
        final isFavorite = favoriteIds.contains(id);

        return Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            8,
            22,
            MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    prompt['category']!,
                    style: TextStyle(
                      color: Theme.of(sheetContext).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    prompt['title']!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SelectableText(
                    prompt['content']!,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _toggleFavorite(id);
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          label: Text(
                            isFavorite ? 'Saved' : 'Favorite',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: prompt['content']!),
                            );
                            if (!sheetContext.mounted) return;
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              const SnackBar(
                                content: Text('Prompt copied'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy prompt'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
