import { useState, useEffect } from 'react';
import { IslamicContent } from '@/app/data/islamicContent';
import { Button } from '@/app/components/ui/button';
import { BookOpen, Sparkles } from 'lucide-react';

interface ContentDisplayProps {
  content: IslamicContent;
  onComplete: () => void;
  onSkip: () => void;
}

export function ContentDisplay({ content, onComplete, onSkip }: ContentDisplayProps) {
  const [timeLeft, setTimeLeft] = useState(3);
  const [canProceed, setCanProceed] = useState(false);

  useEffect(() => {
    if (timeLeft > 0) {
      const timer = setTimeout(() => setTimeLeft(timeLeft - 1), 1000);
      return () => clearTimeout(timer);
    } else {
      setCanProceed(true);
    }
  }, [timeLeft]);

  // Shake detection
  useEffect(() => {
    let shakeCount = 0;
    let lastTime = Date.now();

    const handleMotion = (event: DeviceMotionEvent) => {
      const acceleration = event.accelerationIncludingGravity;
      if (!acceleration) return;

      const { x, y, z } = acceleration;
      const total = Math.abs(x || 0) + Math.abs(y || 0) + Math.abs(z || 0);

      const currentTime = Date.now();
      if (currentTime - lastTime > 100) {
        if (total > 40) {
          shakeCount++;
          if (shakeCount > 3) {
            onSkip();
          }
        }
        lastTime = currentTime;
      }
    };

    window.addEventListener('devicemotion', handleMotion);
    return () => window.removeEventListener('devicemotion', handleMotion);
  }, [onSkip]);

  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 to-white flex items-center justify-center p-6">
      <div className="max-w-2xl w-full">
        <div className="bg-white rounded-3xl shadow-lg border border-gray-100 p-8 space-y-6">
          {/* Header */}
          <div className="flex items-center gap-3 pb-4 border-b border-gray-100">
            {content.type === 'quran' ? (
              <BookOpen className="w-6 h-6 text-blue-600" />
            ) : (
              <Sparkles className="w-6 h-6 text-blue-600" />
            )}
            <span className="text-sm font-medium text-gray-600">
              {content.type === 'quran' ? 'Quranic Verse' : 'Hadith'}
            </span>
          </div>

          {/* Arabic Text */}
          <div className="text-center py-6">
            <p className="text-3xl leading-loose text-black font-arabic" dir="rtl">
              {content.arabic}
            </p>
          </div>

          {/* Translation */}
          <div className="bg-blue-50 rounded-2xl p-6">
            <p className="text-lg text-black leading-relaxed italic">
              "{content.translation}"
            </p>
          </div>

          {/* Reference */}
          <div className="text-center">
            <p className="text-sm text-gray-600 font-medium">{content.reference}</p>
          </div>

          {/* Timer and Actions */}
          <div className="pt-4 space-y-4">
            {!canProceed && (
              <div className="text-center">
                <div className="inline-flex items-center justify-center w-16 h-16 bg-blue-100 rounded-full mb-2">
                  <span className="text-2xl font-bold text-blue-600">{timeLeft}</span>
                </div>
                <p className="text-sm text-gray-600">Take a moment to reflect...</p>
              </div>
            )}

            <Button
              onClick={onComplete}
              disabled={!canProceed}
              className="w-full h-14 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-base font-medium disabled:bg-gray-200 disabled:text-gray-400"
            >
              {canProceed ? 'Done' : 'Please wait...'}
            </Button>

            <p className="text-xs text-center text-gray-500">
              Shake device to skip in emergencies
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
