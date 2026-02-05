import 'package:flutter_test/flutter_test.dart';
import 'package:app_lock_islam360/features/app_lock/data/islamic_content.dart';

void main() {
  group('IslamicContent', () {
    test('should have correct predefined feelings count', () {
      expect(predefinedFeelings.length, 10);
    });

    test('should have content for all predefined feelings', () {
      for (final feeling in predefinedFeelings) {
        final content = getContentForFeeling(feeling);
        expect(content.arabic, isNotEmpty);
        expect(content.translation, isNotEmpty);
        expect(content.reference, isNotEmpty);
      }
    });

    test('should return correct content for stressed feeling', () {
      final content = getContentForFeeling('Stressed');
      expect(content.arabic, contains('يُسْرًا'));
      expect(content.translation, contains('ease'));
      expect(content.reference, contains('94:6'));
      expect(content.type, ContentType.ayat);
    });

    test('should return correct content for anxious feeling', () {
      final content = getContentForFeeling('Anxious');
      expect(content.arabic, contains('تَطْمَئِنُّ'));
      expect(content.translation, contains('rest'));
      expect(content.reference, contains('13:28'));
    });

    test('should be case insensitive', () {
      final lowercase = getContentForFeeling('stressed');
      final uppercase = getContentForFeeling('STRESSED');
      final mixed = getContentForFeeling('Stressed');

      expect(lowercase.translation, uppercase.translation);
      expect(uppercase.translation, mixed.translation);
    });

    test('should return default content for unknown feeling', () {
      final content = getContentForFeeling('randomfeeling123');
      expect(content, defaultContent);
      expect(content.translation, contains('patient'));
    });

    test('should handle partial matches', () {
      // 'I feel stressed out' contains 'stressed'
      final content = getContentForFeeling('I feel stressed out');
      expect(content.reference, contains('94:6'));
    });

    test('should trim whitespace', () {
      final content = getContentForFeeling('  stressed  ');
      expect(content.reference, contains('94:6'));
    });

    test('defaultContent should be valid', () {
      expect(defaultContent.arabic, isNotEmpty);
      expect(defaultContent.translation, isNotEmpty);
      expect(defaultContent.reference, isNotEmpty);
      expect(defaultContent.type, ContentType.ayat);
    });
  });
}
