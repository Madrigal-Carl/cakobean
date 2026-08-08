/// The kind of media a [ArticleModel] slide can be.
enum MediaType { image, video }

/// Detects the media type from a URL by its file extension.
/// Anything that isn't a known video extension is treated as an image.
MediaType mediaTypeForUrl(String url) {
  final path = url.toLowerCase();
  if (path.endsWith('.mp4') ||
      path.endsWith('.mov') ||
      path.endsWith('.m4v') ||
      path.endsWith('.webm')) {
    return MediaType.video;
  }
  return MediaType.image;
}
