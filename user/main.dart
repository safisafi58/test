import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final ValueNotifier<ThemeMode> promptGoThemeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
final ValueNotifier<Color> promptGoAccent = ValueNotifier<Color>(const Color(0xff6750a4));

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

String pgGuide() {
  const guide = <String,String>{
    'Pashto':'۱. په کورپاڼه کې د پرامپټونو کارتونه وګورئ.\n\n۲. د لټون او کټګوریو له لارې پرامپټ ومومئ.\n\n۳. پر کارت کلیک وکړئ، انځور او متن وګورئ.\n\n۴. د متن له بشپړېدو وروسته د Copy تڼۍ ووهئ.\n\n۵. کاپي شوی متن په خپلې خوښې AI وسیلې کې وکاروئ.\n\n۶. د زړه نښه ووهئ څو پرامپټ خوښ شوو کې خوندي شي.\n\n۷. په تنظیماتو کې ژبه، رنګ او بڼه بدله کړئ.\n\nPromptGo د کار لپاره انټرنېټ ته اړتیا لري.',
    'Persian':'۱. کارت‌های پرامپت را در صفحه اصلی مرور کنید.\n\n۲. با جستجو یا دسته‌بندی‌ها پرامپت پیدا کنید.\n\n۳. روی کارت بزنید تا تصویر و متن باز شود.\n\n۴. پس از آماده‌شدن متن، دکمه کپی را بزنید.\n\n۵. متن را در ابزار هوش مصنوعی دلخواه خود استفاده کنید.\n\n۶. با نماد قلب، پرامپت را ذخیره کنید.\n\n۷. زبان و ظاهر را از تنظیمات تغییر دهید.\n\nPromptGo برای کار به اینترنت نیاز دارد.',
    'Dari':'۱. کارت‌های پرامپت را در صفحه اصلی ببینید.\n\n۲. با جستجو یا دسته‌بندی‌ها پرامپت پیدا کنید.\n\n۳. روی کارت بزنید تا تصویر و متن باز شود.\n\n۴. پس از آماده‌شدن متن، دکمه کاپی را بزنید.\n\n۵. متن را در ابزار هوش مصنوعی دلخواه استفاده کنید.\n\n۶. با نشان قلب، پرامپت را ذخیره کنید.\n\n۷. زبان و ظاهر را از تنظیمات تغییر دهید.\n\nPromptGo برای کار به اینترنت نیاز دارد.',
    'Urdu':'۱. ہوم اسکرین پر پرامپٹ کارڈز دیکھیں۔\n\n۲. تلاش یا کیٹیگریز سے پرامپٹ تلاش کریں۔\n\n۳. تصویر اور متن کھولنے کے لیے کارڈ پر ٹیپ کریں۔\n\n۴. متن تیار ہونے کے بعد کاپی بٹن دبائیں۔\n\n۵. متن اپنی پسندیدہ AI ایپ میں استعمال کریں۔\n\n۶. دل کے نشان سے پرامپٹ محفوظ کریں۔\n\n۷. سیٹنگز میں زبان اور تھیم تبدیل کریں۔\n\nPromptGo کے لیے انٹرنیٹ ضروری ہے۔',
    'Arabic':'١. تصفح بطاقات المطالبات في الصفحة الرئيسية.\n\n٢. استخدم البحث أو الفئات للعثور على مطالبة.\n\n٣. اضغط على البطاقة لعرض الصورة والنص.\n\n٤. بعد اكتمال النص اضغط زر النسخ.\n\n٥. استخدم النص في تطبيق الذكاء الاصطناعي المفضل لديك.\n\n٦. احفظ المطالبات باستخدام رمز القلب.\n\n٧. غيّر اللغة والمظهر من الإعدادات.\n\nيتطلب PromptGo اتصالاً بالإنترنت.',
    'English':'1. Browse prompt cards on the Home screen.\n\n2. Use search or categories to find prompts.\n\n3. Tap a card to view its image and text.\n\n4. When the text is ready, tap Copy.\n\n5. Paste it into your preferred AI tool.\n\n6. Save prompts with the heart icon.\n\n7. Change language and appearance in Settings.\n\nPromptGo requires an internet connection.',
    'German':'1. Durchsuche die Prompt-Karten auf der Startseite.\n\n2. Nutze Suche oder Kategorien.\n\n3. Tippe auf eine Karte, um Bild und Text zu öffnen.\n\n4. Tippe nach der Textanzeige auf Kopieren.\n\n5. Verwende den Text in deinem KI-Tool.\n\n6. Speichere Prompts mit dem Herzsymbol.\n\n7. Ändere Sprache und Darstellung in den Einstellungen.\n\nPromptGo benötigt eine Internetverbindung.',
    'French':'1. Parcourez les cartes de prompts sur l’accueil.\n\n2. Utilisez la recherche ou les catégories.\n\n3. Touchez une carte pour voir son image et son texte.\n\n4. Lorsque le texte est prêt, touchez Copier.\n\n5. Collez-le dans votre outil IA préféré.\n\n6. Enregistrez les prompts avec le cœur.\n\n7. Changez la langue et l’apparence dans les paramètres.\n\nPromptGo nécessite Internet.',
    'Spanish':'1. Explora las tarjetas de prompts en Inicio.\n\n2. Usa la búsqueda o las categorías.\n\n3. Toca una tarjeta para ver su imagen y texto.\n\n4. Cuando el texto esté listo, toca Copiar.\n\n5. Pégalo en tu herramienta de IA favorita.\n\n6. Guarda prompts con el icono del corazón.\n\n7. Cambia idioma y apariencia en Ajustes.\n\nPromptGo necesita conexión a Internet.',
    'Turkish':'1. Ana ekrandaki prompt kartlarına göz atın.\n\n2. Arama veya kategorileri kullanın.\n\n3. Görsel ve metni açmak için karta dokunun.\n\n4. Metin hazır olduğunda Kopyala’ya dokunun.\n\n5. Metni tercih ettiğiniz yapay zekâ aracında kullanın.\n\n6. Kalp simgesiyle promptları kaydedin.\n\n7. Ayarlardan dili ve görünümü değiştirin.\n\nPromptGo internet bağlantısı gerektirir.',
    'Chinese':'1. 浏览主页上的提示词卡片。\n\n2. 使用搜索或分类查找提示词。\n\n3. 点击卡片查看图片和文本。\n\n4. 文本准备好后点击复制。\n\n5. 将文本粘贴到常用的 AI 工具中。\n\n6. 点击心形图标收藏提示词。\n\n7. 在设置中更改语言和外观。\n\nPromptGo 需要互联网连接。',
    'Hindi':'1. होम स्क्रीन पर प्रॉम्प्ट कार्ड देखें।\n\n2. खोज या श्रेणियों से प्रॉम्प्ट ढूँढें।\n\n3. चित्र और टेक्स्ट देखने के लिए कार्ड टैप करें।\n\n4. टेक्स्ट तैयार होने पर कॉपी दबाएँ।\n\n5. इसे अपने पसंदीदा AI टूल में पेस्ट करें।\n\n6. दिल के आइकन से प्रॉम्प्ट सेव करें।\n\n7. सेटिंग्स में भाषा और रूप बदलें।\n\nPromptGo के लिए इंटरनेट आवश्यक है।',
    'Bengali':'১. হোম স্ক্রিনে প্রম্পট কার্ড দেখুন।\n\n২. অনুসন্ধান বা বিভাগ ব্যবহার করে প্রম্পট খুঁজুন।\n\n৩. ছবি ও লেখা দেখতে কার্ডে চাপ দিন।\n\n৪. লেখা প্রস্তুত হলে কপি চাপুন।\n\n৫. আপনার পছন্দের AI টুলে লেখাটি ব্যবহার করুন।\n\n৬. হার্ট আইকনে প্রম্পট সংরক্ষণ করুন।\n\n৭. সেটিংসে ভাষা ও চেহারা পরিবর্তন করুন।\n\nPromptGo ব্যবহার করতে ইন্টারনেট প্রয়োজন।',
  };
  return guide[promptGoLanguage.value] ?? guide['English']!;
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
  final savedAccent = prefs.getInt('promptgo_accent');
  if (savedAccent != null) promptGoAccent.value = Color(savedAccent);
  try {
    await FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance.subscribeToTopic('promptgo_new_posts');
  } catch (_) {}
  runApp(const PromptGoUser());
}

class PromptGoUser extends StatelessWidget {
  const PromptGoUser({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: Listenable.merge([promptGoThemeMode, promptGoLanguage, promptGoAccent]), builder: (context, _) => MaterialApp(
    title: 'PromptGo',
    debugShowCheckedModeBanner: false,
    themeMode: promptGoThemeMode.value,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: promptGoAccent.value), scaffoldBackgroundColor: const Color(0xfff7f7fa), pageTransitionsTheme: const PageTransitionsTheme(builders: {TargetPlatform.android: ZoomPageTransitionsBuilder(), TargetPlatform.iOS: CupertinoPageTransitionsBuilder(), TargetPlatform.windows: ZoomPageTransitionsBuilder(), TargetPlatform.linux: ZoomPageTransitionsBuilder(), TargetPlatform.macOS: CupertinoPageTransitionsBuilder()})),
    darkTheme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: promptGoAccent.value, brightness: Brightness.dark), scaffoldBackgroundColor: const Color(0xff101014), pageTransitionsTheme: const PageTransitionsTheme(builders: {TargetPlatform.android: ZoomPageTransitionsBuilder(), TargetPlatform.iOS: CupertinoPageTransitionsBuilder(), TargetPlatform.windows: ZoomPageTransitionsBuilder(), TargetPlatform.linux: ZoomPageTransitionsBuilder(), TargetPlatform.macOS: CupertinoPageTransitionsBuilder()})),
    builder: (context, child) => Directionality(textDirection: promptGoIsRtl ? TextDirection.rtl : TextDirection.ltr, child: child ?? const SizedBox.shrink()),
    home: const PromptGoSplash(),
  ));
}

class PromptGoSplash extends StatefulWidget {
  const PromptGoSplash({super.key});
  @override
  State<PromptGoSplash> createState() => _PromptGoSplashState();
}
class _PromptGoSplashState extends State<PromptGoSplash> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
  late final Animation<double> _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnlineGate()));
    });
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(body: Center(child: AnimatedBuilder(animation: _controller, builder: (context, _) => FadeTransition(opacity: _fade, child: ScaleTransition(scale: _scale, child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.primaryContainer, boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: .25), blurRadius: 35, spreadRadius: 5)]), child: ColorFiltered(colorFilter: ColorFilter.mode(dark ? Colors.white : Colors.transparent, BlendMode.difference), child: Image.asset('assets/sp.png', width: 138, height: 138, fit: BoxFit.contain))),
      const SizedBox(height: 22),
      const Text('PromptGo', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: .5)),
      const SizedBox(height: 7),
      Text('IDEAS INTO ACTION', style: TextStyle(letterSpacing: 3, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      const SizedBox(height: 30), SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5)),
    ])))));
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
  int _itemsToShow = 10;

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
    return WillPopScope(onWillPop: () async {
      final leave = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Exit PromptGo?'), content: const Text('Do you want to close the app?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Exit'))]));
      if (leave == true) SystemNavigator.pop();
      return false;
    }, child: Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Row(children: [ColorFiltered(colorFilter: ColorFilter.mode(Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.transparent, BlendMode.difference), child: Image.asset('assets/sp.png', width: 30, height: 30, fit: BoxFit.contain)), const SizedBox(width: 9), const Text('PromptGo', style: TextStyle(fontWeight: FontWeight.w900))]),
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

          final shownCount = visible.length < _itemsToShow ? visible.length : _itemsToShow;
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
                  itemCount: shownCount,
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
            if (visible.length > _itemsToShow) Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 28), child: FilledButton.icon(onPressed: () => setState(() => _itemsToShow += 10), icon: const Icon(Icons.expand_more_rounded), label: const Text('Load 10 more prompts'))),
          ]));
        },
      ),
    ));
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
    UserAccountsDrawerHeader(margin: EdgeInsets.zero, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, image: const DecorationImage(image: AssetImage('assets/caver.JPG'), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken))), accountName: const Text('PromptGo', style: TextStyle(fontWeight: FontWeight.w900)), accountEmail: const Text('AI Prompt Library'), currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: ColorFiltered(colorFilter: ColorFilter.mode(Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.transparent, BlendMode.difference), child: Image.asset('assets/sp.png', width: 42, height: 42, fit: BoxFit.contain)))),
    ListTile(leading: const Icon(Icons.settings_outlined), title: Text(pg('Settings')), subtitle: Text(pg('Theme and app preferences')), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())); }),
    ListTile(leading: const Icon(Icons.palette_outlined), title: Text(pg('Appearance')), subtitle: Text(pg('Light') + ' • ' + pg('Dark') + ' • ' + pg('Automatic')), onTap: () { Navigator.pop(context); _showThemePicker(context); }),
    ListTile(leading: const Icon(Icons.favorite_outline), title: Text(pg('Favorites')), onTap: () { Navigator.pop(context); setState(() => showFavoritesOnly = !showFavoritesOnly); }),
    const Divider(),
    ListTile(leading: const Icon(Icons.person_outline), title: Text(pg('Creator info')), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatorInfoPage())); }),
    ListTile(leading: const Icon(Icons.star_outline), title: Text(pg('Rate app')), onTap: () async { Navigator.pop(context); await launchUrl(Uri.parse('https://play.google.com/store/search?q=PromptGo&c=apps'), mode: LaunchMode.externalApplication); }),
    ListTile(leading: const Icon(Icons.share_outlined), title: Text(pg('Share app')), onTap: () { Navigator.pop(context); Share.share('Try PromptGo — an AI prompt library for creative ideas.'); }),
    ListTile(leading: const Icon(Icons.info_outline), title: Text(pg('About')), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPromptGoPage())); }),
    ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: const Text('Privacy Policy'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())); }),
    const Divider(),
    ListTile(leading: const Icon(Icons.exit_to_app), title: Text(pg('Exit')), onTap: () async { Navigator.pop(context); final leave = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Exit PromptGo?'), content: const Text('Do you want to close the app?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Exit'))])); if (leave == true) SystemNavigator.pop(); }),
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
    Center(child: ColorFiltered(colorFilter: ColorFilter.mode(Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.transparent, BlendMode.difference), child: Image.asset('assets/sp.png', width: 76, height: 76))),
    const SizedBox(height: 10),
    const Center(child: Text('PromptGo', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900))),
    const SizedBox(height: 20),
    Text(pg('App guide'), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
    const SizedBox(height: 12),
    Text(pgGuide()),
    const SizedBox(height: 18),
    StreamBuilder<DatabaseEvent>(stream: FirebaseDatabase.instance.ref('appInfo/creator').onValue, builder: (context, snap) {
      final raw = snap.data?.snapshot.value;
      if (raw is! Map) return const SizedBox.shrink();
      final d = Map<dynamic,dynamic>.from(raw);
      final name = (d['name'] ?? '').toString();
      if (name.isEmpty) return const SizedBox.shrink();
      return Card(child: ListTile(leading: const Icon(Icons.person_outline), title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text((d['bio'] ?? '').toString(), maxLines: 3, overflow: TextOverflow.ellipsis)));
    }),
    const SizedBox(height: 12),
    const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w800)),
    const Text('PromptGo uses Firebase to display online prompts and app information. It does not provide offline access. Notifications are optional and can be disabled in Android settings.'),
    const SizedBox(height: 14), const Text('Version 1.0.0 • Ideas into action', style: TextStyle(fontWeight: FontWeight.w700)),
  ]));
}
class CreatorInfoPage extends StatelessWidget {
  const CreatorInfoPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(pg('Creator info'))), body: StreamBuilder<DatabaseEvent>(
    stream: FirebaseDatabase.instance.ref('appInfo/creator').onValue,
    builder: (context, snap) {
      final raw = snap.data?.snapshot.value;
      final d = raw is Map ? Map<dynamic,dynamic>.from(raw) : <dynamic,dynamic>{};
      final name = (d['name'] ?? 'Sayed Safi').toString();
      final bio = (d['bio'] ?? 'PromptGo creator').toString();
      final image = (d['imageUrl'] ?? '').toString();
      final email = (d['email'] ?? 'noorrahmansayede07@gmail.com').toString();
      final whatsapp = (d['whatsapp'] ?? '+93744864493').toString();
      final extra = (d['extraContact'] ?? '').toString();
      return ListView(padding: const EdgeInsets.all(22), children: [
        Center(child: ClipRRect(borderRadius: BorderRadius.circular(100), child: image.isNotEmpty ? Image.network(image, width: 150, height: 150, fit: BoxFit.cover, errorBuilder: (_,__,___) => Image.asset('assets/admin.JPG',width:150,height:150,fit:BoxFit.cover)) : Image.asset('assets/admin.JPG', width: 150, height: 150, fit: BoxFit.cover))),
        const SizedBox(height: 18),
        Center(child: Text(name, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900))),
        const SizedBox(height: 14), Text(bio),
        const SizedBox(height: 24),
        if (email.isNotEmpty) Card(child: ListTile(leading: const Icon(Icons.email_outlined), title: const Text('Email'), subtitle: Text(email), onTap: () => launchUrl(Uri.parse('mailto:$email')))),
        if (whatsapp.isNotEmpty) Card(child: ListTile(leading: const Icon(Icons.chat_outlined), title: const Text('WhatsApp'), subtitle: Text(whatsapp), onTap: () => launchUrl(Uri.parse('https://wa.me/${whatsapp.replaceAll(RegExp(r'[^0-9]'), '')}'), mode: LaunchMode.externalApplication))),
        if (extra.isNotEmpty) Card(child: ListTile(leading: const Icon(Icons.contact_phone_outlined), title: const Text('Other contact'), subtitle: Text(extra))),
      ]);
    },
  ));
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


class OnlineGate extends StatelessWidget {
  const OnlineGate({super.key});
  Future<Map<String,dynamic>?> _requiredUpdate() async {
    final snap = await FirebaseDatabase.instance.ref('appUpdate').get();
    if (snap.value is! Map) return null;
    final data = Map<dynamic,dynamic>.from(snap.value as Map);
    if (data['forceUpdate'] != true) return null;
    final info = await PackageInfo.fromPlatform();
    int compare(String a, String b) {
      final aa = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final bb = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      for (var i=0;i<3;i++) { final x=i<aa.length?aa[i]:0; final y=i<bb.length?bb[i]:0; if(x!=y) return x.compareTo(y); }
      return 0;
    }
    final latest = (data['version'] ?? '1.0.0').toString();
    return compare(info.version, latest) < 0 ? data.map((k,v) => MapEntry(k.toString(),v)) : null;
  }
  @override
  Widget build(BuildContext context) => StreamBuilder<DatabaseEvent>(
    stream: FirebaseDatabase.instance.ref('.info/connected').onValue,
    builder: (context, connection) {
      if (connection.data?.snapshot.value != true) return Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_rounded, size: 64), const SizedBox(height: 16),
        const Text('Internet connection required', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
        const SizedBox(height: 8), const Text('PromptGo works online only. Connect to the internet and try again.', textAlign: TextAlign.center),
        const SizedBox(height: 20), const CircularProgressIndicator(),
      ]))));
      return FutureBuilder<Map<String,dynamic>?>(future: _requiredUpdate(), builder: (context, update) {
        if (update.connectionState != ConnectionState.done) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (update.hasError) return const Scaffold(body: Center(child: Text('Could not check app version. Please reconnect.')));
        if (update.data != null) return ForceUpdatePage(update: update.data!);
        return const PromptLibrary();
      });
    },
  );
}

class ForceUpdatePage extends StatelessWidget {
  final Map<String,dynamic> update;
  const ForceUpdatePage({super.key, required this.update});
  @override
  Widget build(BuildContext context) {
    final url = (update['apkUrl'] ?? '').toString();
    return PopScope(canPop: false, child: Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.system_update_alt_rounded, size: 76), const SizedBox(height: 18),
      const Text('Update required', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10), Text('Version ${update['version'] ?? ''} is required to continue.', textAlign: TextAlign.center),
      if ((update['releaseNotes'] ?? '').toString().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(update['releaseNotes'].toString(), textAlign: TextAlign.center)),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: url.startsWith('https://') ? () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication) : null, icon: const Icon(Icons.download_rounded), label: const Text('Download update'))),
    ]))));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(pg('Settings'))), body: ListView(padding: const EdgeInsets.all(16), children: [
    Text(pg('Language'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
    const SizedBox(height: 8),
    ...promptGoLanguages.map((language) => RadioListTile<String>(value: language, groupValue: promptGoLanguage.value, title: Text(language), onChanged: (value) async { if (value != null) { promptGoLanguage.value=value; final p=await SharedPreferences.getInstance(); await p.setString('promptgo_language',value); } })),
    const Divider(height: 30),
    Text(pg('Appearance'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
    for (final item in <MapEntry<ThemeMode,String>>[MapEntry(ThemeMode.system,pg('Automatic')),MapEntry(ThemeMode.light,pg('Light')),MapEntry(ThemeMode.dark,pg('Dark'))])
      RadioListTile<ThemeMode>(value:item.key,groupValue:promptGoThemeMode.value,title:Text(item.value),onChanged:(v) async { if(v!=null){promptGoThemeMode.value=v; final p=await SharedPreferences.getInstance(); await p.setString('promptgo_theme',v.name);} }),
    const Divider(height: 30),
    const Text('Accent color', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
    const SizedBox(height: 12),
    Wrap(spacing: 14, children: [
      for (final c in <Color>[const Color(0xff6750a4),const Color(0xff1565c0),const Color(0xff00897b),const Color(0xffef6c00)])
        GestureDetector(onTap: () async { promptGoAccent.value=c; final p=await SharedPreferences.getInstance(); await p.setInt('promptgo_accent',c.value); }, child: CircleAvatar(radius: 23, backgroundColor:c, child: promptGoAccent.value.value==c.value?const Icon(Icons.check,color:Colors.white):null)),
    ]),
    const SizedBox(height: 24),
    ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: const Text('Privacy Policy'), onTap: () => Navigator.push(context,MaterialPageRoute(builder:(_)=>const PrivacyPolicyPage()))),
    ListTile(leading: const Icon(Icons.info_outline), title: Text(pg('About')), onTap: () => Navigator.push(context,MaterialPageRoute(builder:(_)=>const AboutPromptGoPage()))),
  ]));
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Privacy Policy')), body: ListView(padding: const EdgeInsets.all(20), children: const [
    Text('PromptGo Privacy Policy', style: TextStyle(fontSize: 24,fontWeight:FontWeight.w900)),
    SizedBox(height: 14),
    Text('PromptGo connects to Firebase to retrieve prompt posts, creator information and update information. The app requires an internet connection and does not offer offline browsing.'),
    SizedBox(height: 12),
    Text('Data: Favorites and appearance preferences are stored on your device. Firebase may process technical data required to provide database and notification services.'),
    SizedBox(height: 12),
    Text('Notifications: PromptGo may ask permission to send notifications about new prompts. You can disable notifications at any time in Android system settings.'),
    SizedBox(height: 12),
    Text('Contacts: If you choose to contact the creator, your device opens the relevant email or messaging app. PromptGo does not send messages on your behalf.'),
    SizedBox(height: 12),
    Text('Children: PromptGo is not designed to collect personal information from children.'),
    SizedBox(height: 12),
    Text('Changes: This policy may be updated when app features change.'),
    SizedBox(height: 12),
    Text('Contact: noorrahmansayede07@gmail.com'),
  ]));
}
