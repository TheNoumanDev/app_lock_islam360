import { Flame } from 'lucide-react';

interface StreakDisplayProps {
  streak: number;
}

export function StreakDisplay({ streak }: StreakDisplayProps) {
  return (
    <div className="bg-white rounded-2xl p-8 shadow-sm border border-gray-100">
      <div className="flex flex-col items-center gap-4">
        <div className="relative">
          <div className="w-24 h-24 bg-blue-50 rounded-full flex items-center justify-center">
            <Flame className="w-12 h-12 text-blue-600" />
          </div>
          {streak > 0 && (
            <div className="absolute -top-1 -right-1 bg-blue-600 text-white w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold">
              {streak}
            </div>
          )}
        </div>
        <div className="text-center">
          <h3 className="text-2xl font-semibold text-black mb-1">Noor Streak</h3>
          <p className="text-gray-600 text-sm">
            {streak === 0 ? 'Start your journey' : `${streak} day${streak > 1 ? 's' : ''} of reflection`}
          </p>
        </div>
      </div>
    </div>
  );
}
