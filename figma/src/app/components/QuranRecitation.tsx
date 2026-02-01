import { useState, useEffect } from 'react';
import { Button } from '@/app/components/ui/button';
import { Card } from '@/app/components/ui/card';
import { Input } from '@/app/components/ui/input';
import { BookOpen, ChevronLeft, ChevronRight, Check, Star, Search, BookmarkCheck } from 'lucide-react';
import { ScrollArea } from '@/app/components/ui/scroll-area';
import { allSurahs, sampleVerses, Surah, Verse } from '@/app/data/quranData';

export function QuranRecitation() {
  const [currentSurah, setCurrentSurah] = useState<Surah>(allSurahs[0]);
  const [verses, setVerses] = useState<Verse[]>([]);
  const [readVerses, setReadVerses] = useState<Record<number, number[]>>({});
  const [lastRead, setLastRead] = useState<{ surahNumber: number; verseNumber: number }>({ surahNumber: 1, verseNumber: 1 });
  const [bookmarkedSurahs, setBookmarkedSurahs] = useState<number[]>([1]);
  const [searchQuery, setSearchQuery] = useState('');
  const [showSurahList, setShowSurahList] = useState(false);

  // Load verses when surah changes
  useEffect(() => {
    if (sampleVerses[currentSurah.number]) {
      setVerses(sampleVerses[currentSurah.number]);
    } else {
      // In a real app, fetch verses from API
      // For now, generate placeholder verses
      const placeholderVerses: Verse[] = Array.from({ length: currentSurah.totalVerses }, (_, i) => ({
        number: i + 1,
        arabic: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        translation: `Verse ${i + 1} - Translation will be loaded from API`
      }));
      setVerses(placeholderVerses);
    }
  }, [currentSurah]);

  const handleVerseRead = (verseNumber: number) => {
    const surahReads = readVerses[currentSurah.number] || [];
    
    if (surahReads.includes(verseNumber)) {
      setReadVerses({
        ...readVerses,
        [currentSurah.number]: surahReads.filter(v => v !== verseNumber)
      });
    } else {
      setReadVerses({
        ...readVerses,
        [currentSurah.number]: [...surahReads, verseNumber]
      });
      // Update last read
      setLastRead({ surahNumber: currentSurah.number, verseNumber });
    }
  };

  const handleBookmark = (surahNumber: number) => {
    if (bookmarkedSurahs.includes(surahNumber)) {
      setBookmarkedSurahs(bookmarkedSurahs.filter(s => s !== surahNumber));
    } else {
      setBookmarkedSurahs([...bookmarkedSurahs, surahNumber]);
    }
  };

  const goToNextSurah = () => {
    const currentIndex = allSurahs.findIndex(s => s.number === currentSurah.number);
    if (currentIndex < allSurahs.length - 1) {
      setCurrentSurah(allSurahs[currentIndex + 1]);
    }
  };

  const goToPreviousSurah = () => {
    const currentIndex = allSurahs.findIndex(s => s.number === currentSurah.number);
    if (currentIndex > 0) {
      setCurrentSurah(allSurahs[currentIndex - 1]);
    }
  };

  const goToLastRead = () => {
    const surah = allSurahs.find(s => s.number === lastRead.surahNumber);
    if (surah) {
      setCurrentSurah(surah);
      setShowSurahList(false);
      // Scroll to verse (in a real app)
    }
  };

  const currentSurahReads = readVerses[currentSurah.number] || [];
  const progress = Math.round((currentSurahReads.length / currentSurah.totalVerses) * 100);

  const filteredSurahs = allSurahs.filter(surah =>
    surah.name.includes(searchQuery) ||
    surah.englishName.toLowerCase().includes(searchQuery.toLowerCase()) ||
    surah.englishNameTranslation.toLowerCase().includes(searchQuery.toLowerCase()) ||
    surah.number.toString().includes(searchQuery)
  );

  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-50 to-white pb-20">
      {/* Header */}
      <div className="bg-white border-b border-gray-100">
        <div className="max-w-4xl mx-auto px-6 py-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-black">Quran</h1>
              <p className="text-sm text-gray-600 mt-1">Read and reflect</p>
            </div>
            <Button
              onClick={() => setShowSurahList(!showSurahList)}
              variant="outline"
              className="rounded-xl"
            >
              <BookOpen className="w-5 h-5 mr-2" />
              {showSurahList ? 'Hide' : 'All Surahs'}
            </Button>
          </div>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-6 py-6 space-y-6">
        {/* Continue Reading Banner */}
        {!showSurahList && lastRead.surahNumber !== currentSurah.number && (
          <Card className="bg-gradient-to-r from-green-500 to-green-600 p-4 border-0 cursor-pointer" onClick={goToLastRead}>
            <div className="flex items-center justify-between text-white">
              <div className="flex items-center gap-3">
                <BookmarkCheck className="w-6 h-6" />
                <div>
                  <p className="font-semibold">Continue Reading</p>
                  <p className="text-sm text-green-100">
                    {allSurahs.find(s => s.number === lastRead.surahNumber)?.englishName} - Verse {lastRead.verseNumber}
                  </p>
                </div>
              </div>
              <ChevronRight className="w-5 h-5" />
            </div>
          </Card>
        )}

        {!showSurahList ? (
          <>
            {/* Surah Header */}
            <Card className="p-6 border-gray-100 shadow-sm">
              <div className="flex items-center justify-between mb-4">
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-2">
                    <h2 className="text-2xl font-bold text-black">{currentSurah.name}</h2>
                    <button
                      onClick={() => handleBookmark(currentSurah.number)}
                      className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                    >
                      <Star
                        className={`w-5 h-5 ${
                          bookmarkedSurahs.includes(currentSurah.number)
                            ? 'fill-yellow-400 text-yellow-400'
                            : 'text-gray-400'
                        }`}
                      />
                    </button>
                  </div>
                  <p className="text-gray-600">
                    {currentSurah.englishName} • {currentSurah.englishNameTranslation}
                  </p>
                  <p className="text-sm text-gray-500 mt-1">
                    {currentSurah.revelationType} • {currentSurah.totalVerses} verses
                  </p>
                </div>
                <div className="text-right">
                  <div className="text-3xl font-bold text-blue-600">{progress}%</div>
                  <p className="text-sm text-gray-600">Read</p>
                </div>
              </div>

              {/* Progress Bar */}
              <div className="w-full bg-gray-200 rounded-full h-2 mb-4">
                <div
                  className="bg-gradient-to-r from-blue-600 to-blue-500 h-2 rounded-full transition-all duration-300"
                  style={{ width: `${progress}%` }}
                />
              </div>

              {/* Navigation */}
              <div className="flex gap-2">
                <Button
                  onClick={goToPreviousSurah}
                  disabled={currentSurah.number === 1}
                  variant="outline"
                  className="flex-1 h-10 rounded-xl"
                >
                  <ChevronLeft className="w-4 h-4 mr-1" />
                  Previous
                </Button>
                <Button
                  onClick={goToNextSurah}
                  disabled={currentSurah.number === 114}
                  variant="outline"
                  className="flex-1 h-10 rounded-xl"
                >
                  Next
                  <ChevronRight className="w-4 h-4 ml-1" />
                </Button>
              </div>
            </Card>

            {/* Verses */}
            <div className="space-y-4">
              {verses.map((verse) => {
                const isRead = currentSurahReads.includes(verse.number);
                
                return (
                  <Card
                    key={verse.number}
                    className={`p-6 border-gray-100 shadow-sm cursor-pointer transition-all ${
                      isRead ? 'bg-green-50 border-green-200' : ''
                    }`}
                    onClick={() => handleVerseRead(verse.number)}
                  >
                    <div className="flex items-start gap-4">
                      <div
                        className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 ${
                          isRead ? 'bg-green-500 text-white' : 'bg-gray-200 text-gray-600'
                        }`}
                      >
                        {isRead ? <Check className="w-4 h-4" /> : verse.number}
                      </div>
                      <div className="flex-1 space-y-4">
                        {/* Arabic Text */}
                        <p
                          className="text-2xl leading-loose text-black text-right font-arabic"
                          dir="rtl"
                        >
                          {verse.arabic}
                        </p>
                        
                        {/* Translation */}
                        <p className="text-base text-gray-700 leading-relaxed">
                          {verse.translation}
                        </p>
                      </div>
                    </div>
                  </Card>
                );
              })}
            </div>
          </>
        ) : (
          <>
            {/* Search */}
            <div className="relative">
              <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
              <Input
                placeholder="Search by name, number, or translation..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="h-12 pl-12 rounded-xl border-gray-200"
              />
            </div>

            {/* Surah List */}
            <Card className="p-4 border-gray-100 shadow-sm">
              <h3 className="text-lg font-semibold text-black mb-4 px-2">All Surahs (114)</h3>
              <ScrollArea className="h-[600px]">
                <div className="space-y-2">
                  {filteredSurahs.map((surah) => {
                    const surahReads = readVerses[surah.number] || [];
                    const surahProgress = Math.round((surahReads.length / surah.totalVerses) * 100);
                    
                    return (
                      <button
                        key={surah.number}
                        onClick={() => {
                          setCurrentSurah(surah);
                          setShowSurahList(false);
                        }}
                        className={`w-full flex items-center justify-between p-4 rounded-xl transition-colors ${
                          currentSurah.number === surah.number
                            ? 'bg-blue-50 border-2 border-blue-200'
                            : 'bg-gray-50 hover:bg-gray-100'
                        }`}
                      >
                        <div className="flex items-center gap-3 flex-1">
                          <div className="w-10 h-10 bg-white rounded-lg flex items-center justify-center text-sm font-semibold text-gray-700 flex-shrink-0">
                            {surah.number}
                          </div>
                          <div className="text-left flex-1">
                            <div className="flex items-center gap-2">
                              <span className="font-semibold text-black">{surah.name}</span>
                              {bookmarkedSurahs.includes(surah.number) && (
                                <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                              )}
                            </div>
                            <div className="text-sm text-gray-600">{surah.englishName} • {surah.totalVerses} verses</div>
                            {surahProgress > 0 && (
                              <div className="flex items-center gap-2 mt-1">
                                <div className="flex-1 bg-gray-200 rounded-full h-1">
                                  <div
                                    className="bg-blue-600 h-1 rounded-full"
                                    style={{ width: `${surahProgress}%` }}
                                  />
                                </div>
                                <span className="text-xs text-gray-500">{surahProgress}%</span>
                              </div>
                            )}
                          </div>
                        </div>
                        <span className={`text-xs px-2 py-1 rounded ${
                          surah.revelationType === 'Meccan' ? 'bg-orange-100 text-orange-700' : 'bg-green-100 text-green-700'
                        }`}>
                          {surah.revelationType}
                        </span>
                      </button>
                    );
                  })}
                </div>
              </ScrollArea>
            </Card>
          </>
        )}

        {/* Info */}
        {!showSurahList && (
          <Card className="bg-blue-50 p-4 border-blue-100">
            <p className="text-sm text-gray-700">
              <span className="font-medium text-black">Tip:</span> Tap on any verse to mark it as read. 
              Your progress is tracked for each Surah.
            </p>
          </Card>
        )}
      </div>
    </div>
  );
}
