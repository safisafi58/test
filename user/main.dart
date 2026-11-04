import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final ValueNotifier<ThemeMode> promptGoThemeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

final ValueNotifier<String> promptGoLanguage = ValueNotifier<String>('English');
const promptGoLanguages = <String>['Pashto','Persian','Dari','Urdu','Arabic','English','German','French','Spanish','Turkish','Chinese','Hindi','Bengali'];
bool get promptGoIsRtl => const ['Pashto','Persian','Dari','Urdu','Arabic'].contains(promptGoLanguage.value);
String pg(String key) {
  const values = <String, Map<String, String>>{
    'Pashto': {'Settings':'تنظیمات','Theme and app preferences':'د اپلیکیشن بڼه او تنظیمات','Appearance':'بڼه','Favorites':'خوښې شوې','Rate app':'اپلیکیشن ته درجه ورکړئ','Share app':'اپلیکیشن شریک کړئ','About':'د اپلیکیشن په اړه','Creator info':'د جوړوونکي معلومات','Exit':'وتل','Language':'ژبه','Choose language':'ژبه وټاکئ','Choose appearance':'د اپلیکیشن بڼه وټاکئ','Automatic':'اتومات','Light':'روښانه','Dark':'تیاره','App guide':'د اپلیکیشن لارښود','Copy prompt':'پرامپټ کاپي کړئ'},
    'Persian': {'Settings':'تنظیمات','Theme and app preferences':'ظاهر و تنظیمات برنامه','Appearance':'ظاهر','Favorites':'علاقه‌مندی‌ها','Rate app':'امتیاز به برنامه','Share app':'اشتراک‌گذاری برنامه','About':'درباره برنامه','Creator info':'اطلاعات سازنده','Exit':'خروج','Language':'زبان','Choose language':'انتخاب زبان','Choose appearance':'انتخاب ظاهر','Automatic':'خودکار','Light':'روشن','Dark':'تیره','App guide':'راهنمای برنامه','Copy prompt':'کپی پرامپت'},
    'Dari': {'Settings':'تنظیمات','Theme and app preferences':'ظاهر و تنظیمات برنامه','Appearance':'ظاهر','Favorites':'علاقه‌مندی‌ها','Rate app':'امتیاز به برنامه','Share app':'شریک‌سازی برنامه','About':'درباره برنامه','Creator info':'معلومات سازنده','Exit':'خروج','Language':'زبان','Choose language':'انتخاب زبان','Choose appearance':'انتخاب ظاهر','Automatic':'خودکار','Light':'روشن','Dark':'تیره','App guide':'راهنمای برنامه','Copy prompt':'کاپی پرامپت'},
    'Urdu': {'Settings':'ترتیبات','Theme and app preferences':'ایپ کی شکل اور ترتیبات','Appearance':'ظاہری شکل','Favorites':'پسندیدہ','Rate app':'ایپ کو ریٹ کریں','Share app':'ایپ شیئر کریں','About':'ایپ کے بارے میں','Creator info':'تخلیق کار کی معلومات','Exit':'باہر نکلیں','Language':'زبان','Choose language':'زبان منتخب کریں','Choose appearance':'ظاہری شکل منتخب کریں','Automatic':'خودکار','Light':'روشن','Dark':'گہرا','App guide':'ایپ گائیڈ','Copy prompt':'پرامپٹ کاپی کریں'},
    'Arabic': {'Settings':'الإعدادات','Theme and app preferences':'المظهر وتفضيلات التطبيق','Appearance':'المظهر','Favorites':'المفضلة','Rate app':'قيّم التطبيق','Share app':'مشاركة التطبيق','About':'حول التطبيق','Creator info':'معلومات المنشئ','Exit':'خروج','Language':'اللغة','Choose language':'اختر اللغة','Choose appearance':'اختر المظهر','Automatic':'تلقائي','Light':'فاتح','Dark':'داكن','App guide':'دليل التطبيق','Copy prompt':'نسخ النص'},
    'English': {'Settings':'Settings','Theme and app preferences':'Theme and app preferences','Appearance':'Appearance','Favorites':'Favorites','Rate app':'Rate app','Share app':'Share app','About':'About','Creator info':'Creator info','Exit':'Exit','Language':'Language','Choose language':'Choose language','Choose appearance':'Choose appearance','Automatic':'Automatic','Light':'Light','Dark':'Dark','App guide':'How to use PromptGo','Copy prompt':'Copy prompt'},
    'German': {'Settings':'Einstellungen','Theme and app preferences':'Design und App-Einstellungen','Appearance':'Darstellung','Favorites':'Favoriten','Rate app':'App bewerten','Share app':'App teilen','About':'Über','Creator info':'Informationen zum Ersteller','Exit':'Beenden','Language':'Sprache','Choose language':'Sprache wählen','Choose appearance':'Darstellung wählen','Automatic':'Automatisch','Light':'Hell','Dark':'Dunkel','App guide':'App-Anleitung','Copy prompt':'Prompt kopieren'},
    'French': {'Settings':'Paramètres','Theme and app preferences':'Thème et préférences','Appearance':'Apparence','Favorites':'Favoris','Rate app':'Noter l’application','Share app':'Partager l’application','About':'À propos','Creator info':'Informations du créateur','Exit':'Quitter','Language':'Langue','Choose language':'Choisir la langue','Choose appearance':'Choisir l’apparence','Automatic':'Automatique','Light':'Clair','Dark':'Sombre','App guide':'Guide de l’application','Copy prompt':'Copier le prompt'},
    'Spanish': {'Settings':'Ajustes','Theme and app preferences':'Tema y preferencias','Appearance':'Apariencia','Favorites':'Favoritos','Rate app':'Calificar la app','Share app':'Compartir app','About':'Acerca de','Creator info':'Información del creador','Exit':'Salir','Language':'Idioma','Choose language':'Elegir idioma','Choose appearance':'Elegir apariencia','Automatic':'Automático','Light':'Claro','Dark':'Oscuro','App guide':'Guía de la app','Copy prompt':'Copiar prompt'},
    'Turkish': {'Settings':'Ayarlar','Theme and app preferences':'Tema ve uygulama tercihleri','Appearance':'Görünüm','Favorites':'Favoriler','Rate app':'Uygulamayı değerlendir','Share app':'Uygulamayı paylaş','About':'Hakkında','Creator info':'Oluşturucu bilgisi','Exit':'Çıkış','Language':'Dil','Choose language':'Dil seçin','Choose appearance':'Görünüm seçin','Automatic':'Otomatik','Light':'Açık','Dark':'Koyu','App guide':'Uygulama rehberi','Copy prompt':'Promptu kopyala'},
    'Chinese': {'Settings':'设置','Theme and app preferences':'主题和应用偏好','Appearance':'外观','Favorites':'收藏','Rate app':'评价应用','Share app':'分享应用','About':'关于','Creator info':'创作者信息','Exit':'退出','Language':'语言','Choose language':'选择语言','Choose appearance':'选择外观','Automatic':'自动','Light':'浅色','Dark':'深色','App guide':'使用指南','Copy prompt':'复制提示词'},
    'Hindi': {'Settings':'सेटिंग्स','Theme and app preferences':'थीम और ऐप प्राथमिकताएँ','Appearance':'दिखावट','Favorites':'पसंदीदा','Rate app':'ऐप को रेट करें','Share app':'ऐप साझा करें','About':'ऐप के बारे में','Creator info':'निर्माता की जानकारी','Exit':'बाहर निकलें','Language':'भाषा','Choose language':'भाषा चुनें','Choose appearance':'दिखावट चुनें','Automatic':'स्वचालित','Light':'हल्का','Dark':'गहरा','App guide':'ऐप उपयोग गाइड','Copy prompt':'प्रॉम्प्ट कॉपी करें'},
    'Bengali': {'Settings':'সেটিংস','Theme and app preferences':'থিম ও অ্যাপ পছন্দ','Appearance':'চেহারা','Favorites':'পছন্দের','Rate app':'অ্যাপ রেট করুন','Share app':'অ্যাপ শেয়ার করুন','About':'অ্যাপ সম্পর্কে','Creator info':'নির্মাতার তথ্য','Exit':'বের হন','Language':'ভাষা','Choose language':'ভাষা নির্বাচন করুন','Choose appearance':'চেহারা নির্বাচন করুন','Automatic':'স্বয়ংক্রিয়','Light':'হালকা','Dark':'গাঢ়','App guide':'অ্যাপ ব্যবহারের নির্দেশিকা','Copy prompt':'প্রম্পট কপি করুন'},
  };
  return values[promptGoLanguage.value]?[key] ?? values['English']![key] ?? key;
}


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
  promptGoLanguage.value = prefs.getString('promptgo_language') ?? 'English';
  promptGoThemeMode.value = savedTheme == 'dark' ? ThemeMode.dark : savedTheme == 'light' ? ThemeMode.light : ThemeMode.system;
  runApp(const PromptGoUser());
}

class PromptGoUser extends StatelessWidget {
  const PromptGoUser({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: Listenable.merge([promptGoThemeMode, promptGoLanguage]), builder: (context, _) => MaterialApp(
    title: 'PromptGo',
    debugShowCheckedModeBanner: false,
    themeMode: promptGoThemeMode.value,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff6750a4)), scaffoldBackgroundColor: const Color(0xfff7f7fa)),
    darkTheme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffb9a5ff), brightness: Brightness.dark), scaffoldBackgroundColor: const Color(0xff101014)),
    builder: (context, child) => Directionality(textDirection: promptGoIsRtl ? TextDirection.rtl : TextDirection.ltr, child: child ?? const SizedBox.shrink()),
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

          return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
            visible.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(showFavoritesOnly ? Icons.favorite_border : Icons.search_off, size: 54, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(showFavoritesOnly ? 'No favorites yet' : 'No prompts found', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                ]))
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
          ]));
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
    ListTile(leading: const Icon(Icons.settings_outlined), title: Text(pg('Settings')), subtitle: Text(pg('Theme and app preferences')), onTap: () { Navigator.pop(context); _showSettings(context); }),
    ListTile(leading: const Icon(Icons.palette_outlined), title: Text(pg('Appearance')), subtitle: Text(pg('Light') + ' • ' + pg('Dark') + ' • ' + pg('Automatic')), onTap: () { Navigator.pop(context); _showThemePicker(context); }),
    ListTile(leading: const Icon(Icons.favorite_outline), title: Text(pg('Favorites')), onTap: () { Navigator.pop(context); setState(() => showFavoritesOnly = !showFavoritesOnly); }),
    const Divider(),
    ListTile(leading: const Icon(Icons.person_outline), title: Text(pg('Creator info')), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatorInfoPage())); }),
    ListTile(leading: const Icon(Icons.star_outline), title: Text(pg('Rate app')), onTap: () async { Navigator.pop(context); await launchUrl(Uri.parse('https://play.google.com/store/search?q=PromptGo&c=apps'), mode: LaunchMode.externalApplication); }),
    ListTile(leading: const Icon(Icons.share_outlined), title: Text(pg('Share app')), onTap: () { Navigator.pop(context); Share.share('Try PromptGo — an AI prompt library for creative ideas.'); }),
    ListTile(leading: const Icon(Icons.info_outline), title: Text(pg('About')), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPromptGoPage())); }),
    const Divider(),
    ListTile(leading: const Icon(Icons.exit_to_app), title: Text(pg('Exit')), onTap: () { Navigator.pop(context); SystemNavigator.pop(); }),
  ])));

  void _showSettings(BuildContext context) => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (ctx) => SafeArea(child: ListView(shrinkWrap: true, children: [
    ListTile(title: Text(pg('Settings'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
    ListTile(leading: const Icon(Icons.language), title: Text(pg('Language')), subtitle: Text(promptGoLanguage.value), onTap: () { Navigator.pop(ctx); _showLanguagePicker(context); }),
    ListTile(leading: const Icon(Icons.brightness_6_outlined), title: Text(pg('Appearance')), subtitle: Text(pg('Choose appearance')), onTap: () { Navigator.pop(ctx); _showThemePicker(context); }),
    ListTile(leading: const Icon(Icons.info_outline), title: Text(pg('About')), subtitle: const Text('PromptGo • Version 1.0.0'), onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPromptGoPage())); }),
  ])));

  void _showLanguagePicker(BuildContext context) => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (ctx) => SafeArea(child: ListView(shrinkWrap: true, children: [ListTile(title: Text(pg('Choose language'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900))), for (final language in promptGoLanguages) RadioListTile<String>(value: language, groupValue: promptGoLanguage.value, title: Text(language), onChanged: (value) async { if (value != null) { promptGoLanguage.value = value; final prefs = await SharedPreferences.getInstance(); await prefs.setString('promptgo_language', value); if (ctx.mounted) Navigator.pop(ctx); } })])));

  void _showThemePicker(BuildContext context) => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Padding(padding: const EdgeInsets.all(16), child: Text(pg('Choose appearance'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900))),
    for (final item in <MapEntry<ThemeMode, String>>[MapEntry(ThemeMode.system, pg('Automatic')), MapEntry(ThemeMode.light, pg('Light')), MapEntry(ThemeMode.dark, pg('Dark'))])
      RadioListTile<ThemeMode>(value: item.key, groupValue: promptGoThemeMode.value, title: Text(item.value), onChanged: (value) { if (value != null) { promptGoThemeMode.value = value; SharedPreferences.getInstance().then((prefs) => prefs.setString('promptgo_theme', value.name)); Navigator.pop(ctx); } }),
    const SizedBox(height: 12),
  ])));
}


class AboutPromptGoPage extends StatelessWidget {
  const AboutPromptGoPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(pg('About'))), body: ListView(padding: const EdgeInsets.all(20), children: [
    const Icon(Icons.auto_awesome_rounded, size: 64),
    const SizedBox(height: 12),
    const Center(child: Text('PromptGo', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900))),
    const SizedBox(height: 20),
    Text(pg('App guide'), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
    const SizedBox(height: 12),
    const Text('1. Browse prompt cards on the Home screen.\n\n2. Use search or category filters to find prompts.\n\n3. Tap a card to open its details and view the image.\n\n4. Wait until the prompt text finishes appearing; the Copy button becomes active when ready.\n\n5. Tap Copy prompt, then paste it into your favorite AI app.\n\n6. Tap the heart icon to save prompts to Favorites.\n\n7. Open Settings to change language or choose Light, Dark, or Automatic appearance.\n\nPromptGo needs an internet connection to load online prompts.'),
    const SizedBox(height: 16), const Text('Version 1.0.0 • Ideas into action', style: TextStyle(fontWeight: FontWeight.w700)),
  ]));
}
class CreatorInfoPage extends StatelessWidget {
  const CreatorInfoPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(pg('Creator info'))), body: ListView(padding: const EdgeInsets.all(22), children: [
    Center(child: ClipRRect(borderRadius: BorderRadius.circular(100), child: Image.asset('assets/admin.JPG', width: 150, height: 150, fit: BoxFit.cover))),
    const SizedBox(height: 18),
    const Center(child: Text('Sayed Safi', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900))),
    const SizedBox(height: 14),
    const Text('Sayed Safi is the creator of PromptGo. He works to make creative ideas and useful AI prompts easier to discover, organize, and use. PromptGo helps people find inspiration, explore visual styles, and copy ready-to-use prompts with ease.'),
    const SizedBox(height: 24),
    Card(child: ListTile(leading: const Icon(Icons.email_outlined), title: const Text('Email'), subtitle: const Text('noorrahmansayede07@gmail.com'), onTap: () => launchUrl(Uri.parse('mailto:noorrahmansayede07@gmail.com')))),
    Card(child: ListTile(leading: const Icon(Icons.chat_outlined), title: const Text('WhatsApp'), subtitle: const Text('+93744864493'), onTap: () => launchUrl(Uri.parse('https://wa.me/93744864493'), mode: LaunchMode.externalApplication))),
  ]));
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
