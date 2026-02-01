import { useState } from 'react';
import { Button } from '@/app/components/ui/button';
import { Input } from '@/app/components/ui/input';
import { Lock } from 'lucide-react';

interface AppLockInputScreenProps {
  appName: string;
  onSubmit: (feeling: string) => void;
}

const predefinedFeelings = [
  'Stressed',
  'Anxious',
  'Bored',
  'Sad',
  'Ungrateful',
  'Angry',
  'Frustrated',
  'Distracted',
  'Lonely',
  'Overwhelmed'
];

export function AppLockInputScreen({ appName, onSubmit }: AppLockInputScreenProps) {
  const [customFeeling, setCustomFeeling] = useState('');

  return (
    <div className="min-h-screen bg-white flex flex-col items-center justify-center px-6">
      {/* Icon */}
      <div className="w-24 h-24 bg-blue-50 rounded-full flex items-center justify-center mb-6">
        <Lock className="w-12 h-12 text-blue-600" />
      </div>

      {/* App Name */}
      <h2 className="text-2xl font-bold text-black mb-2">{appName}</h2>

      {/* Question */}
      <p className="text-gray-600 text-center mb-8">
        How are you feeling right now?
      </p>

      {/* Text Input */}
      <div className="w-full max-w-md mb-6">
        <Input
          placeholder="Why am I reaching for this app?"
          value={customFeeling}
          onChange={(e) => setCustomFeeling(e.target.value)}
          className="h-14 rounded-xl border-gray-200 text-base"
          onKeyPress={(e) => {
            if (e.key === 'Enter' && customFeeling.trim()) {
              onSubmit(customFeeling);
            }
          }}
        />
        <Button
          onClick={() => onSubmit(customFeeling)}
          disabled={!customFeeling.trim()}
          className="w-full h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-xl mt-3"
        >
          Continue
        </Button>
      </div>

      {/* Divider */}
      <div className="w-full max-w-md flex items-center gap-4 my-6">
        <div className="flex-1 h-px bg-gray-200"></div>
        <span className="text-sm text-gray-500">or choose from below</span>
        <div className="flex-1 h-px bg-gray-200"></div>
      </div>

      {/* Predefined Feelings */}
      <div className="w-full max-w-md flex flex-wrap gap-2 justify-center">
        {predefinedFeelings.map((feeling) => (
          <button
            key={feeling}
            onClick={() => onSubmit(feeling)}
            className="px-5 py-2.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-sm font-medium transition-colors"
          >
            {feeling}
          </button>
        ))}
      </div>
    </div>
  );
}
