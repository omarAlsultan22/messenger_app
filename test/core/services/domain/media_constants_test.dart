import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/core/services/domain/media_constants.dart';


void main() {
  group('MediaConstants.classify', () {
    test('classifies .jpg as image', () {
      expect(MediaConstants.classify(File('/tmp/photo.jpg')),
          MediaCategory.image);
    });

    test('classifies .png as image', () {
      expect(MediaConstants.classify(File('/tmp/photo.png')),
          MediaCategory.image);
    });

    test('classifies .gif as image', () {
      expect(MediaConstants.classify(File('/tmp/anim.gif')),
          MediaCategory.image);
    });

    test('classifies .mp4 as video', () {
      expect(MediaConstants.classify(File('/tmp/clip.mp4')),
          MediaCategory.video);
    });

    test('classifies .mov as video', () {
      expect(MediaConstants.classify(File('/tmp/clip.mov')),
          MediaCategory.video);
    });

    test('classifies .mp3 as audio', () {
      expect(MediaConstants.classify(File('/tmp/song.mp3')),
          MediaCategory.audio);
    });

    test('classifies .wav as audio', () {
      expect(MediaConstants.classify(File('/tmp/song.wav')),
          MediaCategory.audio);
    });

    test('classifies .pdf as unknown', () {
      expect(MediaConstants.classify(File('/tmp/doc.pdf')),
          MediaCategory.unknown);
    });

    test('classifies file with no extension as unknown', () {
      expect(MediaConstants.classify(File('/tmp/README')),
          MediaCategory.unknown);
    });

    test('is case-insensitive for uppercase extensions', () {
      expect(MediaConstants.classify(File('/tmp/PHOTO.JPG')),
          MediaCategory.image);
      expect(MediaConstants.classify(File('/tmp/CLIP.MP4')),
          MediaCategory.video);
    });

    test('classifies file with leading dot only (.jpg) as image', () {
      expect(MediaConstants.classify(File('/tmp/.jpg')),
          MediaCategory.image);
    });
  });
}