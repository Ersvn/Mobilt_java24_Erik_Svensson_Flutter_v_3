import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FlutterMoodApp());
}

class FlutterMoodApp extends StatelessWidget {
  const FlutterMoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Mood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController textController = TextEditingController();

  String selectedMood = 'Glad';
  bool isSaving = false;

  Future<void> saveMood() async {
    final text = textController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skriv något först')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('moods').add({
        'text': text,
        'mood': selectedMood,
        'createdAt': FieldValue.serverTimestamp(),
      });

      textController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sparat i Firebase')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fel vid sparning: $error'),
          duration: const Duration(seconds: 8),
        ),
      );

      debugPrint('FIREBASE SAVE ERROR: $error');
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Mood'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  'https://images.unsplash.com/photo-1536420113339-670e1666cbdd?q=80&w=2564&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Hur mår du idag?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'Skriv en kort text, välj humör och spara det i Firebase.',
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: textController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Skriv något',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedMood,
                decoration: const InputDecoration(
                  labelText: 'Humör',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Glad', child: Text('Glad')),
                  DropdownMenuItem(value: 'Trött', child: Text('Trött')),
                  DropdownMenuItem(value: 'Stressad', child: Text('Stressad')),
                  DropdownMenuItem(value: 'Motiverad', child: Text('Motiverad')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedMood = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: isSaving ? null : saveMood,
                child: Text(isSaving ? 'Sparar...' : 'Spara'),
              ),
              const SizedBox(height: 8),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedMoodsPage(),
                    ),
                  );
                },
                child: const Text('Visa sparade humör'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SavedMoodsPage extends StatelessWidget {
  const SavedMoodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final moodStream = FirebaseFirestore.instance
        .collection('moods')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sparade humör'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: StreamBuilder<QuerySnapshot>(
            stream: moodStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Kunde inte hämta data.'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final moods = snapshot.data!.docs;

              if (moods.isEmpty) {
                return const Center(
                  child: Text('Inga sparade humör än.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: moods.length,
                itemBuilder: (context, index) {
                  final mood = moods[index].data() as Map<String, dynamic>;

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.favorite),
                      title: Text(mood['text'] ?? ''),
                      subtitle: Text('Humör: ${mood['mood'] ?? ''}'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}