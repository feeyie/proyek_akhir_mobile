class SearchResult {
  final String title;
  final String link;
  final String snippet;

  SearchResult({
    required this.title,
    required this.link,
    required this.snippet,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      title: json['title'] ?? 'No Title',

      link: json['link']
          ?? json['formattedUrl']
          ?? json['url']
          ?? '',

      snippet: json['snippet'] ?? 'No description available',
    );
  }
}
