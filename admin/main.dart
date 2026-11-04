import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
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
    cardTheme: CardTheme(
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

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});
  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('prompts');
    return Scaffold(
      drawer: Drawer(child: SafeArea(child: ListView(padding: EdgeInsets.zero, children: [
        UserAccountsDrawerHeader(margin: EdgeInsets.zero, accountName: const Text('Admin Profile', style: TextStyle(fontWeight: FontWeight.w900)), accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? 'Admin account'), currentAccountPicture: const CircleAvatar(child: Icon(Icons.admin_panel_settings_rounded, size: 30))),
        ListTile(leading: const Icon(Icons.person_outline), title: const Text('Admin profile'), subtitle: Text('UID: ${FirebaseAuth.instance.currentUser?.uid ?? 'Unavailable'}')),
        ListTile(leading: const Icon(Icons.manage_accounts_outlined), title: const Text('App information & creator'), subtitle: const Text('Edit creator details and contacts'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminManagementPage())); }),
        ListTile(leading: const Icon(Icons.system_update_alt), title: const Text('App update'), subtitle: const Text('Publish a required user app update'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminManagementPage(initialTab: 1))); }),
        const ListTile(leading: Icon(Icons.info_outline), title: Text('PromptGo Admin'), subtitle: Text('Version 1.0.0')),
        ListTile(leading: const Icon(Icons.logout), title: const Text('Sign out'), onTap: () { Navigator.pop(context); FirebaseAuth.instance.signOut(); }),
      ]))),
      appBar: AppBar(title: const Text('PromptGo Admin', style: TextStyle(fontWeight: FontWeight.w900)), actions: [
        IconButton(tooltip: 'App settings', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminManagementPage())), icon: const Icon(Icons.settings_suggest_outlined)),
        IconButton(tooltip: 'Sign out', onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout)),
      ]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => editPrompt(context, ref), icon: const Icon(Icons.add), label: const Text('New prompt')),
      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('Database error: ${snapshot.error}')));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final raw = snapshot.data!.snapshot.value;
          if (raw is! Map || raw.isEmpty) return const Center(child: Text('No prompts yet. Tap New prompt to add one.'));
          final entries = raw.entries.toList();
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 9),
            itemBuilder: (context, index) {
              final entry = entries[index];
              if (entry.value is! Map) return const SizedBox.shrink();
              final id = entry.key.toString();
              final data = Map<dynamic, dynamic>.from(entry.value as Map);
              final title = (data['title'] ?? 'Untitled').toString();
              final category = (data['category'] ?? 'Video Prompt').toString();
              final imageUrl = (data['imageUrl'] ?? '').toString();
              return Card(child: ListTile(
                leading: imageUrl.isEmpty ? const CircleAvatar(child: Icon(Icons.image_outlined)) : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(imageUrl, width: 54, height: 54, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const CircleAvatar(child: Icon(Icons.broken_image_outlined)))),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('$category${data['isTrending'] == true ? ' • TRENDING' : ''}\n${data['content'] ?? ''}', maxLines: 3, overflow: TextOverflow.ellipsis),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') editPrompt(context, ref, id: id, old: data);
                    if (value == 'delete') deletePrompt(context, ref, id);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ));
            },
          );
        },
      ),
    );
  }
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
