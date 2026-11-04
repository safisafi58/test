import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

const options = FirebaseOptions(
  apiKey: 'AIzaSyBbLn0_NN2gghyaZpy2FPBCjUYz8LGUkgc',
  appId: '1:915531372851:android:0d4b4ae112f12390ce4646',
  messagingSenderId: '915531372851',
  projectId: 'romptgo',
  databaseURL: 'https://romptgo-default-rtdb.firebaseio.com',
);
const promptCategories = <String>[
  'Video Prompt', 'Kids', 'DP Maker', 'Game', 'Cinematic', 'Anime & Cartoon',
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: options);
  runApp(const PromptGoAdmin());
}

class PromptGoAdmin extends StatelessWidget {
  const PromptGoAdmin({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PromptGo Admin',
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.system,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff6750a4))),
    darkTheme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffb9a5ff), brightness: Brightness.dark)),
    home: const AdminSplash(),
  );
}

class AdminSplash extends StatefulWidget {
  const AdminSplash({super.key});
  @override
  State<AdminSplash> createState() => _AdminSplashState();
}
class _AdminSplashState extends State<AdminSplash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminGate()));
    });
  }
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.auto_awesome_rounded, size: 72), SizedBox(height: 12),
    Text('PromptGo Admin', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
    SizedBox(height: 20), CircularProgressIndicator(),
  ])));
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
      appBar: AppBar(title: const Text('PromptGo Admin', style: TextStyle(fontWeight: FontWeight.w900)), actions: [
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
