import { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { Button } from '@/app/components/ui/button';
import { Card } from '@/app/components/ui/card';
import { BookOpen } from 'lucide-react';

interface AyatDisplayScreenProps {
  feeling: string;
  onComplete: () => void;
  onSkip: () => void;
}

// Sample content based on feeling
const contentMap: Record<string, { arabic: string; translation: string; reference: string }> = {
  default: {
    arabic: 'فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا',
    translation: 'For indeed, with hardship [will be] ease.',
    reference: 'Surah Ash-Sharh (94:6)'
  },
  Stressed: {
    arabic: 'فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا',
    translation: 'For indeed, with hardship [will be] ease.',
    reference: 'Surah Ash-Sharh (94:6)'
  },
  Anxious: {
    arabic: 'أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ',
    translation: 'Verily, in the remembrance of Allah do hearts find rest.',
    reference: 'Surah Ar-Ra\'d (13:28)'
  },
  Sad: {
    arabic: 'وَلَا تَحْزَنْ إِنَّ ٱللَّهَ مَعَنَا',
    translation: 'Do not grieve; indeed Allah is with us.',
    reference: 'Surah At-Tawbah (9:40)'
  },
  Bored: {
    arabic: 'أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ',
    translation: 'Verily, in the remembrance of Allah do hearts find rest.',
    reference: 'Surah Ar-Ra\'d (13:28)'
  },
  Ungrateful: {
    arabic: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
    translation: 'If you are grateful, I will surely increase you [in favor].',
    reference: 'Surah Ibrahim (14:7)'
  }
};

export function AyatDisplayScreen({ feeling, onComplete, onSkip }: AyatDisplayScreenProps) {
  const [countdown, setCountdown] = useState(3);
  const [canContinue, setCanContinue] = useState(false);

  const content = contentMap[feeling] || contentMap.default;

  useEffect(() => {
    const timer = setInterval(() => {
      setCountdown((prev) => {
        if (prev <= 1) {
          setCanContinue(true);
          clearInterval(timer);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    // Shake detection
    const handleShake = (event: DeviceMotionEvent) => {
      const acceleration = event.accelerationIncludingGravity;
      if (acceleration && 
          (Math.abs(acceleration.x || 0) > 15 || 
           Math.abs(acceleration.y || 0) > 15 || 
           Math.abs(acceleration.z || 0) > 15)) {
        onSkip();
      }
    };

    window.addEventListener('devicemotion', handleShake);

    return () => {
      clearInterval(timer);
      window.removeEventListener('devicemotion', handleShake);
    };
  }, [onSkip]);

  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 via-white to-white flex flex-col items-center justify-center px-6">
      {/* Header */}
      <div className="flex items-center gap-2 mb-8">
        <BookOpen className="w-6 h-6 text-blue-600" />
        <span className="text-sm font-semibold text-blue-600 uppercase tracking-wide">
          Quranic Verse
        </span>
      </div>

      {/* Arabic Text */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="mb-8"
      >
        <p 
          className="text-4xl text-center text-black leading-loose mb-8"
          dir="rtl"
          style={{ fontFamily: 'Traditional Arabic, serif' }}
        >
          {content.arabic}
        </p>
      </motion.div>

      {/* Translation Card */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.2 }}
        className="w-full max-w-md mb-6"
      >
        <Card className="p-6 border-gray-100 shadow-sm bg-white/80 backdrop-blur-sm">
          <div className="text-lg text-gray-700 leading-relaxed mb-4">
            <span className="text-gray-400 text-2xl">"</span>
            {content.translation}
            <span className="text-gray-400 text-2xl">"</span>
          </div>
          <p className="text-sm text-gray-500 font-medium">{content.reference}</p>
        </Card>
      </motion.div>

      {/* Countdown Circle */}
      {!canContinue && (
        <motion.div
          initial={{ scale: 0.8, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          className="mb-4"
        >
          <div className="w-20 h-20 rounded-full bg-blue-100 flex items-center justify-center">
            <motion.span
              key={countdown}
              initial={{ scale: 1.5, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              className="text-3xl font-bold text-blue-600"
            >
              {countdown}
            </motion.span>
          </div>
        </motion.div>
      )}

      {/* Message */}
      <p className="text-sm text-gray-500 mb-8 text-center">
        {canContinue ? 'Reflection complete' : 'Take a moment to reflect...'}
      </p>

      {/* Done Button */}
      <Button
        onClick={onComplete}
        disabled={!canContinue}
        className="w-full max-w-md h-14 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-lg font-medium disabled:opacity-50 disabled:cursor-not-allowed"
      >
        Done
      </Button>

      {/* Skip Hint */}
      <p className="text-xs text-gray-400 mt-6 text-center">
        Shake device to skip in emergencies
      </p>
    </div>
  );
}
