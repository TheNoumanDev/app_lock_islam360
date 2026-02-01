import { useState } from 'react';
import { Button } from '@/app/components/ui/button';
import { Input } from '@/app/components/ui/input';
import { ScrollArea } from '@/app/components/ui/scroll-area';
import { Lock, ChevronRight } from 'lucide-react';
import { predefinedFeelings } from '@/app/data/islamicContent';

interface AppLockScreenProps {
  appName: string;
  onFeelingSubmit: (feeling: string) => void;
  onPasswordSubmit: (password: string) => void;
  requireFeeling: boolean;
  requirePassword: boolean;
}

export function AppLockScreen({ 
  appName, 
  onFeelingSubmit, 
  onPasswordSubmit,
  requireFeeling,
  requirePassword 
}: AppLockScreenProps) {
  const [mode, setMode] = useState<'feeling' | 'password'>(requireFeeling ? 'feeling' : 'password');
  const [customFeeling, setCustomFeeling] = useState('');
  const [password, setPassword] = useState('');

  const handleFeelingSelect = (feeling: string) => {
    onFeelingSubmit(feeling);
  };

  const handleCustomFeelingSubmit = () => {
    if (customFeeling.trim()) {
      onFeelingSubmit(customFeeling);
    }
  };

  const handlePasswordSubmit = () => {
    onPasswordSubmit(password);
  };

  if (mode === 'password' || !requireFeeling) {
    return (
      <div className="min-h-screen bg-white flex items-center justify-center p-6">
        <div className="max-w-md w-full space-y-6">
          {/* Lock Icon */}
          <div className="flex justify-center">
            <div className="w-20 h-20 bg-blue-50 rounded-full flex items-center justify-center">
              <Lock className="w-10 h-10 text-blue-600" />
            </div>
          </div>

          {/* App Name */}
          <div className="text-center">
            <h2 className="text-2xl font-semibold text-black mb-2">{appName}</h2>
            <p className="text-gray-600 text-sm">Enter password to continue</p>
          </div>

          {/* Password Input */}
          <div className="space-y-4">
            <Input
              type="password"
              placeholder="Enter password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && handlePasswordSubmit()}
              className="h-14 rounded-xl border-gray-200 text-base"
            />
            <Button
              onClick={handlePasswordSubmit}
              className="w-full h-14 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-base font-medium"
            >
              Unlock
            </Button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-white flex items-center justify-center p-6">
      <div className="max-w-md w-full space-y-6">
        {/* Lock Icon */}
        <div className="flex justify-center">
          <div className="w-20 h-20 bg-blue-50 rounded-full flex items-center justify-center">
            <Lock className="w-10 h-10 text-blue-600" />
          </div>
        </div>

        {/* App Name */}
        <div className="text-center">
          <h2 className="text-2xl font-semibold text-black mb-2">{appName}</h2>
          <p className="text-gray-600 text-sm">How are you feeling right now?</p>
        </div>

        {/* Custom Input */}
        <div className="space-y-3">
          <Input
            placeholder="Type your feeling or situation..."
            value={customFeeling}
            onChange={(e) => setCustomFeeling(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && handleCustomFeelingSubmit()}
            className="h-14 rounded-xl border-gray-200 text-base"
          />
          <Button
            onClick={handleCustomFeelingSubmit}
            disabled={!customFeeling.trim()}
            className="w-full h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-base font-medium disabled:bg-gray-200 disabled:text-gray-400"
          >
            Continue
          </Button>
        </div>

        {/* Divider */}
        <div className="relative">
          <div className="absolute inset-0 flex items-center">
            <div className="w-full border-t border-gray-200"></div>
          </div>
          <div className="relative flex justify-center text-sm">
            <span className="px-4 bg-white text-gray-500">or choose from below</span>
          </div>
        </div>

        {/* Predefined Feelings */}
        <ScrollArea className="h-64 rounded-xl border border-gray-200 p-2">
          <div className="space-y-2">
            {predefinedFeelings.map((feeling) => (
              <button
                key={feeling}
                onClick={() => handleFeelingSelect(feeling)}
                className="w-full flex items-center justify-between p-4 rounded-lg hover:bg-blue-50 transition-colors group"
              >
                <span className="text-black font-medium">{feeling}</span>
                <ChevronRight className="w-5 h-5 text-gray-400 group-hover:text-blue-600 transition-colors" />
              </button>
            ))}
          </div>
        </ScrollArea>
      </div>
    </div>
  );
}
