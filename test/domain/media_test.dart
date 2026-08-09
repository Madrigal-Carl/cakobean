import 'package:test/test.dart';

import 'package:cakobean/domain/models/media.dart';

void main() {
  group('mediaTypeForUrl', () {
    test('detects plain image URLs by extension', () {
      expect(
        mediaTypeForUrl('https://example.com/photo.jpg'),
        MediaType.image,
      );
    });

    test('detects plain video URLs by extension', () {
      expect(mediaTypeForUrl('https://example.com/video.mp4'), MediaType.video);
      expect(mediaTypeForUrl('https://example.com/clip.mov'), MediaType.video);
      expect(mediaTypeForUrl('https://example.com/clip.MOV'), MediaType.video);
    });

    test('treats extensionless URLs as images', () {
      expect(mediaTypeForUrl('https://example.com/photo'), MediaType.image);
    });

    test('strips query parameters before checking the extension', () {
      expect(
        mediaTypeForUrl('https://example.com/video.mp4?token=abc'),
        MediaType.video,
      );
    });

    test('decodes the path of a Firebase Storage download URL', () {
      const storageBase = 'https://firebasestorage.googleapis.com/v0/b/'
          'bucket.appspot.com/o';
      expect(
        mediaTypeForUrl('$storageBase/articles%2Fuid%2Fphoto.jpg?alt=media'),
        MediaType.image,
      );
      expect(
        mediaTypeForUrl(
          '$storageBase/articles%2Fuid%2Fclip.mp4?alt=media&token=xyz',
        ),
        MediaType.video,
      );
    });
  });
}
