import { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { Card } from '@/app/components/ui/card';
import { User, MapPin, ChevronRight, Flame, Lock, AlarmClock, BookOpen, Clock, Home as HomeIcon } from 'lucide-react';

interface HomeScreenProps {
  onNavigate: (screen: string) => void;
}

export function HomeScreen({ onNavigate }: HomeScreenProps) {
  const [countdown, setCountdown] = useState({ hours: 2, minutes: 45, seconds: 10 });
  
  const prayers = [
    { name: 'Fajr', time: '05:30', completed: true },
    { name: 'Dhuhr', time: '12:45', completed: true },
    { name: 'Asr', time: '15:30', current: true },
    { name: 'Maghrib', time: '18:15', completed: false },
    { name: 'Isha', time: '19:45', completed: false },
  ];

  const completedCount = prayers.filter(p => p.completed).length;
  const totalCount = prayers.length;
  const fillPercentage = (completedCount / totalCount) * 100;

  // Countdown timer effect
  useEffect(() => {
    const timer = setInterval(() => {
      setCountdown(prev => {
        if (prev.seconds > 0) {
          return { ...prev, seconds: prev.seconds - 1 };
        } else if (prev.minutes > 0) {
          return { ...prev, minutes: prev.minutes - 1, seconds: 59 };
        } else if (prev.hours > 0) {
          return { hours: prev.hours - 1, minutes: 59, seconds: 59 };
        }
        return prev;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  return (
    <div className="min-h-screen bg-white pb-24">
      {/* Header */}
      <div className="bg-white border-b border-gray-100 px-6 py-6">
        <div className="flex items-center justify-between mb-2">
          <h1 className="text-2xl font-bold text-black">Islam Lock</h1>
          <button 
            onClick={() => onNavigate('profile')}
            className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center hover:bg-gray-300 transition-colors"
          >
            <User className="w-5 h-5 text-gray-600" />
          </button>
        </div>
        <p className="text-sm text-gray-500">Transform distractions into dhikr</p>
      </div>

      <div className="px-6 py-6 space-y-6">
        {/* Prayer Widget with Animated Water Fill */}
        <Card className="relative overflow-hidden border-gray-100 shadow-lg">
          {/* Water Fill Background */}
          <motion.div
            className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-blue-400/20 to-blue-300/10"
            initial={{ height: 0 }}
            animate={{ height: `${fillPercentage}%` }}
            transition={{ duration: 1.5, ease: "easeOut" }}
          >
            {/* Wave Animation */}
            <svg className="absolute top-0 left-0 w-full" viewBox="0 0 1440 100" style={{ transform: 'translateY(-50%)' }}>
              <motion.path
                d="M0,50 Q360,20 720,50 T1440,50 L1440,100 L0,100 Z"
                fill="rgba(59, 130, 246, 0.15)"
                animate={{
                  d: [
                    "M0,50 Q360,20 720,50 T1440,50 L1440,100 L0,100 Z",
                    "M0,50 Q360,80 720,50 T1440,50 L1440,100 L0,100 Z",
                    "M0,50 Q360,20 720,50 T1440,50 L1440,100 L0,100 Z"
                  ]
                }}
                transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
              />
            </svg>
          </motion.div>

          {/* Content */}
          <div className="relative z-10 p-6">
            {/* Top Row */}
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-2 bg-white/80 backdrop-blur-sm px-3 py-1.5 rounded-full">
                <MapPin className="w-4 h-4 text-gray-600" />
                <span className="text-sm font-medium text-gray-700">Karachi</span>
              </div>
              <div className="bg-blue-600 text-white px-3 py-1.5 rounded-full text-sm font-medium">
                Hanafi
              </div>
            </div>

            {/* Center - Next Prayer */}
            <div className="text-center mb-6">
              <p className="text-xs text-gray-500 uppercase tracking-wider mb-2">Upcoming</p>
              <h2 className="text-5xl font-bold text-black mb-3">Asr</h2>
              <div className="text-4xl font-mono font-bold text-blue-600 mb-2">
                {String(countdown.hours).padStart(2, '0')}:
                {String(countdown.minutes).padStart(2, '0')}:
                {String(countdown.seconds).padStart(2, '0')}
              </div>
              <p className="text-sm text-gray-600">until Maghrib</p>
            </div>

            {/* Prayer Timeline */}
            <div className="flex justify-between gap-2">
              {prayers.map((prayer) => (
                <div
                  key={prayer.name}
                  className={`flex-1 rounded-xl px-2 py-3 text-center transition-all ${
                    prayer.completed
                      ? 'bg-blue-600 text-white'
                      : prayer.current
                      ? 'bg-white border-2 border-blue-600 text-blue-600'
                      : 'bg-gray-100 text-gray-500'
                  }`}
                >
                  <div className="text-xs font-semibold mb-1">{prayer.name}</div>
                  <div className="text-xs">{prayer.time}</div>
                  {prayer.completed && <div className="text-lg">✓</div>}
                </div>
              ))}
            </div>
          </div>
        </Card>

        {/* Continue Reading Widget */}
        <Card 
          onClick={() => onNavigate('quran')}
          className="p-4 border-gray-100 shadow-sm cursor-pointer hover:bg-gray-50 transition-colors"
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 bg-green-50 rounded-xl flex items-center justify-center">
                <BookOpen className="w-6 h-6 text-green-600" />
              </div>
              <div>
                <h4 className="font-semibold text-black">Continue Reading</h4>
                <p className="text-sm text-gray-600">Surah Al-Baqarah • Verse 142</p>
              </div>
            </div>
            <ChevronRight className="w-5 h-5 text-gray-400" />
          </div>
        </Card>

        {/* Noor Streaks Section */}
        <div className="space-y-3">
          <h3 className="text-lg font-semibold text-black">Noor Streaks</h3>
          
          <div className="grid grid-cols-2 gap-3">
            <Card className="p-4 border-gray-100 shadow-sm bg-blue-50/30">
              <div className="flex items-center gap-2 mb-3">
                <div className="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
                  <Lock className="w-5 h-5 text-blue-600" />
                </div>
                <div className="flex-1">
                  <p className="text-xs text-gray-600">App Lock</p>
                  <p className="text-xs text-gray-500">Reflections</p>
                </div>
              </div>
              <div className="text-3xl font-bold text-blue-600 mb-1">127</div>
              <p className="text-xs text-gray-600">Total moments of contemplation</p>
            </Card>

            <Card className="p-4 border-gray-100 shadow-sm bg-blue-50/30">
              <div className="flex items-center gap-2 mb-3">
                <div className="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
                  <Clock className="w-5 h-5 text-blue-600" />
                </div>
                <div className="flex-1">
                  <p className="text-xs text-gray-600">Namaz Streaks</p>
                </div>
              </div>
              <div className="text-3xl font-bold text-blue-600 mb-1">84</div>
              <p className="text-xs text-gray-600">Consecutive prayers offered</p>
            </Card>

            <Card className="p-4 border-gray-100 shadow-sm bg-purple-50/30">
              <div className="flex items-center gap-2 mb-3">
                <div className="w-10 h-10 bg-purple-100 rounded-xl flex items-center justify-center">
                  <BookOpen className="w-5 h-5 text-purple-600" />
                </div>
                <div className="flex-1">
                  <p className="text-xs text-gray-600">Ayat Readings</p>
                </div>
              </div>
              <div className="text-3xl font-bold text-purple-600 mb-1">205</div>
              <p className="text-xs text-gray-600">Verses recited from Quran</p>
            </Card>

            <Card className="p-4 border-gray-100 shadow-sm bg-green-50/30">
              <div className="flex items-center gap-2 mb-3">
                <div className="w-10 h-10 bg-green-100 rounded-xl flex items-center justify-center">
                  <Flame className="w-5 h-5 text-green-600" />
                </div>
                <div className="flex-1">
                  <p className="text-xs text-gray-600">Daily Engagement</p>
                </div>
              </div>
              <div className="text-3xl font-bold text-green-600 mb-1">23 Days</div>
              <p className="text-xs text-gray-600">Active spiritual journey</p>
            </Card>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="space-y-3">
          <h3 className="text-lg font-semibold text-black">Quick Actions</h3>
          
          <Card 
            onClick={() => onNavigate('apps')}
            className="p-4 border-gray-100 shadow-sm cursor-pointer hover:bg-gray-50 transition-colors"
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
            onClick={() => onNavigate('alarms')}
            className="p-4 border-gray-100 shadow-sm cursor-pointer hover:bg-gray-50 transition-colors"
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-orange-50 rounded-xl flex items-center justify-center">
                  <AlarmClock className="w-6 h-6 text-orange-600" />
                </div>
                <div>
                  <h4 className="font-semibold text-black">Islamic Alarms</h4>
                  <p className="text-sm text-gray-600">Mindful wake-up</p>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </div>
          </Card>

          <Card 
            onClick={() => onNavigate('quran')}
            className="p-4 border-gray-100 shadow-sm cursor-pointer hover:bg-gray-50 transition-colors"
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-green-50 rounded-xl flex items-center justify-center">
                  <BookOpen className="w-6 h-6 text-green-600" />
                </div>
                <div>
                  <h4 className="font-semibold text-black">Read Quran</h4>
                  <p className="text-sm text-gray-600">Continue your journey</p>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </div>
          </Card>
        </div>

        {/* Demo Buttons */}
        <div className="space-y-2 pt-4 border-t border-gray-200">
          <p className="text-xs text-gray-500 text-center mb-2">Demo Features</p>
          <div className="flex gap-2">
            <button
              onClick={() => onNavigate('test-lock')}
              className="flex-1 px-4 py-2 bg-blue-100 text-blue-700 rounded-lg text-sm font-medium hover:bg-blue-200 transition-colors"
            >
              Try App Lock
            </button>
            <button
              onClick={() => onNavigate('test-alarm')}
              className="flex-1 px-4 py-2 bg-orange-100 text-orange-700 rounded-lg text-sm font-medium hover:bg-orange-200 transition-colors"
            >
              Try Alarm
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}