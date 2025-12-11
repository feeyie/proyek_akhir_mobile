import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/search_service.dart';

class ResultsPage extends StatelessWidget {
  final String query;
  final List<SearchResult> apiResults;
  final String currencyCode;
  final int timezoneOffset;

  const ResultsPage({
    super.key,
    required this.query,
    required this.apiResults,
    required this.currencyCode,
    required this.timezoneOffset,
  });

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text("Search Result: $query"),
        backgroundColor: const Color(0xFF5D7B79),
      ),
      body: apiResults.isEmpty
          ? const Center(
              child: Text(
                "Tidak ada hasil ditemukan",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: apiResults.length,
              itemBuilder: (context, i) {
                final item = apiResults[i];

                return GestureDetector(
                  onTap: () => _openLink(item.link),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF344E41),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          item.snippet,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            const Icon(Icons.open_in_new,
                                size: 17, color: Color(0xFF5D7B79)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.link,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF5D7B79),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
