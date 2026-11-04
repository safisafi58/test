import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:flutter/cupertino.dart';

const options = FirebaseOptions(
  apiKey: 'AIzaSyBbLn0_NN2gghyaZpy2FPBCjUYz8LGUkgc',
  appId: '1:915531372851:android:0d4b4ae112f12390ce4646',
  messagingSenderId: '915531372851',
  projectId: 'romptgo',
  databaseURL: 'https://romptgo-default-rtdb.firebaseio.com',
  storageBucket: 'romptgo.firebasestorage.app',
);
const creatorSocialPlatforms = <String>['facebook', 'instagram', 'telegram', 'tiktok', 'youtube', 'x', 'linkedin', 'website'];

const promptCategories = <String>[
  'Video Prompt', 'Kids', 'DP Maker', 'Game', 'Cinematic', 'Anime & Cartoon',
  'Drawing and sketch', 'Photo Editing', 'Logo Design', 'Products',
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: options);
  runApp(const PromptGoAdmin());
}


ThemeData adminPromptGoTheme({required bool dark}) {
  final base = ColorScheme.fromSeed(
    seedColor: dark ? const Color(0xffa78bfa) : const Color(0xff7654df),
    brightness: dark ? Brightness.dark : Brightness.light,
  ).copyWith(
    tertiary: const Color(0xff00d4ff),
    surface: dark ? const Color(0xff15182b) : const Color(0xfffbfaff),
  );
  final glass = dark ? const Color(0xff252943).withValues(alpha: .76) : Colors.white.withValues(alpha: .84);
  final edge = dark ? const Color(0xff9b8cff).withValues(alpha: .25) : const Color(0xff8068df).withValues(alpha: .16);
  final radius = BorderRadius.circular(20);
  return ThemeData(
    useMaterial3: true,
    colorScheme: base,
    scaffoldBackgroundColor: dark ? const Color(0xff090b18) : const Color(0xfff2f1fb),
    cardColor: glass,
    cardTheme: CardThemeData(
      color: glass,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: edge)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: base.onSurface),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: glass,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: edge)),
      enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: edge)),
      focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: base.primary, width: 1.6)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: base.primary,
      foregroundColor: base.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    chipTheme: ChipThemeData(shape: const StadiumBorder(), side: BorderSide(color: edge), backgroundColor: glass, selectedColor: base.primaryContainer),
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: base.tertiary),
    dividerTheme: DividerThemeData(color: edge, thickness: 1),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: ZoomPageTransitionsBuilder(),
      TargetPlatform.linux: ZoomPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    }),
  );
}

class PromptGoAdmin extends StatelessWidget {
  const PromptGoAdmin({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PromptGo Admin',
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.system,
    theme: adminPromptGoTheme(dark: false),
    darkTheme: adminPromptGoTheme(dark: true),
    home: const AdminSplash(),
  );
}

class AdminSplash extends StatefulWidget {
  const AdminSplash({super.key});
  @override
  State<AdminSplash> createState() => _AdminSplashState();
}
class _AdminSplashState extends State<AdminSplash> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync:this,duration:const Duration(milliseconds:1500))..forward();
  late final Animation<double> scale = CurvedAnimation(parent:controller,curve:Curves.elasticOut);
  late final Animation<double> fade = CurvedAnimation(parent:controller,curve:Curves.easeIn);
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminGate()));
    });
  }
  @override
  void dispose(){controller.dispose();super.dispose();}
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: FadeTransition(opacity:fade,child:ScaleTransition(scale:scale,child:Column(mainAxisSize:MainAxisSize.min,children:[
    Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(shape:BoxShape.circle,color:Theme.of(context).colorScheme.primaryContainer,boxShadow:[BoxShadow(color:Theme.of(context).colorScheme.primary.withValues(alpha:.25),blurRadius:30,spreadRadius:4)]),child:Icon(Icons.auto_awesome_rounded,size:76,color:Theme.of(context).colorScheme.primary)),
    const SizedBox(height:18),
    const Text('PromptGo Admin',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),
    const SizedBox(height:22),const SizedBox(width:26,height:26,child:CircularProgressIndicator(strokeWidth:2.5)),
  ])))));
}

class AdminGate extends StatelessWidget {
  const AdminGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      return snapshot.data == null ? const AdminLoginPage() : const AdminHome();
    },
  );
}

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});
  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}
class _AdminLoginPageState extends State<AdminLoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool creating = false, busy = false, hidePassword = true;
  String? error;
  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }

  String readableError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found': return 'Email or password is incorrect.';
      case 'email-already-in-use': return 'This email already has an account. Sign in instead.';
      case 'weak-password': return 'Password must be at least 6 characters.';
      case 'invalid-email': return 'Please enter a valid email address.';
      case 'operation-not-allowed': return 'Enable Email/Password in Firebase Authentication settings.';
      case 'network-request-failed': return 'Network error. Check your internet connection.';
      case 'too-many-requests': return 'Too many attempts. Please try again later.';
      default: return '${e.message ?? e.code} (${e.code})';
    }
  }

  Future<void> submit() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      setState(() => error = 'Enter your email and password.');
      return;
    }
    setState(() { busy = true; error = null; });
    try {
      if (creating) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text.trim(), password: password.text,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text.trim(), password: password.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => error = readableError(e));
    } catch (e) {
      if (mounted) setState(() => error = 'Sign-in failed: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> resetPassword() async {
    if (email.text.trim().isEmpty) {
      setState(() => error = 'Enter your email first, then tap Forgot password.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
      if (mounted) setState(() => error = 'Password reset email sent. Check your inbox.');
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => error = readableError(e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.admin_panel_settings_rounded, size: 68, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 18),
          Text(creating ? 'Create Admin Account' : 'Admin Sign In', textAlign: TextAlign.center, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(creating ? 'Create your account to manage PromptGo.' : 'Sign in to manage your prompt library.', textAlign: TextAlign.center),
          const SizedBox(height: 28),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, autocorrect: false, decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder())),
          const SizedBox(height: 14),
          TextField(controller: password, obscureText: hidePassword, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(), suffixIcon: IconButton(onPressed: () => setState(() => hidePassword = !hidePassword), icon: Icon(hidePassword ? Icons.visibility : Icons.visibility_off)))),
          if (error != null) Padding(padding: const EdgeInsets.only(top: 14), child: Text(error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600))),
          const SizedBox(height: 18),
          FilledButton(onPressed: busy ? null : submit, child: busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(creating ? 'Create account' : 'Sign in')),
          if (!creating) TextButton(onPressed: busy ? null : resetPassword, child: const Text('Forgot password?')),
          TextButton(onPressed: busy ? null : () => setState(() { creating = !creating; error = null; }), child: Text(creating ? 'Already have an account? Sign in' : 'First time? Create admin account')),
          const SizedBox(height: 8),
          const Text('Firebase Authentication must have Email/Password enabled.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ],
      )),
    )),
  );
}


class AdminAdsPage extends StatefulWidget {
  const AdminAdsPage({super.key});
  @override
  State<AdminAdsPage> createState() => _AdminAdsPageState();
}
class _AdminAdsPageState extends State<AdminAdsPage> {
  final DatabaseReference adsRef = FirebaseDatabase.instance.ref('appAds');
  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final date = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (date == null || !mounted) return null;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
  Future<void> _editAd({String? id, Map<dynamic, dynamic>? old}) async {
    final title = TextEditingController(text: (old?['title'] ?? '').toString());
    final image = TextEditingController(text: (old?['imageUrl'] ?? '').toString());
    final description = TextEditingController(text: (old?['description'] ?? '').toString());
    final buttonText = TextEditingController(text: (old?['buttonText'] ?? 'Open').toString());
    final buttonUrl = TextEditingController(text: (old?['buttonUrl'] ?? '').toString());
    DateTime start = DateTime.fromMillisecondsSinceEpoch(old?['startAt'] is num ? (old!['startAt'] as num).toInt() : DateTime.now().millisecondsSinceEpoch);
    DateTime end = DateTime.fromMillisecondsSinceEpoch(old?['endAt'] is num ? (old!['endAt'] as num).toInt() : DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch);
    bool enabled = old?['enabled'] != false;
    String? error;
    String fmt(DateTime d) => '\${d.year.toString().padLeft(4,'0')}-\${d.month.toString().padLeft(2,'0')}-\${d.day.toString().padLeft(2,'0')}  \${d.hour.toString().padLeft(2,'0')}:\${d.minute.toString().padLeft(2,'0')}';
    await showDialog<void>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
      title: Text(id == null ? 'Create advertisement' : 'Edit advertisement'),
      content: SizedBox(width: 460, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Ad title (optional)', prefixIcon: Icon(Icons.title))),
        const SizedBox(height: 10),
        TextField(controller: image, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'Image URL *', prefixIcon: Icon(Icons.image_outlined))),
        const SizedBox(height: 10),
        TextField(controller: description, maxLines: 2, decoration: const InputDecoration(labelText: 'Description (optional)')),
        const SizedBox(height: 10),
        TextField(controller: buttonText, decoration: const InputDecoration(labelText: 'Button name *', prefixIcon: Icon(Icons.smart_button_outlined))),
        const SizedBox(height: 10),
        TextField(controller: buttonUrl, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'Button link URL *', prefixIcon: Icon(Icons.link))),
        const SizedBox(height: 14),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.schedule), title: const Text('Show from'), subtitle: Text(fmt(start)), trailing: IconButton(icon: const Icon(Icons.edit_calendar), onPressed: () async { final d = await _pickDateTime(start); if (d != null) setDialogState(() => start = d); })),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.event_available), title: const Text('Show until'), subtitle: Text(fmt(end)), trailing: IconButton(icon: const Icon(Icons.edit_calendar), onPressed: () async { final d = await _pickDateTime(end); if (d != null) setDialogState(() => end = d); })),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Advertisement enabled'), value: enabled, onChanged: (v) => setDialogState(() => enabled = v)),
        if (error != null) Align(alignment: Alignment.centerLeft, child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton.icon(onPressed: () async {
          final imageUri = Uri.tryParse(image.text.trim());
          final linkUri = Uri.tryParse(buttonUrl.text.trim());
          if (imageUri == null || !imageUri.hasScheme || !['http','https'].contains(imageUri.scheme) || linkUri == null || !linkUri.hasScheme || !['http','https'].contains(linkUri.scheme) || buttonText.text.trim().isEmpty) {
            setDialogState(() => error = 'Enter a valid image URL, button name and button link.');
            return;
          }
          if (!end.isAfter(start)) { setDialogState(() => error = 'End time must be after start time.'); return; }
          final data = <String, dynamic>{'title': title.text.trim(), 'imageUrl': image.text.trim(), 'description': description.text.trim(), 'buttonText': buttonText.text.trim(), 'buttonUrl': buttonUrl.text.trim(), 'startAt': start.millisecondsSinceEpoch, 'endAt': end.millisecondsSinceEpoch, 'enabled': enabled, 'updatedAt': ServerValue.timestamp};
          try {
            if (id == null) { data['createdAt'] = ServerValue.timestamp; await adsRef.push().set(data); }
            else { await adsRef.child(id).update(data); }
            if (dialogContext.mounted) Navigator.pop(dialogContext);
            if (mounted) ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Advertisement saved.')));
          } catch (e) { setDialogState(() => error = 'Could not save: $e'); }
        }, icon: const Icon(Icons.save_outlined), label: const Text('Save')),
      ],
    )));
    title.dispose(); image.dispose(); description.dispose(); buttonText.dispose(); buttonUrl.dispose();
  }
  Future<void> _deleteAd(String id) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete advertisement?'), content: const Text('This advertisement will be removed from the User app immediately.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete'))]));
    if (confirm == true) await adsRef.child(id).remove();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Advertisements')),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => _editAd(), icon: const Icon(Icons.add), label: const Text('New ad')),
    body: StreamBuilder<DatabaseEvent>(stream: adsRef.onValue, builder: (context, snapshot) {
      if (snapshot.hasError) return Center(child: Text('Database error: \${snapshot.error}'));
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final raw = snapshot.data!.snapshot.value;
      if (raw is! Map || raw.isEmpty) return const Center(child: Text('No advertisements yet. Tap New ad.'));
      final entries = raw.entries.where((e) => e.value is Map).toList();
      return ListView(padding: const EdgeInsets.fromLTRB(14, 12, 14, 90), children: [
        const Padding(padding: EdgeInsets.all(8), child: Text('Ads appear in the User app only while enabled and within their scheduled time.')),
        for (final entry in entries) Builder(builder: (context) {
          final id = entry.key.toString();
          final data = Map<dynamic,dynamic>.from(entry.value as Map);
          final startAt = data['startAt'] is num ? DateTime.fromMillisecondsSinceEpoch((data['startAt'] as num).toInt()) : null;
          final endAt = data['endAt'] is num ? DateTime.fromMillisecondsSinceEpoch((data['endAt'] as num).toInt()) : null;
          final now = DateTime.now();
          final active = data['enabled'] == true && startAt != null && endAt != null && !now.isBefore(startAt) && now.isBefore(endAt);
          return Card(child: ListTile(
            leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network((data['imageUrl'] ?? '').toString(), width: 58, height: 58, fit: BoxFit.cover, errorBuilder: (_,__,___) => const SizedBox(width:58,height:58,child: Icon(Icons.image_not_supported)))),
            title: Text((data['title'] ?? 'Advertisement').toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('\${active ? 'LIVE NOW' : data['enabled'] == true ? 'Scheduled / inactive' : 'Disabled'}\\n\${startAt == null ? '' : startAt.toLocal()} → \${endAt == null ? '' : endAt.toLocal()}', maxLines: 3),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(onSelected: (v) {
              if (v == 'edit') _editAd(id: id, old: data);
              if (v == 'toggle') adsRef.child(id).update({'enabled': data['enabled'] != true});
              if (v == 'delete') _deleteAd(id);
            }, itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: ListTile(dense:true, leading: Icon(Icons.edit), title: Text('Edit'))),
              PopupMenuItem(value: 'toggle', child: ListTile(dense:true, leading: Icon(data['enabled'] == true ? Icons.pause : Icons.play_arrow), title: Text(data['enabled'] == true ? 'Disable' : 'Enable'))),
              const PopupMenuItem(value: 'delete', child: ListTile(dense:true, leading: Icon(Icons.delete_outline), title: Text('Delete'))),
            ]),
          ));
        }),
      ]);
    }),
  );
}

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('prompts');
    return Scaffold(
      drawer: Drawer(child: SafeArea(child: ListView(padding: EdgeInsets.zero, children: [
        UserAccountsDrawerHeader(
          margin: EdgeInsets.zero,
          accountName: const Text('Admin Profile', style: TextStyle(fontWeight: FontWeight.w900)),
          accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? 'Admin account'),
          currentAccountPicture: const CircleAvatar(child: Icon(Icons.admin_panel_settings_rounded, size: 30)),
        ),
        ListTile(leading: const Icon(Icons.person_outline), title: const Text('Admin profile'), subtitle: Text('UID: ${FirebaseAuth.instance.currentUser?.uid ?? 'Unavailable'}')),
        ListTile(leading: const Icon(Icons.campaign_outlined), title: const Text('Advertisements'), subtitle: const Text('Create, schedule, edit or remove ads'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAdsPage())); }),
        ListTile(leading: const Icon(Icons.manage_accounts_outlined), title: const Text('App information & creator'), subtitle: const Text('Edit creator details and contacts'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminManagementPage())); }),
        ListTile(leading: const Icon(Icons.telegram), title: const Text('Add Telegram post'), subtitle: const Text('Import image and text from a public channel'), onTap: () { Navigator.pop(context); addTelegramPrompt(context, ref); }),
        ListTile(leading: const Icon(Icons.system_update_alt), title: const Text('App update'), subtitle: const Text('Publish a required user app update'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminManagementPage(initialTab: 1))); }),
        const ListTile(leading: Icon(Icons.info_outline), title: Text('PromptGo Admin'), subtitle: Text('Version 1.0.0')),
        ListTile(leading: const Icon(Icons.logout), title: const Text('Sign out'), onTap: () { Navigator.pop(context); FirebaseAuth.instance.signOut(); }),
      ]))),
      appBar: AppBar(
        title: const Text('PromptGo Admin', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(tooltip: 'Advertisements', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAdsPage())), icon: const Icon(Icons.campaign_outlined)),
          IconButton(tooltip: 'Add Telegram post', onPressed: () => addTelegramPrompt(context, ref), icon: const Icon(Icons.telegram)),
          IconButton(tooltip: 'App settings', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminManagementPage())), icon: const Icon(Icons.settings_suggest_outlined)),
          IconButton(tooltip: 'Sign out', onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => editPrompt(context, ref), icon: const Icon(Icons.add), label: const Text('New prompt')),
      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('Database error: ${snapshot.error}')));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final raw = snapshot.data!.snapshot.value;
          if (raw is! Map || raw.isEmpty) return const Center(child: Text('No prompts yet. Tap New prompt to add one.'));

          final grouped = <String, List<Map<String, dynamic>>>{};
          for (final entry in raw.entries) {
            if (entry.value is! Map) continue;
            final data = Map<dynamic, dynamic>.from(entry.value as Map);
            final category = (data['category'] ?? 'Video Prompt').toString();
            grouped.putIfAbsent(category, () => <Map<String, dynamic>>[]).add({
              'id': entry.key.toString(),
              'data': data,
              'title': (data['title'] ?? 'Untitled').toString(),
              'imageUrl': (data['imageUrl'] ?? '').toString(),
              'content': (data['content'] ?? '').toString(),
              'isTrending': data['isTrending'] == true,
            });
          }
          if (grouped.isEmpty) return const Center(child: Text('No prompts yet. Tap New prompt to add one.'));
          for (final posts in grouped.values) {
            posts.sort((a, b) => a['title'].toString().toLowerCase().compareTo(b['title'].toString().toLowerCase()));
          }
          final categories = <String>[
            ...promptCategories.where(grouped.containsKey),
            ...grouped.keys.where((category) => !promptCategories.contains(category)).toList()..sort(),
          ];

          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                child: Text(
                  '${grouped.values.fold<int>(0, (total, posts) => total + posts.length)} posts • ${categories.length} categories',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700),
                ),
              ),
              for (final category in categories)
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    initiallyExpanded: false,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(Icons.category_outlined, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(category, style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text('${grouped[category]!.length} posts'),
                    children: [
                      const Divider(height: 1),
                      for (final post in grouped[category]!)
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          leading: post['imageUrl'].toString().isEmpty
                              ? const CircleAvatar(child: Icon(Icons.image_outlined))
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: Image.network(
                                    post['imageUrl'].toString(),
                                    width: 54,
                                    height: 54,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const CircleAvatar(child: Icon(Icons.broken_image_outlined)),
                                  ),
                                ),
                          title: Text(
                            post['title'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${post['isTrending'] == true ? 'TRENDING • ' : ''}${post['content']}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: PopupMenuButton<String>(
                            tooltip: 'Manage post',
                            onSelected: (value) {
                              final id = post['id'].toString();
                              final data = post['data'] as Map<dynamic, dynamic>;
                              if (value == 'edit') editPrompt(context, ref, id: id, old: data);
                              if (value == 'delete') deletePrompt(context, ref, id);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: ListTile(dense: true, leading: Icon(Icons.edit_outlined), title: Text('Edit'))),
                              PopupMenuItem(value: 'delete', child: ListTile(dense: true, leading: Icon(Icons.delete_outline), title: Text('Delete'))),
                            ],
                          ),
                        ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Imports a post from a PUBLIC Telegram channel and saves its photo and caption
/// into the same Firebase fields used by regular prompts. The channel name is
/// deliberately not stored as a display title or shown in the user app.
Future<void> addTelegramPrompt(BuildContext context, DatabaseReference ref) async {
  final link = TextEditingController();
  final title = TextEditingController();
  String category = promptCategories.first;
  bool trending = false;
  bool busy = false;
  final formKey = GlobalKey<FormState>();

  String? parsePostPath(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) return null;
    if (uri.host != 't.me' && uri.host != 'www.t.me') return null;
    final parts = uri.pathSegments.where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    final offset = parts.first == 's' ? 1 : 0;
    if (parts.length < offset + 2) return null;
    final channel = parts[offset];
    final postId = parts[offset + 1];
    if (channel.isEmpty || int.tryParse(postId) == null) return null;
    return '$channel/$postId';
  }

  await showDialog<void>(
    context: context,
    barrierDismissible: !busy,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.telegram, color: Color(0xff229ED9)),
          SizedBox(width: 10),
          Expanded(child: Text('Add Telegram post')),
        ]),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Paste a post link from a public Telegram channel. PromptGo will import its photo and caption.', style: TextStyle(height: 1.4)),
                const SizedBox(height: 14),
                TextFormField(
                  controller: link,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(labelText: 'Telegram post link', hintText: 'https://t.me/channel/123', prefixIcon: Icon(Icons.link)),
                  validator: (v) => parsePostPath(v ?? '') == null ? 'Enter a valid public Telegram post link' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(controller: title, decoration: const InputDecoration(labelText: 'Display title', hintText: 'Optional title')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: promptCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) { if (v != null) setDialogState(() => category = v); },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mark as Trending'),
                  subtitle: const Text('Show this post in the Trending section'),
                  value: trending,
                  onChanged: (v) => setDialogState(() => trending = v),
                ),
                if (busy) const Padding(padding: EdgeInsets.only(top: 16), child: LinearProgressIndicator()),
              ]),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: busy ? null : () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton.icon(
            onPressed: busy ? null : () async {
              if (!formKey.currentState!.validate()) return;
              setDialogState(() => busy = true);
              try {
                final path = parsePostPath(link.text)!;
                // Request the exact Telegram post, not the channel feed.
                final embedUri = Uri.parse('https://t.me/$path?embed=1&mode=tme');
                final response = await http.get(embedUri, headers: const {
                  'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120.0 Mobile Safari/537.36',
                }).timeout(const Duration(seconds: 20));
                if (response.statusCode != 200) {
                  throw Exception('Telegram could not open this post. Check that the channel is public.');
                }
                final document = html_parser.parse(response.body);
                final postElement = document.querySelector('.tgme_widget_message_wrap[data-post="$path"]')
                    ?? document.querySelector('.tgme_widget_message');
                if (postElement == null) {
                  throw Exception('The exact Telegram post was not found. Copy the link directly from that photo post.');
                }
                final textElement = postElement.querySelector('.tgme_widget_message_text');
                final caption = (textElement?.text ?? '').trim();
                final photoElement = postElement.querySelector('.tgme_widget_message_photo_wrap');
                final photoStyle = photoElement?.attributes['style'] ?? '';
                final photoMatch = RegExp(r"""url\(['"]?(.*?)['"]?\)""").firstMatch(photoStyle);
                var photoUrl = photoMatch?.group(1) ?? '';
                if (photoUrl.isEmpty) {
                  photoUrl = postElement.querySelector('img.tgme_widget_message_photo')?.attributes['src'] ?? '';
                }
                if (photoUrl.isEmpty) {
                  photoUrl = document.querySelector('meta[property="og:image"]')?.attributes['content'] ?? '';
                }
                if (caption.isEmpty) {
                  throw Exception('No text was found in this Telegram post. Please use a post that contains the prompt text.');
                }
                if (!photoUrl.startsWith('https://')) {
                  throw Exception('No public photo was found in this Telegram post. Please check the link.');
                }
                final data = <String, Object>{
                  'title': title.text.trim().isEmpty ? (caption.split('\\n').first.trim().length > 60 ? caption.split('\\n').first.trim().substring(0, 60) : caption.split('\\n').first.trim()) : title.text.trim(),
                  'category': category,
                  'content': caption,
                  'imageUrl': photoUrl,
                  'sourceType': 'telegram',
                  'telegramUrl': link.text.trim(),
                  'isTrending': trending,
                  'createdAt': ServerValue.timestamp,
                  'updatedAt': ServerValue.timestamp,
                };
                await ref.push().set(data);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Telegram photo and prompt imported successfully.')));
              } catch (e) {
                if (dialogContext.mounted) {
                  setDialogState(() => busy = false);
                  ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Import failed: $e')));
                }
              }
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('Import post'),
          ),
        ],
      ),
    ),
  );
  link.dispose();
  title.dispose();
}

Future<void> editPrompt(BuildContext context, DatabaseReference ref, {String? id, Map<dynamic, dynamic>? old}) async {
  final title = TextEditingController(text: (old?['title'] ?? '').toString());
  final content = TextEditingController(text: (old?['content'] ?? '').toString());
  final imageUrl = TextEditingController(text: (old?['imageUrl'] ?? '').toString());
  String category = promptCategories.contains(old?['category']) ? old!['category'].toString() : promptCategories.first;
  bool trending = old?['isTrending'] == true;
  final formKey = GlobalKey<FormState>();
  await showDialog<void>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (dialogContext, setDialogState) => AlertDialog(
    title: Text(id == null ? 'Create prompt' : 'Edit prompt'),
    content: SizedBox(width: 440, child: SingleChildScrollView(child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextFormField(controller: title, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v == null || v.trim().isEmpty ? 'Enter a title' : null),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: category,
        decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
        items: promptCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (v) { if (v != null) setDialogState(() => category = v); },
      ),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Mark as Trending'), value: trending, onChanged: (v) => setDialogState(() => trending = v)),
      TextFormField(controller: imageUrl, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'Image URL (https://...)', prefixIcon: Icon(Icons.link), border: OutlineInputBorder()), validator: (v) { final value = (v ?? '').trim(); final uri = Uri.tryParse(value); return value.isEmpty || uri == null || !uri.hasScheme || !(uri.scheme == 'https' || uri.scheme == 'http') || uri.host.isEmpty ? 'Enter a valid image URL' : null; }),
      const SizedBox(height: 12),
      TextFormField(controller: content, minLines: 4, maxLines: 8, decoration: const InputDecoration(labelText: 'Prompt text'), validator: (v) => v == null || v.trim().isEmpty ? 'Enter prompt text' : null),
    ])))),
    actions: [
      TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
      FilledButton(onPressed: () async {
        if (!formKey.currentState!.validate()) return;
        final data = <String, Object>{
          'title': title.text.trim(),
          'category': category,
          'content': content.text.trim(),
          'imageUrl': imageUrl.text.trim(),
          'isTrending': trending,
          'createdAt': old?['createdAt'] ?? ServerValue.timestamp,
          'updatedAt': ServerValue.timestamp,
        };
        try {
          if (id == null) { await ref.push().set(data); } else { await ref.child(id).update(data); }
          if (dialogContext.mounted) Navigator.pop(dialogContext);
        } catch (e) {
          if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Save failed: $e')));
        }
      }, child: const Text('Save')),
    ],
  )));
  title.dispose();
  content.dispose();
  imageUrl.dispose();
}

Future<void> deletePrompt(BuildContext context, DatabaseReference ref, String id) async {
  final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
    title: const Text('Delete prompt?'),
    content: const Text('This prompt will be permanently removed.'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
      FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
    ],
  ));
  if (confirmed == true) await ref.child(id).remove();
}


class AdminManagementPage extends StatefulWidget {
  final int initialTab;
  const AdminManagementPage({super.key, this.initialTab = 0});
  @override
  State<AdminManagementPage> createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage> with SingleTickerProviderStateMixin {
  late final TabController tabs = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  @override
  void dispose() { tabs.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('App management'), bottom: TabBar(controller: tabs, tabs: const [Tab(icon: Icon(Icons.person_outline), text: 'Creator'), Tab(icon: Icon(Icons.system_update_alt), text: 'App update')])),
    body: TabBarView(controller: tabs, children: const [CreatorManagementTab(), UpdateManagementTab()]),
  );
}

class CreatorManagementTab extends StatelessWidget {
  const CreatorManagementTab({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<DatabaseEvent>(
    stream: FirebaseDatabase.instance.ref('appInfo/creator').onValue,
    builder: (context, snap) {
      final raw = snap.data?.snapshot.value;
      final d = raw is Map ? Map<dynamic,dynamic>.from(raw) : <dynamic,dynamic>{};
      return ListView(padding: const EdgeInsets.all(18), children: [
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
          CircleAvatar(radius: 42, backgroundImage: (d['imageUrl'] ?? '').toString().startsWith('http') ? NetworkImage(d['imageUrl'].toString()) : null, child: (d['imageUrl'] ?? '').toString().isEmpty ? const Icon(Icons.person, size: 42) : null),
          const SizedBox(height: 12),
          Text((d['name'] ?? 'Sayed Safi').toString(), style: const TextStyle(fontSize: 22,fontWeight:FontWeight.w900)),
          const SizedBox(height: 8), Text((d['bio'] ?? 'Add creator description').toString(), textAlign: TextAlign.center),
          const SizedBox(height: 8), Text((d['email'] ?? '').toString()), Text((d['whatsapp'] ?? '').toString()),
        ]))),
        const SizedBox(height: 14),
        FilledButton.icon(onPressed: () => editCreatorInfo(context,d), icon: const Icon(Icons.edit_outlined), label: const Text('Edit creator information')),
        const Padding(padding: EdgeInsets.only(top: 14), child: Text('These details appear in the User app About and Creator Info screens.')),
      ]);
    },
  );
}

Future<void> editCreatorInfo(BuildContext context, Map<dynamic,dynamic> old) async {
  final name = TextEditingController(text: (old['name'] ?? 'Sayed Safi').toString());
  final bio = TextEditingController(text: (old['bio'] ?? '').toString());
  final image = TextEditingController(text: (old['imageUrl'] ?? '').toString());
  final email = TextEditingController(text: (old['email'] ?? '').toString());
  final whatsapp = TextEditingController(text: (old['whatsapp'] ?? '').toString());
  final extra = TextEditingController(text: (old['extraContact'] ?? '').toString());
  final oldSocialRaw = old['socialLinks'];
  final oldSocial = oldSocialRaw is Map ? Map<dynamic, dynamic>.from(oldSocialRaw) : <dynamic, dynamic>{};
  final socialControllers = <String, TextEditingController>{
    for (final key in creatorSocialPlatforms)
      key: TextEditingController(text: oldSocial[key] is Map ? ((oldSocial[key] as Map)['url'] ?? '').toString() : ''),
  };
  final socialEnabled = <String, bool>{
    for (final key in creatorSocialPlatforms)
      key: oldSocial[key] is Map && (oldSocial[key] as Map)['enabled'] == true,
  };
  bool showEmail = old['showEmail'] != false;
  bool showWhatsApp = old['showWhatsApp'] != false;
  final key = GlobalKey<FormState>();
  bool uploading = false;
  await showDialog<void>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialog) => AlertDialog(
    title: const Text('Creator information'),
    content: SizedBox(width: 480, child: SingleChildScrollView(child: Form(key: key, child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Creator name'), validator: (v) => v == null || v.trim().isEmpty ? 'Enter a name' : null),
      TextFormField(controller: bio, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'Description / Bio')),
      TextFormField(controller: image, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'Profile image URL (or upload below)')),
      OutlinedButton.icon(
        onPressed: uploading ? null : () async {
          final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82, maxWidth: 1200);
          if (picked == null) return;
          setDialog(() => uploading = true);
          try {
            final fileRef = FirebaseStorage.instance.ref('creator/profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
            await fileRef.putFile(File(picked.path));
            image.text = await fileRef.getDownloadURL();
          } catch (e) {
            if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
          } finally {
            if (ctx.mounted) setDialog(() => uploading = false);
          }
        },
        icon: uploading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.photo_library_outlined),
        label: Text(uploading ? 'Uploading image...' : 'Choose and upload profile image'),
      ),
      const Divider(height: 28),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Show Email button in User app'), value: showEmail, onChanged: (v) => setDialog(() => showEmail = v)),
      TextFormField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address')),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Show WhatsApp button in User app'), value: showWhatsApp, onChanged: (v) => setDialog(() => showWhatsApp = v)),
      TextFormField(controller: whatsapp, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'WhatsApp number')),
      const Divider(height: 28),
      const Align(alignment: Alignment.centerLeft, child: Text('Social media buttons', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17))),
      const SizedBox(height: 8),
      for (final platform in creatorSocialPlatforms)
        Card(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), child: Column(children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Show ${platform[0].toUpperCase()}${platform.substring(1)} button'),
            value: socialEnabled[platform] ?? false,
            onChanged: (v) => setDialog(() => socialEnabled[platform] = v),
          ),
          TextFormField(
            controller: socialControllers[platform],
            keyboardType: TextInputType.url,
            decoration: InputDecoration(labelText: '${platform[0].toUpperCase()}${platform.substring(1)} URL (https://...)'),
          ),
        ]))),
      const SizedBox(height: 10),
      TextFormField(controller: extra, decoration: const InputDecoration(labelText: 'Other contact details')),
    ])))),
    actions: [
      TextButton(onPressed: uploading ? null : () => Navigator.pop(ctx), child: const Text('Cancel')),
      FilledButton(onPressed: uploading ? null : () async {
        if (!key.currentState!.validate()) return;
        try {
          await FirebaseDatabase.instance.ref('appInfo/creator').set({
            'name': name.text.trim(),
            'bio': bio.text.trim(),
            'imageUrl': image.text.trim(),
            'email': email.text.trim(),
            'whatsapp': whatsapp.text.trim(),
            'showEmail': showEmail,
            'showWhatsApp': showWhatsApp,
            'extraContact': extra.text.trim(),
            'socialLinks': {
              for (final platform in creatorSocialPlatforms)
                platform: {
                  'enabled': socialEnabled[platform] == true,
                  'url': socialControllers[platform]!.text.trim(),
                },
            },
            'updatedAt': ServerValue.timestamp,
          });
          if (ctx.mounted) Navigator.pop(ctx);
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Creator information saved.')));
        } catch (e) {
          if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Save failed: $e')));
        }
      }, child: const Text('Save')),
    ],
  )));
  name.dispose();
  bio.dispose();
  image.dispose();
  email.dispose();
  whatsapp.dispose();
  extra.dispose();
  for (final controller in socialControllers.values) {
    controller.dispose();
  }
}

class UpdateManagementTab extends StatelessWidget {
  const UpdateManagementTab({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<DatabaseEvent>(
    stream: FirebaseDatabase.instance.ref('appUpdate').onValue,
    builder:(context,snap){
      final raw=snap.data?.snapshot.value;
      final d=raw is Map?Map<dynamic,dynamic>.from(raw):<dynamic,dynamic>{};
      return ListView(padding:const EdgeInsets.all(18),children:[
        Card(child:ListTile(leading:const Icon(Icons.system_update_alt,size:34),title:Text('Version ${d['version']??'1.0.0'}',style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Text(d['forceUpdate']==true?'Mandatory update is enabled':'No mandatory update is currently active'))),
        const SizedBox(height:14),
        const Text('Publish a new version of the User app. To make it mandatory, enable the switch and provide a direct HTTPS APK link.',style:TextStyle(height:1.5)),
        const SizedBox(height:14),
        FilledButton.icon(onPressed:()=>editAppUpdate(context,d),icon:const Icon(Icons.publish),label:const Text('Configure / publish update')),
      ]);
    },
  );
}

Future<void> editAppUpdate(BuildContext context, Map<dynamic,dynamic> old) async {
  final version=TextEditingController(text:(old['version']??'1.0.1').toString());
  final apk=TextEditingController(text:(old['apkUrl']??'').toString());
  final notes=TextEditingController(text:(old['releaseNotes']??'').toString());
  bool force=old['forceUpdate']==true;
  final key=GlobalKey<FormState>();
  await showDialog<void>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,setDialog)=>AlertDialog(
    title:const Text('User app update'),
    content:SizedBox(width:460,child:SingleChildScrollView(child:Form(key:key,child:Column(mainAxisSize:MainAxisSize.min,children:[
      TextFormField(controller:version,decoration:const InputDecoration(labelText:'New app version (e.g. 1.0.2)'),validator:(v){final parts=(v??'').trim().split('.');return parts.length!=3||parts.any((part)=>part.isEmpty||int.tryParse(part)==null)?'Use format 1.0.2':null;}),
      TextFormField(controller:apk,keyboardType:TextInputType.url,decoration:const InputDecoration(labelText:'Direct APK HTTPS URL'),validator:(v)=>v==null||!v.trim().startsWith('https://')?'Enter an HTTPS APK URL':null),
      TextFormField(controller:notes,minLines:2,maxLines:4,decoration:const InputDecoration(labelText:'Release notes')),
      SwitchListTile(contentPadding:EdgeInsets.zero,value:force,onChanged:(v)=>setDialog(()=>force=v),title:const Text('Force update (block old versions)')),
    ])))),
    actions:[
      TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Cancel')),
      FilledButton(onPressed:() async {
        if(!key.currentState!.validate()) return;
        try {
          await FirebaseDatabase.instance.ref('appUpdate').set({'version':version.text.trim(),'apkUrl':apk.text.trim(),'releaseNotes':notes.text.trim(),'forceUpdate':force,'updatedAt':ServerValue.timestamp});
          if(ctx.mounted) Navigator.pop(ctx);
          if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Update settings published.')));
        } catch(e) { if(ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content:Text('Publish failed: $e'))); }
      },child:const Text('Publish')),
    ],
  )));
  version.dispose();apk.dispose();notes.dispose();
}
