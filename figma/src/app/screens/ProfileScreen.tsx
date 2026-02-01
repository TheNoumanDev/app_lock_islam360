import { Card } from '@/app/components/ui/card';
import { Button } from '@/app/components/ui/button';
import { ChevronLeft, ChevronRight, User, MapPin, Bell, CreditCard, Lock, AlarmClock, Info, Shield, Heart, Trophy, Star, Medal, BookOpen, Zap, Target } from 'lucide-react';

interface ProfileScreenProps {
  onBack: () => void;
}

export function ProfileScreen({ onBack }: ProfileScreenProps) {
  const settingsItems = [
    { icon: MapPin, label: 'Prayer Calculation Method', value: 'Hanafi - Karachi University', color: 'text-green-600', bg: 'bg-green-50' },
    { icon: MapPin, label: 'Location Settings', value: 'Karachi, Pakistan', color: 'text-blue-600', bg: 'bg-blue-50' },
    { icon: Bell, label: 'Notification Preferences', value: 'Enabled', color: 'text-orange-600', bg: 'bg-orange-50' },
    { icon: CreditCard, label: 'Subscription Status', value: 'Free', color: 'text-purple-600', bg: 'bg-purple-50' },
    { icon: Lock, label: 'App Lock Settings', value: '', color: 'text-blue-600', bg: 'bg-blue-50' },
    { icon: AlarmClock, label: 'Alarm Settings', value: '', color: 'text-orange-600', bg: 'bg-orange-50' },
    { icon: Info, label: 'About & Support', value: '', color: 'text-gray-600', bg: 'bg-gray-50' },
    { icon: Shield, label: 'Privacy Policy', value: '', color: 'text-gray-600', bg: 'bg-gray-50' },
  ];

  const achievements = [
    { icon: Trophy, label: 'First Reflection', unlocked: true, color: 'text-blue-600', bg: 'bg-blue-50' },
    { icon: Star, label: 'Daily Devotion I', unlocked: true, color: 'text-yellow-600', bg: 'bg-yellow-50' },
    { icon: Medal, label: 'Namaz Punctual', unlocked: false, color: 'text-gray-400', bg: 'bg-gray-100' },
    { icon: BookOpen, label: 'Quran Explorer', unlocked: true, color: 'text-green-600', bg: 'bg-green-50' },
    { icon: Zap, label: 'Spiritual Growth', unlocked: true, color: 'text-purple-600', bg: 'bg-purple-50' },
    { icon: Target, label: 'Faith Keeper', unlocked: false, color: 'text-gray-400', bg: 'bg-gray-100' },
  ];

  return (
    <div className="min-h-screen bg-white pb-24">
      {/* Header */}
      <div className="bg-white border-b border-gray-100 px-6 py-6">
        <div className="flex items-center gap-4">
          <button
            onClick={onBack}
            className="w-10 h-10 rounded-full hover:bg-gray-100 flex items-center justify-center transition-colors"
          >
            <ChevronLeft className="w-6 h-6 text-gray-700" />
          </button>
          <h1 className="text-2xl font-bold text-black">Profile</h1>
        </div>
      </div>

      <div className="px-6 py-6 space-y-6">
        {/* User Section */}
        <Card className="p-6 border-gray-100 shadow-sm text-center">
          <div className="w-24 h-24 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center mx-auto mb-4">
            <User className="w-12 h-12 text-white" />
          </div>
          <h2 className="text-xl font-bold text-black mb-1">Guest User</h2>
          <p className="text-sm text-gray-600 mb-4">guest@islamlock.app</p>
          <Button variant="outline" className="rounded-xl border-gray-200">
            Edit Profile
          </Button>
        </Card>

        {/* Achievements Section */}
        <div className="space-y-3">
          <h3 className="text-lg font-semibold text-black px-2">Achievements</h3>
          <div className="grid grid-cols-3 gap-3">
            {achievements.map((achievement, index) => {
              const Icon = achievement.icon;
              return (
                <Card
                  key={index}
                  className={`p-4 border-gray-100 shadow-sm text-center ${
                    achievement.unlocked ? '' : 'opacity-60'
                  }`}
                >
                  <div className={`w-12 h-12 ${achievement.bg} rounded-xl flex items-center justify-center mx-auto mb-2`}>
                    <Icon className={`w-6 h-6 ${achievement.color}`} />
                  </div>
                  <p className="text-xs font-medium text-gray-700 leading-tight">
                    {achievement.label}
                  </p>
                  {achievement.unlocked && (
                    <div className="mt-1">
                      <span className="text-xs text-green-600">✓</span>
                    </div>
                  )}
                </Card>
              );
            })}
          </div>
        </div>

        {/* Settings List */}
        <div className="space-y-3">
          <h3 className="text-lg font-semibold text-black px-2">Settings</h3>
          
          {settingsItems.map((item, index) => {
            const Icon = item.icon;
            return (
              <Card 
                key={index}
                className="p-4 border-gray-100 shadow-sm cursor-pointer hover:bg-gray-50 transition-colors"
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className={`w-10 h-10 ${item.bg} rounded-xl flex items-center justify-center`}>
                      <Icon className={`w-5 h-5 ${item.color}`} />
                    </div>
                    <div>
                      <h4 className="font-medium text-black">{item.label}</h4>
                      {item.value && (
                        <p className="text-sm text-gray-500">{item.value}</p>
                      )}
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-gray-400" />
                </div>
              </Card>
            );
          })}
        </div>

        {/* Footer */}
        <div className="text-center pt-6 space-y-2">
          <p className="text-sm text-gray-500">Version 1.0.0</p>
          <p className="text-sm text-gray-700">
            Made with <Heart className="w-4 h-4 inline text-red-500 fill-red-500" /> by{' '}
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