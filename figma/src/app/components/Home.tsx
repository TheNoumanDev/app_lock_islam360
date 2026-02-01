import { useState } from 'react';
import { Button } from '@/app/components/ui/button';
import { Card } from '@/app/components/ui/card';
import { PrayerVessel } from '@/app/components/PrayerVessel';
import { 
  ChevronRight, 
  Lock, 
  AlarmClock, 
  Clock as ClockIcon,
  BookOpen,
  Flame
} from 'lucide-react';
import { getNextPrayer, getTodaysPrayerTimes } from '@/app/data/prayerTimes';

interface HomeProps {
  namazStreak: number;
  ayatStreak: number;
  lockStreak: number;
  onNavigate: (tab: string) => void;
}

export function Home({ namazStreak, ayatStreak, lockStreak, onNavigate }: HomeProps) {
  const nextPrayer = getNextPrayer();
  const todaysPrayers = getTodaysPrayerTimes();
  const completedPrayers = todaysPrayers.filter(p => p.completed).length;

  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-50 to-white pb-20">
      {/* Header */}
      <div className="bg-white border-b border-gray-100">
        <div className="max-w-4xl mx-auto px-6 py-6">
          <div>
            <h1 className="text-2xl font-bold text-black">Islam360</h1>
            <p className="text-sm text-gray-600 mt-1">As-salamu alaykum</p>
          </div>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-6 py-6 space-y-6">
        {/* Prayer Vessel */}
        <Card className="p-6 border-gray-100 shadow-sm">
          <div className="text-center mb-4">
            <h3 className="text-lg font-semibold text-black">Today's Prayers</h3>
            <p className="text-sm text-gray-600">Next: {nextPrayer.name} in {nextPrayer.timeUntil}</p>
          </div>
          <PrayerVessel 
            completedPrayers={completedPrayers} 
            totalPrayers={todaysPrayers.length} 
          />
        </Card>

        {/* Compact Streaks */}
        <div className="grid grid-cols-3 gap-3">
          <Card className="p-3 text-center border-gray-100 shadow-sm">
            <div className="flex items-center justify-center gap-1 mb-1">
              <ClockIcon className="w-4 h-4 text-green-600" />
              <Flame className="w-3 h-3 text-orange-500" />
            </div>
            <div className="text-xl font-bold text-black">{namazStreak}</div>
            <div className="text-xs text-gray-600">Namaz</div>
          </Card>

          <Card className="p-3 text-center border-gray-100 shadow-sm">
            <div className="flex items-center justify-center gap-1 mb-1">
              <BookOpen className="w-4 h-4 text-purple-600" />
              <Flame className="w-3 h-3 text-orange-500" />
            </div>
            <div className="text-xl font-bold text-black">{ayatStreak}</div>
            <div className="text-xs text-gray-600">Quran</div>
          </Card>

          <Card className="p-3 text-center border-gray-100 shadow-sm">
            <div className="flex items-center justify-center gap-1 mb-1">
              <Lock className="w-4 h-4 text-blue-600" />
              <Flame className="w-3 h-3 text-orange-500" />
            </div>
            <div className="text-xl font-bold text-black">{lockStreak}</div>
            <div className="text-xs text-gray-600">App Lock</div>
          </Card>
        </div>

        {/* Quick Actions */}
        <div className="space-y-3">
          <h3 className="text-lg font-semibold text-black px-2">Quick Actions</h3>
          
          <Card 
            className="p-4 border-gray-100 shadow-sm cursor-pointer hover:bg-gray-50 transition-colors"
            onClick={() => onNavigate('locked-apps')}
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-blue-50 rounded-xl flex items-center justify-center">
                  <Lock className="w-6 h-6 text-blue-600" />
                </div>
                <div>
                  <h4 className="font-semibold text-black">App Lock</h4>
                  <p className="text-sm text-gray-600">Manage locked apps</p>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </div>
          </Card>

          <Card 
            className="p-4 border-gray-100 shadow-sm cursor-pointer hover:bg-gray-50 transition-colors"
            onClick={() => onNavigate('alarms')}
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-orange-50 rounded-xl flex items-center justify-center">
                  <AlarmClock className="w-6 h-6 text-orange-600" />
                </div>
                <div>
                  <h4 className="font-semibold text-black">Islamic Alarms</h4>
                  <p className="text-sm text-gray-600">Set mindful reminders</p>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </div>
          </Card>

          <Card 
            className="p-4 border-gray-100 shadow-sm cursor-pointer hover:bg-gray-50 transition-colors"
            onClick={() => onNavigate('quran')}
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-green-50 rounded-xl flex items-center justify-center">
                  <BookOpen className="w-6 h-6 text-green-600" />
                </div>
                <div>
                  <h4 className="font-semibold text-black">Quran Recitation</h4>
                  <p className="text-sm text-gray-600">Read and reflect</p>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </div>
          </Card>
        </div>

        {/* Info */}
        <div className="bg-blue-50 rounded-xl p-4 text-center">
          <p className="text-sm text-gray-700">
            Made with ❤️ by{' '}
            <a
              href="https://github.com/theDumbNetwork"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 font-medium hover:underline"
            >
              theDumbNetwork
            </a>
          </p>
        </div>
      </div>
    </div>
  );
}