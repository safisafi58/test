import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final ValueNotifier<ThemeMode> promptGoThemeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

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
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('promptgo_theme') ?? 'system';
  promptGoThemeMode.value = savedTheme == 'dark' ? ThemeMode.dark : savedTheme == 'light' ? ThemeMode.light : ThemeMode.system;
  runApp(const PromptGoUser());
}

class PromptGoUser extends StatelessWidget {
  const PromptGoUser({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(valueListenable: promptGoThemeMode, builder: (context, mode, _) => MaterialApp(
    title: 'PromptGo',
    debugShowCheckedModeBanner: false,
    themeMode: mode,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff6750a4)), scaffoldBackgroundColor: const Color(0xfff7f7fa)),
    darkTheme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffb9a5ff), brightness: Brightness.dark), scaffoldBackgroundColor: const Color(0xff101014)),
    home: const PromptGoSplash(),
  ));
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
    Image.asset('assets/sp.png', width: 180, height: 180, fit: BoxFit.contain),
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
  final PageController _latestPageController = PageController(viewportFraction: 0.92);
  Timer? _latestSlideTimer;
  List<Map<String, dynamic>> _latestSliderPosts = [];
  final Set<String> favoriteIds = <String>{};
  String selectedCategory = 'All';
  bool showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _latestSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_latestPageController.hasClients || _latestSliderPosts.length < 2) return;
      final current = (_latestPageController.page ?? 0).round();
      _latestPageController.animateToPage((current + 1) % _latestSliderPosts.length, duration: const Duration(milliseconds: 550), curve: Curves.easeInOut);
    });
  }
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
  void dispose() {
    _latestSlideTimer?.cancel();
    _latestPageController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('prompts');
    return Scaffold(
      drawer: _buildDrawer(context),
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
                'imageUrl': (data['imageUrl'] ?? '').toString(),
                'createdAt': data['createdAt'],
                'isTrending': data['isTrending'] == true,
              });
            }
          }
          prompts.sort((a, b) => (b['createdAt'] is num ? b['createdAt'] as num : 0).compareTo(a['createdAt'] is num ? a['createdAt'] as num : 0));
          _latestSliderPosts = prompts.take(10).toList();
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
            _buildLatestPostsSlider(context),
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
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                  itemCount: visible.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.82),
                  itemBuilder: (context, index) {
                    final p = visible[index];
                    final id = p['id'] as String;
                    final favorite = favoriteIds.contains(id);
                    final imageUrl = (p['imageUrl'] ?? '').toString();
                    return Card(clipBehavior: Clip.antiAlias, child: InkWell(onTap: () => _showDetails(context, p), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Stack(fit: StackFit.expand, children: [
                        if (imageUrl.isNotEmpty) Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: const Icon(Icons.broken_image_outlined))) else Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: const Icon(Icons.image_outlined, size: 42)),
                        Positioned(right: 4, top: 4, child: CircleAvatar(backgroundColor: Colors.black45, radius: 17, child: IconButton(padding: EdgeInsets.zero, iconSize: 18, onPressed: () => _toggleFavorite(id), icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: Colors.white)))),
                      ])),
                      Padding(padding: const EdgeInsets.fromLTRB(10, 9, 10, 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p['title'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)), const SizedBox(height: 5), Text(p['category'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.primary))])),
                    ]))); 
                  },
                ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _buildLatestPostsSlider(BuildContext context) {
    final posts = _latestSliderPosts;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), child: Row(children: [
        const Expanded(child: Text('Latest posts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
        Text('Latest 10', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ])),
      SizedBox(height: 184, child: posts.isEmpty
        ? Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(width: double.infinity, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(18)), alignment: Alignment.center, child: const Text('New prompts will appear here')))
        : PageView.builder(
            controller: _latestPageController,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final p = posts[index];
              final url = (p['imageUrl'] ?? '').toString();
              return Padding(padding: const EdgeInsets.only(right: 10), child: ClipRRect(borderRadius: BorderRadius.circular(18), child: Stack(fit: StackFit.expand, children: [
                if (url.isNotEmpty) Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Theme.of(context).colorScheme.primaryContainer)) else Container(color: Theme.of(context).colorScheme.primaryContainer),
                DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: 0.02), Colors.black.withValues(alpha: 0.78)]))),
                Positioned(left: 16, right: 16, bottom: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text((p['category'] ?? '').toString().toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                  const SizedBox(height: 4),
                  Text((p['title'] ?? '').toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                ])),
              ])));
            },
          )),
    ]);
  }

  Widget _tag(BuildContext context, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onPrimaryContainer)),
  );

  void _showDetails(BuildContext context, Map<String, dynamic> p) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PromptDetailPage(prompt: p)));
  }

  Widget _buildDrawer(BuildContext context) => Drawer(child: SafeArea(child: ListView(padding: EdgeInsets.zero, children: [
    UserAccountsDrawerHeader(margin: EdgeInsets.zero, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary), accountName: const Text('PromptGo', style: TextStyle(fontWeight: FontWeight.w900)), accountEmail: const Text('AI Prompt Library'), currentAccountPicture: const CircleAvatar(child: Icon(Icons.auto_awesome, size: 30))),
    ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('Settings'), subtitle: const Text('Theme and app preferences'), onTap: () { Navigator.pop(context); _showSettings(context); }),
    ListTile(leading: const Icon(Icons.palette_outlined), title: const Text('Appearance'), subtitle: const Text('Light • Dark • System'), onTap: () { Navigator.pop(context); _showThemePicker(context); }),
    ListTile(leading: const Icon(Icons.favorite_outline), title: const Text('Favorites'), onTap: () { Navigator.pop(context); setState(() => showFavoritesOnly = !showFavoritesOnly); }),
    const Divider(),
    ListTile(leading: const Icon(Icons.admin_panel_settings_outlined), title: const Text('Admin profile'), subtitle: const Text('PromptGo administration'), onTap: () { Navigator.pop(context); showAboutDialog(context: context, applicationName: 'PromptGo Admin', applicationVersion: '1.0.0', children: const [Text('Manage prompts in the separate PromptGo Admin app.')]); }),
    ListTile(leading: const Icon(Icons.star_outline), title: const Text('Rate app'), onTap: () async { Navigator.pop(context); await launchUrl(Uri.parse('https://play.google.com/store/search?q=PromptGo&c=apps'), mode: LaunchMode.externalApplication); }),
    ListTile(leading: const Icon(Icons.share_outlined), title: const Text('Share app'), onTap: () { Navigator.pop(context); Share.share('Try PromptGo — an AI prompt library for creative ideas.'); }),
    ListTile(leading: const Icon(Icons.info_outline), title: const Text('About'), onTap: () { Navigator.pop(context); showAboutDialog(context: context, applicationName: 'PromptGo', applicationVersion: '1.0.0', applicationLegalese: 'Ideas into action'); }),
  ])));

  void _showSettings(BuildContext context) => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (ctx) => SafeArea(child: ListView(shrinkWrap: true, children: [
    const ListTile(title: Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
    ListTile(leading: const Icon(Icons.brightness_6_outlined), title: const Text('Appearance'), subtitle: const Text('Choose light, dark or automatic theme'), onTap: () { Navigator.pop(ctx); _showThemePicker(context); }),
    const ListTile(leading: Icon(Icons.info_outline), title: Text('App information'), subtitle: Text('PromptGo • Version 1.0.0')),
  ])));

  void _showThemePicker(BuildContext context) => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Padding(padding: EdgeInsets.all(16), child: Text('Choose appearance', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900))),
    for (final item in <MapEntry<ThemeMode, String>>[const MapEntry(ThemeMode.system, 'Automatic'), const MapEntry(ThemeMode.light, 'Light'), const MapEntry(ThemeMode.dark, 'Dark')])
      RadioListTile<ThemeMode>(value: item.key, groupValue: promptGoThemeMode.value, title: Text(item.value), onChanged: (value) { if (value != null) { promptGoThemeMode.value = value; SharedPreferences.getInstance().then((prefs) => prefs.setString('promptgo_theme', value.name)); Navigator.pop(ctx); } }),
    const SizedBox(height: 12),
  ])));
}

class PromptDetailPage extends StatefulWidget {
  final Map<String, dynamic> prompt;
  const PromptDetailPage({super.key, required this.prompt});
  @override
  State<PromptDetailPage> createState() => _PromptDetailPageState();
}
class _PromptDetailPageState extends State<PromptDetailPage> {
  Timer? _typingTimer;
  String _typedText = '';
  bool _typingComplete = false;
  @override
  void initState() { super.initState(); _startTyping(); }
  void _startTyping() {
    final fullText = (widget.prompt['content'] ?? '').toString();
    if (fullText.isEmpty) { _typingComplete = true; return; }
    _typingTimer = Timer.periodic(const Duration(milliseconds: 18), (timer) {
      if (!mounted) { timer.cancel(); return; }
      final nextLength = (_typedText.length + 1).clamp(0, fullText.length).toInt();
      setState(() { _typedText = fullText.substring(0, nextLength); if (nextLength >= fullText.length) { _typingComplete = true; timer.cancel(); } });
    });
  }
  @override
  void dispose() { _typingTimer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final imageUrl = (widget.prompt['imageUrl'] ?? '').toString();
    final fullText = (widget.prompt['content'] ?? '').toString();
    return Scaffold(appBar: AppBar(title: const Text('Prompt details')), body: ListView(padding: const EdgeInsets.all(16), children: [
      if (imageUrl.isNotEmpty) ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.network(imageUrl, width: double.infinity, height: 250, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 180, color: Theme.of(context).colorScheme.surfaceContainerHighest, child: const Icon(Icons.broken_image_outlined, size: 48)))),
      const SizedBox(height: 18),
      Text((widget.prompt['category'] ?? '').toString(), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6), Text((widget.prompt['title'] ?? '').toString(), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
      const SizedBox(height: 20),
      Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)), child: SelectableText(_typedText, style: const TextStyle(fontSize: 16, height: 1.7))),
      const SizedBox(height: 10),
      if (!_typingComplete) Row(children: [const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)), const SizedBox(width: 9), Text('Preparing prompt...', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))]),
      const SizedBox(height: 18),
      SizedBox(height: 52, child: FilledButton.icon(onPressed: _typingComplete && fullText.isNotEmpty ? () async { await Clipboard.setData(ClipboardData(text: fullText)); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prompt copied successfully'))); } : null, icon: const Icon(Icons.copy_rounded), label: const Text('Copy prompt'))),
    ]));
  }
}
