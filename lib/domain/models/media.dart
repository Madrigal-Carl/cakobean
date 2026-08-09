/// The kind of media a [ArticleModel] slide can be.
enum MediaType { image, video }

/// A media file picked locally but not yet uploaded. Kept as plain data so
/// the data layer never depends on the image_picker package.
class PickedMedia {
  final String path;
  final String name;
  final MediaType type;

  const PickedMedia({
    required this.path,
    required this.name,
    required this.type,
  });
}

/// Detects the media type from a URL by its file extension.
/// Anything that isn't a known video extension is treated as an image.
///
/// Handles both plain URLs and Firebase Storage download URLs
/// (`.../o/{encoded path}?alt=media&token=...`), where the file extension is
/// URL-encoded inside the path segment.
MediaType mediaTypeForUrl(String url) {
  var path = url;
  final queryIndex = path.indexOf('?');
  if (queryIndex != -1) path = path.substring(0, queryIndex);

  final objectIndex = path.indexOf('/o/');
  if (objectIndex != -1) {
    path = path.substring(objectIndex + 3);
    try {
      path = Uri.decodeComponent(path);
    } on FormatException {
      // Leave as-is; the extension check below still works for plain URLs.
    }
  }

  final lastSegment = path.toLowerCase().split('/').last;
  if (lastSegment.endsWith('.mp4') ||
      lastSegment.endsWith('.mov') ||
      lastSegment.endsWith('.m4v') ||
      lastSegment.endsWith('.webm')) {
    return MediaType.video;
  }
  return MediaType.image;
}
