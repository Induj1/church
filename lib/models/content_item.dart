class ContentItem {
  final String id;
  final String? title;
  final String? description;
  final String? url;
  final String? thumbnailUrl;
  final String? mimeType;
  final String? type;
  final DateTime? createdAt;

  ContentItem({
    required this.id,
    this.title,
    this.description,
    this.url,
    this.thumbnailUrl,
    this.mimeType,
    this.type,
    this.createdAt,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: (json['id'] ?? json['uuid'] ?? '') as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String?,
      thumbnailUrl: (json['thumbnail_url'] as String?) ?? (json['thumbnailUrl'] as String?),
      mimeType: (json['mime_type'] as String?) ?? (json['mimeType'] as String?),
      type: json['type'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  bool get isImage {
    // Prefer inspecting the thumbnail or file URL extension first — this
    // allows items whose main file is a PDF/text but have an image
    // thumbnail to be displayed as images.
    final path = (thumbnailUrl ?? url) ?? '';
    if (path.isNotEmpty) {
      // Remove query string/fragment if present, then get extension
      final cleaned = path.split('?').first.split('#').first;
      final parts = cleaned.split('.');
      if (parts.length > 1) {
        final ext = parts.last.toLowerCase();
        if (['png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp'].contains(ext)) return true;
      }
    }

    // Fall back to mime type if available
    if (mimeType != null) return mimeType!.toLowerCase().startsWith('image/');

    return false;
  }
}
