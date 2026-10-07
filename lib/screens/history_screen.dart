import 'dart:io';

import 'package:flutter/material.dart';

import '../models/history_item.dart';
import '../services/history_service.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _historyService = HistoryService();
  late Future<List<HistoryItem>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _historyFuture = _historyService.loadHistory();
  }

  Future<void> _clear() async {
    await _historyService.clearHistory();
    if (mounted) {
      setState(_reload);
    }
  }

  Future<void> _delete(String id) async {
    await _historyService.deleteItem(id);
    if (mounted) {
      setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            tooltip: 'Clear history',
            onPressed: _clear,
            icon: const Icon(Icons.delete_sweep_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<HistoryItem>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final history = snapshot.data ?? [];
            if (history.isEmpty) {
              return const _EmptyHistory();
            }

            return RefreshIndicator(
              onRefresh: () async => setState(_reload),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                itemBuilder: (context, index) {
                  final item = history[index];
                  return _HistoryTile(
                    item: item,
                    onOpen: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ResultScreen(
                            image: File(item.imagePath),
                            result: item.result,
                            historyMode: true,
                          ),
                        ),
                      );
                    },
                    onDelete: () => _delete(item.id),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemCount: history.length,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.item,
    required this.onOpen,
    required this.onDelete,
  });

  final HistoryItem item;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final time = '${_two(item.createdAt.hour)}:${_two(item.createdAt.minute)}';

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onOpen,
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE3EAED)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(item.imagePath),
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 76,
                  height: 76,
                  color: const Color(0xFFE8EEF1),
                  child: const Icon(Icons.image_not_supported_rounded),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(item.createdAt),
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: const Color(0xFF65747A)),
                  ),
                  const SizedBox(height: 8),
                  Text('Detected: ${item.result.count} birds'),
                  Text(
                    'Confidence: ${(item.result.averageConfidence * 100).round()}%',
                    style: const TextStyle(
                      color: Color(0xFF137B58),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${_two(date.day)} ${months[date.month - 1]} ${date.year}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history_toggle_off_rounded,
              size: 56,
              color: Color(0xFF8A9AA1),
            ),
            const SizedBox(height: 14),
            Text(
              'No history yet',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Saved detection results will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: const Color(0xFF65747A)),
            ),
          ],
        ),
      ),
    );
  }
}
