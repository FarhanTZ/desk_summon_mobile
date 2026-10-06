import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase dengan kredensial project
  await Supabase.initialize(
    url: 'https://yfoigkrmqwtbrkkptgad.supabase.co',
    anonKey: 'sb_publishable_vk6p3LJQkahLPkz4SeUaGQ_ezfXeQZc',
  );

  runApp(const DeskSummonApp());
}

class DeskSummonApp extends StatelessWidget {
  const DeskSummonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desk Summon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class TaskItem {
  final String id;
  final String title;
  final String category;
  final String url;
  final bool openVSCode;
  bool isCompleted;

  TaskItem({
    required this.id,
    required this.title,
    required this.category,
    required this.url,
    required this.openVSCode,
    this.isCompleted = false,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = false;

  // Daftar Task / Todo List
  final List<TaskItem> _tasks = [
    TaskItem(
      id: '1',
      title: 'Belajar IELTS Writing Task 2 & Reading',
      category: '📖 IELTS',
      url: 'https://ieltsliz.com',
      openVSCode: false,
    ),
    TaskItem(
      id: '2',
      title: 'Coding Backend Desk Summon (Go)',
      category: '💻 Coding',
      url: 'https://github.com/FarhanTZ/desk-summon-backend',
      openVSCode: true,
    ),
    TaskItem(
      id: '3',
      title: 'Tulis Resume & Dokumen Project',
      category: '📄 Docs',
      url: 'https://docs.google.com',
      openVSCode: false,
    ),
    TaskItem(
      id: '4',
      title: 'Nonton Tutorial AI / Kuliah Online',
      category: '📺 Video',
      url: 'https://www.youtube.com/results?search_query=lofi+study+music',
      openVSCode: false,
    ),
  ];

  // Stream data realtime dari baris id = 1
  final _sessionStream = Supabase.instance.client
      .from('current_session')
      .stream(primaryKey: ['id'])
      .eq('id', 1);

  // Eksekusi / Summon task tertentu ke Laptop
  Future<void> _summonTask(TaskItem task) async {
    setState(() => _isLoading = true);
    try {
      await supabase.from('current_session').update({
        'state': 'FOCUSING',
        'topic': task.title,
        'project_path': task.openVSCode ? '.' : null,
        'doc_url': task.url.isNotEmpty ? task.url : null,
        'started_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', 1);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚡ Summoning "${task.title}" ke Laptop!'),
            backgroundColor: const Color(0xFF0284C7),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal summon: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Dialog Tambah Task Baru
  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    String category = '📖 IELTS';
    bool openVSCode = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('➕ Tambah Target Belajar / Task', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nama Task / Topik',
                    labelStyle: TextStyle(color: Colors.white60),
                    hintText: 'Misal: Latihan IELTS Listening',
                    hintStyle: TextStyle(color: Colors.white24),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Kategori Workspace',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                  items: const [
                    DropdownMenuItem(value: '📖 IELTS', child: Text('📖 IELTS Prep')),
                    DropdownMenuItem(value: '💻 Coding', child: Text('💻 Coding / Project')),
                    DropdownMenuItem(value: '📄 Docs', child: Text('📄 Google Docs / Notes')),
                    DropdownMenuItem(value: '📺 Video', child: Text('📺 YouTube / Course')),
                    DropdownMenuItem(value: '🔗 Custom', child: Text('🔗 Custom Link')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() {
                        category = val;
                        if (val == '📖 IELTS' && urlController.text.isEmpty) {
                          urlController.text = 'https://ieltsliz.com';
                          openVSCode = false;
                        } else if (val == '📄 Docs' && urlController.text.isEmpty) {
                          urlController.text = 'https://docs.google.com';
                          openVSCode = false;
                        } else if (val == '💻 Coding') {
                          openVSCode = true;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'URL / Link Browser (Opsional)',
                    labelStyle: TextStyle(color: Colors.white60),
                    hintText: 'https://...',
                    hintStyle: TextStyle(color: Colors.white24),
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Buka VS Code juga di Laptop', style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: openVSCode,
                  activeColor: const Color(0xFF38BDF8),
                  onChanged: (val) {
                    setModalState(() => openVSCode = val ?? false);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: const Color(0xFF0F172A),
              ),
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) return;

                setState(() {
                  _tasks.add(TaskItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: title,
                    category: category,
                    url: urlController.text.trim(),
                    openVSCode: openVSCode,
                  ));
                });
                Navigator.pop(ctx);
              },
              child: const Text('Simpan Task', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _giveUpToday() async {
    setState(() => _isLoading = true);
    try {
      await supabase.from('current_session').update({
        'state': 'SURRENDERED',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', 1);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi selesai. Istirahat tanpa rasa bersalah!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ Desk Summon Remote', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        backgroundColor: const Color(0xFF38BDF8),
        foregroundColor: const Color(0xFF0F172A),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Task', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kartu Status Realtime dari Laptop
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _sessionStream,
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  final state = (data != null && data.isNotEmpty)
                      ? data.first['state'] ?? 'IDLE'
                      : 'IDLE';
                  final topic = (data != null && data.isNotEmpty)
                      ? data.first['topic'] ?? '-'
                      : '-';

                  Color badgeColor = Colors.grey;
                  if (state == 'FOCUSING') badgeColor = Colors.greenAccent;
                  if (state == 'SURRENDERED') badgeColor = Colors.orangeAccent;

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('STATUS WORKSPACE LAPTOP',
                                style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1.2)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                state,
                                style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          state == 'FOCUSING' ? '🔥 Lagi Fokus: $topic' : '💤 Laptop Siaga (Idle)',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🎯 TARGET & TODO LIST HARI INI',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1),
                  ),
                  Text(
                    '${_tasks.where((t) => t.isCompleted).length}/${_tasks.length} Selesai',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF38BDF8)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Daftar Todo List
              Expanded(
                child: ListView.separated(
                  itemCount: _tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: task.isCompleted ? Colors.white10 : Colors.white24,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Checkbox Selesai
                          IconButton(
                            icon: Icon(
                              task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: task.isCompleted ? Colors.greenAccent : Colors.white38,
                            ),
                            onPressed: () {
                              setState(() => task.isCompleted = !task.isCompleted);
                            },
                          ),
                          const SizedBox(width: 4),
                          // Detail Task
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        task.category,
                                        style: const TextStyle(fontSize: 10, color: Color(0xFF38BDF8)),
                                      ),
                                    ),
                                    if (task.openVSCode) ...[
                                      const SizedBox(width: 6),
                                      const Text('💻 VS Code', style: TextStyle(fontSize: 10, color: Colors.white54)),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: task.isCompleted ? Colors.white38 : Colors.white,
                                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                if (task.url.isNotEmpty)
                                  Text(
                                    task.url,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11, color: Colors.white38),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Tombol Eksekusi / Summon Desk
                          ElevatedButton(
                            onPressed: _isLoading ? null : () => _summonTask(task),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF38BDF8),
                              foregroundColor: const Color(0xFF0F172A),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt, size: 16),
                                SizedBox(width: 2),
                                Text('Summon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Tombol Give Up
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : _giveUpToday,
                  child: const Text(
                    'Menyerah Hari Ini (Give Up)',
                    style: TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 60), // Beri ruang untuk Floating Action Button
            ],
          ),
        ),
      ),
    );
  }
}
