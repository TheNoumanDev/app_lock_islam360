export interface IslamicContent {
  id: string;
  type: 'quran' | 'hadith';
  arabic: string;
  translation: string;
  reference: string;
  feelings: string[];
}

export const islamicContents: IslamicContent[] = [
  {
    id: '1',
    type: 'quran',
    arabic: 'فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا',
    translation: 'For indeed, with hardship [will be] ease.',
    reference: 'Surah Ash-Sharh (94:6)',
    feelings: ['stressed', 'anxious', 'overwhelmed', 'difficult']
  },
  {
    id: '2',
    type: 'quran',
    arabic: 'وَلَا تَقْنَطُوا۟ مِن رَّحْمَةِ ٱللَّهِ',
    translation: 'And do not despair of the mercy of Allah.',
    reference: 'Surah Az-Zumar (39:53)',
    feelings: ['sad', 'depressed', 'hopeless', 'lost']
  },
  {
    id: '3',
    type: 'quran',
    arabic: 'إِنَّ ٱللَّهَ مَعَ ٱلصَّٰبِرِينَ',
    translation: 'Indeed, Allah is with the patient.',
    reference: 'Surah Al-Baqarah (2:153)',
    feelings: ['impatient', 'frustrated', 'angry', 'irritated']
  },
  {
    id: '4',
    type: 'quran',
    arabic: 'وَٱذْكُر رَّبَّكَ إِذَا نَسِيتَ',
    translation: 'And remember your Lord when you forget.',
    reference: 'Surah Al-Kahf (18:24)',
    feelings: ['forgetful', 'distracted', 'unmindful', 'heedless']
  },
  {
    id: '5',
    type: 'hadith',
    arabic: 'مَنْ لَمْ يَشْكُرِ النَّاسَ لَمْ يَشْكُرِ اللَّهَ',
    translation: 'He who does not thank people, does not thank Allah.',
    reference: 'Sunan At-Tirmidhi',
    feelings: ['ungrateful', 'entitled', 'complaining', 'dissatisfied']
  },
  {
    id: '6',
    type: 'quran',
    arabic: 'أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ',
    translation: 'Verily, in the remembrance of Allah do hearts find rest.',
    reference: 'Surah Ar-Ra\'d (13:28)',
    feelings: ['anxious', 'restless', 'uneasy', 'worried']
  },
  {
    id: '7',
    type: 'quran',
    arabic: 'وَمَن يَتَّقِ ٱللَّهَ يَجْعَل لَّهُۥ مَخْرَجًا',
    translation: 'And whoever fears Allah - He will make for him a way out.',
    reference: 'Surah At-Talaq (65:2)',
    feelings: ['trapped', 'stuck', 'helpless', 'confused']
  },
  {
    id: '8',
    type: 'hadith',
    arabic: 'إِنَّ اللَّهَ طَيِّبٌ لَا يَقْبَلُ إِلَّا طَيِّبًا',
    translation: 'Indeed, Allah is Pure and accepts only that which is pure.',
    reference: 'Sahih Muslim',
    feelings: ['guilty', 'ashamed', 'regretful', 'sinful']
  },
  {
    id: '9',
    type: 'quran',
    arabic: 'وَلَا تَيْأَسُوا۟ مِن رَّوْحِ ٱللَّهِ',
    translation: 'And despair not of relief from Allah.',
    reference: 'Surah Yusuf (12:87)',
    feelings: ['hopeless', 'desperate', 'defeated', 'lost']
  },
  {
    id: '10',
    type: 'quran',
    arabic: 'فَٱصْبِرْ صَبْرًا جَمِيلًا',
    translation: 'So be patient, with beautiful patience.',
    reference: 'Surah Al-Ma\'arij (70:5)',
    feelings: ['bored', 'waiting', 'restless', 'idle']
  }
];

export const predefinedFeelings = [
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
  'Confused',
  'Guilty',
  'Hopeless',
  'Impatient',
  'Tired'
];

export function findMatchingContent(feeling: string): IslamicContent {
  const normalizedFeeling = feeling.toLowerCase();
  
  // Find content that matches the feeling
  const match = islamicContents.find(content => 
    content.feelings.some(f => 
      normalizedFeeling.includes(f) || f.includes(normalizedFeeling)
    )
  );
  
  // Return match or random content if no match found
  return match || islamicContents[Math.floor(Math.random() * islamicContents.length)];
}
