import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

class LikedHistoryScreen extends StatelessWidget {
  final Box likedBox;

  const LikedHistoryScreen({super.key, required this.likedBox});

  void _removeLikeFromHive(String title, BuildContext context) {
    likedBox.delete(title);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD9F0D9),
      appBar: AppBar(
        title: const Text('Destinasi Favorit'),
        backgroundColor: Color(0xFF5D7B79),
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      body: ValueListenableBuilder(
        valueListenable: likedBox.listenable(),
        builder: (context, Box box, _) {
          final likedList = box.values.toList().cast<Map<dynamic, dynamic>>();

          if (likedList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  const Text(
                    'Belum ada destinasi favorit. Yuk, cari!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: likedList.length,
            itemBuilder: (context, index) {
              final item = likedList[index];
              final title = item['title']?.toString() ?? 'N/A';
              final thumbnail = item['thumbnail']?.toString() ?? '';
              final description = item['description']?.toString() ?? 'Destinasi Disukai';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: thumbnail.isNotEmpty
                        ? Image.network(
                            thumbnail,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.favorite, color: Colors.pinkAccent, size: 40),
                          )
                        : const Icon(Icons.favorite, color: Colors.pinkAccent),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003049),
                    ),
                  ),
                  subtitle: Text(description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _removeLikeFromHive(title, context),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
