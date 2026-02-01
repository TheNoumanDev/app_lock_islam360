import { useState, useEffect } from 'react';
import { Button } from '@/app/components/ui/button';
import { Card } from '@/app/components/ui/card';
import { Input } from '@/app/components/ui/input';
import { Slider } from '@/app/components/ui/slider';
import { Check, Calculator, SlidersHorizontal, Smartphone } from 'lucide-react';

interface AlarmDismissalScreenProps {
  time: string;
  label: string;
  onDismiss: () => void;
}

export function AlarmDismissalScreen({ time, label, onDismiss }: AlarmDismissalScreenProps) {
  const [dismissMethod, setDismissMethod] = useState<'read' | 'math' | 'slide' | 'shake' | null>(null);
  const [mathAnswer, setMathAnswer] = useState('');
  const [sliderValue, setSliderValue] = useState([0]);
  const [shakeDetected, setShakeDetected] = useState(false);

  // Random math problem
  const num1 = 12;
  const num2 = 7;
  const correctAnswer = num1 + num2;

  useEffect(() => {
    // Shake detection
    const handleShake = (event: DeviceMotionEvent) => {
      const acceleration = event.accelerationIncludingGravity;
      if (acceleration && 
          (Math.abs(acceleration.x || 0) > 15 || 
           Math.abs(acceleration.y || 0) > 15 || 
           Math.abs(acceleration.z || 0) > 15)) {
        setShakeDetected(true);
        if (dismissMethod === 'shake') {
          setTimeout(onDismiss, 500);
        }
      }
    };

    window.addEventListener('devicemotion', handleShake);
    return () => window.removeEventListener('devicemotion', handleShake);
  }, [dismissMethod, onDismiss]);

  const handleReadDismiss = () => {
    setDismissMethod('read');
    setTimeout(onDismiss, 500);
  };

  const handleMathSubmit = () => {
    if (parseInt(mathAnswer) === correctAnswer) {
      onDismiss();
    } else {
      setMathAnswer('');
      alert('Incorrect answer. Try again.');
    }
  };

  useEffect(() => {
    if (dismissMethod === 'slide' && sliderValue[0] >= 95) {
      setTimeout(onDismiss, 300);
    }
  }, [sliderValue, dismissMethod, onDismiss]);

  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 via-white to-purple-50 flex flex-col items-center justify-center px-6">
      {/* Time Display */}
      <div className="text-center mb-8">
        <div className="text-6xl font-bold text-black mb-2">{time}</div>
        <p className="text-lg text-gray-600">{label}</p>
      </div>

      {/* Dhikr Card */}
      <Card className="w-full max-w-md p-6 mb-8 border-gray-100 shadow-lg bg-white/90 backdrop-blur-sm">
        <div className="text-center space-y-4">
          <p 
            className="text-3xl text-black leading-loose"
            dir="rtl"
            style={{ fontFamily: 'Traditional Arabic, serif' }}
          >
            سُبْحَانَ اللهِ وَبِحَمْدِهِ
          </p>
          <p className="text-lg text-gray-700">
            "Glory be to Allah and praise Him"
          </p>
          <p className="text-sm text-gray-500 pt-2 border-t border-gray-200">
            Read this dhikr, then choose how to dismiss:
          </p>
        </div>
      </Card>

      {/* Dismissal Options */}
      {!dismissMethod && (
        <div className="w-full max-w-md space-y-3">
          <Button
            onClick={handleReadDismiss}
            className="w-full h-14 bg-green-600 hover:bg-green-700 text-white rounded-xl text-base font-medium flex items-center justify-center gap-2"
          >
            <Check className="w-5 h-5" />
            I have read it
          </Button>

          <Button
            onClick={() => setDismissMethod('math')}
            variant="outline"
            className="w-full h-14 rounded-xl border-gray-200 text-base font-medium flex items-center justify-center gap-2"
          >
            <Calculator className="w-5 h-5" />
            Solve Math Problem
          </Button>

          <Button
            onClick={() => setDismissMethod('slide')}
            variant="outline"
            className="w-full h-14 rounded-xl border-gray-200 text-base font-medium flex items-center justify-center gap-2"
          >
            <SlidersHorizontal className="w-5 h-5" />
            Slide to Dismiss
          </Button>

          <Button
            onClick={() => setDismissMethod('shake')}
            variant="outline"
            className="w-full h-14 rounded-xl border-gray-200 text-base font-medium flex items-center justify-center gap-2"
          >
            <Smartphone className="w-5 h-5" />
            Shake Phone
          </Button>
        </div>
      )}

      {/* Math Problem */}
      {dismissMethod === 'math' && (
        <Card className="w-full max-w-md p-6 border-gray-100 shadow-lg">
          <div className="text-center mb-4">
            <p className="text-4xl font-bold text-black mb-6">
              {num1} + {num2} = ?
            </p>
            <Input
              type="number"
              placeholder="Enter answer"
              value={mathAnswer}
              onChange={(e) => setMathAnswer(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && handleMathSubmit()}
              className="h-14 rounded-xl border-gray-200 text-center text-xl mb-4"
              autoFocus
            />
            <Button
              onClick={handleMathSubmit}
              className="w-full h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-xl"
            >
              Submit
            </Button>
          </div>
        </Card>
      )}

      {/* Slider */}
      {dismissMethod === 'slide' && (
        <Card className="w-full max-w-md p-6 border-gray-100 shadow-lg">
          <p className="text-center text-gray-600 mb-4">Slide to dismiss alarm</p>
          <Slider
            value={sliderValue}
            onValueChange={setSliderValue}
            max={100}
            step={1}
            className="mb-4"
          />
          <div className="text-center text-2xl font-bold text-blue-600">
            {sliderValue[0]}%
          </div>
        </Card>
      )}

      {/* Shake Indicator */}
      {dismissMethod === 'shake' && (
        <Card className="w-full max-w-md p-8 border-gray-100 shadow-lg text-center">
          <Smartphone className={`w-16 h-16 mx-auto mb-4 ${shakeDetected ? 'text-green-600' : 'text-gray-400'}`} />
          <p className="text-lg font-medium text-gray-700">
            {shakeDetected ? 'Shake detected!' : 'Shake your phone to dismiss'}
          </p>
        </Card>
      )}

      {dismissMethod && dismissMethod !== 'math' && (
        <Button
          onClick={() => setDismissMethod(null)}
          variant="ghost"
          className="mt-4 text-gray-500"
        >
          Choose different method
        </Button>
      )}
    </div>
  );
}
