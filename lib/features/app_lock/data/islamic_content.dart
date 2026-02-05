// Islamic content data for app lock screens
// Contains Quranic verses and Hadith mapped to feelings

enum ContentType { ayat, hadith }

/// Model for Islamic content (Ayat or Hadith)
class IslamicContent {
  final String arabic;
  final String translation;
  final String reference;
  final ContentType type;

  const IslamicContent({
    required this.arabic,
    required this.translation,
    required this.reference,
    required this.type,
  });
}

/// Predefined feelings for quick selection (from Figma design)
const List<String> predefinedFeelings = [
  'Stressed',
  'Anxious',
  'Bored',
  'Sad',
  'Ungrateful',
  'Angry',
  'Frustrated',
  'Distracted',
  'Lonely',
  'Overwhelmed',
];

/// Mapping of feelings to relevant Islamic content
const Map<String, IslamicContent> feelingContentMap = {
  'stressed': IslamicContent(
    arabic: 'فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا',
    translation: 'For indeed, with hardship [will be] ease.',
    reference: 'Surah Ash-Sharh (94:6)',
    type: ContentType.ayat,
  ),
  'anxious': IslamicContent(
    arabic: 'أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ',
    translation: 'Verily, in the remembrance of Allah do hearts find rest.',
    reference: 'Surah Ar-Ra\'d (13:28)',
    type: ContentType.ayat,
  ),
  'bored': IslamicContent(
    arabic: 'فَٱصْبِرْ صَبْرًا جَمِيلًا',
    translation: 'So be patient with gracious patience.',
    reference: 'Surah Al-Ma\'arij (70:5)',
    type: ContentType.ayat,
  ),
  'sad': IslamicContent(
    arabic: 'لَا تَحْزَنْ إِنَّ ٱللَّهَ مَعَنَا',
    translation: 'Do not grieve; indeed Allah is with us.',
    reference: 'Surah At-Tawbah (9:40)',
    type: ContentType.ayat,
  ),
  'ungrateful': IslamicContent(
    arabic: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
    translation: 'If you are grateful, I will surely increase you [in favor].',
    reference: 'Surah Ibrahim (14:7)',
    type: ContentType.ayat,
  ),
  'angry': IslamicContent(
    arabic: 'وَٱلْكَـٰظِمِينَ ٱلْغَيْظَ وَٱلْعَافِينَ عَنِ ٱلنَّاسِ',
    translation: 'Those who restrain anger and pardon the people.',
    reference: 'Surah Ali \'Imran (3:134)',
    type: ContentType.ayat,
  ),
  'frustrated': IslamicContent(
    arabic: 'يَـٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ ٱسْتَعِينُوا۟ بِٱلصَّبْرِ وَٱلصَّلَوٰةِ',
    translation: 'O you who believe, seek help through patience and prayer.',
    reference: 'Surah Al-Baqarah (2:153)',
    type: ContentType.ayat,
  ),
  'distracted': IslamicContent(
    arabic: 'وَٱذْكُر رَّبَّكَ إِذَا نَسِيتَ',
    translation: 'And remember your Lord when you forget.',
    reference: 'Surah Al-Kahf (18:24)',
    type: ContentType.ayat,
  ),
  'lonely': IslamicContent(
    arabic: 'وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ',
    translation: 'And He is with you wherever you are.',
    reference: 'Surah Al-Hadid (57:4)',
    type: ContentType.ayat,
  ),
  'overwhelmed': IslamicContent(
    arabic: 'لَا يُكَلِّفُ ٱللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
    translation: 'Allah does not burden a soul beyond that it can bear.',
    reference: 'Surah Al-Baqarah (2:286)',
    type: ContentType.ayat,
  ),
};

/// Default content when no specific feeling is matched
const IslamicContent defaultContent = IslamicContent(
  arabic: 'إِنَّ ٱللَّهَ مَعَ ٱلصَّـٰبِرِينَ',
  translation: 'Indeed, Allah is with the patient.',
  reference: 'Surah Al-Baqarah (2:153)',
  type: ContentType.ayat,
);

/// Get Islamic content for a given feeling
IslamicContent getContentForFeeling(String feeling) {
  final normalizedFeeling = feeling.toLowerCase().trim();

  // Direct match
  if (feelingContentMap.containsKey(normalizedFeeling)) {
    return feelingContentMap[normalizedFeeling]!;
  }

  // Partial match - check if any key contains or is contained in the feeling
  for (final entry in feelingContentMap.entries) {
    if (normalizedFeeling.contains(entry.key) || entry.key.contains(normalizedFeeling)) {
      return entry.value;
    }
  }

  // No match - return default content
  return defaultContent;
}
