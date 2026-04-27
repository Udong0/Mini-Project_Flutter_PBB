import 'package:flutter/material.dart';
import '../../models/glitch_model.dart';
import '../../services/database_helper.dart';
import '../widgets/glitch_card.dart';
import 'add_glitch_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Glitch> _glitches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshGlitches();
  }

  Future<void> _refreshGlitches() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.queryAllRows();
    setState(() {
      _glitches = data;
      _isLoading = false;
    });
  }

  void _deleteGlitch(int id) async {
    await DatabaseHelper.instance.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Glitch deleted!')),
    );
    _refreshGlitches();
  }

  void _backupToCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to backup.')),
      );
      return;
    }

    if (_glitches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No glitches to backup.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backing up to cloud...')),
    );

    try {
      await FirestoreService().backupGlitches(_glitches, user.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: \$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GLITCHDEX', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: 'Backup to Cloud',
            onPressed: _backupToCloud,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
          : _glitches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.radar,
                        size: 100,
                        color: Colors.greenAccent.withOpacity(0.5),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'NO ANOMALIES DETECTED',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                          fontFamily: 'Courier',
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Deploy your camera to capture glitches.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80, top: 8),
                  itemCount: _glitches.length,
                  itemBuilder: (context, index) {
                    final glitch = _glitches[index];
                    return GlitchCard(
                      glitch: glitch,
                      onDelete: () => _deleteGlitch(glitch.id!),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to add screen and wait for result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGlitchScreen()),
          );
          if (result == true) {
            _refreshGlitches(); // Refresh list if a new glitch was added
          }
        },
        icon: const Icon(Icons.document_scanner_outlined),
        label: const Text('SCAN GLITCH', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
    );
  }
}
