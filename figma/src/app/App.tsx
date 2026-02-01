import { useState, useEffect } from 'react';
import { Onboarding } from '@/app/screens/Onboarding';
import { HomeScreen } from '@/app/screens/HomeScreen';
import { ProfileScreen } from '@/app/screens/ProfileScreen';
import { AppLockInputScreen } from '@/app/screens/AppLockInputScreen';
import { AyatDisplayScreen } from '@/app/screens/AyatDisplayScreen';
import { AlarmDismissalScreen } from '@/app/screens/AlarmDismissalScreen';
import { BottomNavigation, NavTab } from '@/app/components/BottomNavigation';
import { LockedApps, Settings } from '@/app/components/LockedApps';
import { Alarms, Alarm } from '@/app/components/Alarms';
import { PrayerTimesMinimal } from '@/app/components/PrayerTimesMinimal';
import { QuranRecitation } from '@/app/components/QuranRecitation';

type Screen = 'onboarding' | 'home' | 'profile' | 'app-lock-input' | 'ayat-display' | 'alarm-dismissal' | 'main-tabs';

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('onboarding');
  const [activeTab, setActiveTab] = useState<NavTab>('home');
  const [currentFeeling, setCurrentFeeling] = useState('');
  
  // App state
  const [settings, setSettings] = useState<Settings>({
    requireFeeling: true,
    requirePassword: false,
    password: '',
    contentFrequency: 'once',
    apps: [
      { name: 'Instagram', enabled: true, frequency: 'every-time' },
      { name: 'TikTok', enabled: true, frequency: 'once' },
      { name: 'Twitter', enabled: true, frequency: 'prayer-times' },
      { name: 'YouTube', enabled: false, frequency: 'every-time' },
      { name: 'Facebook', enabled: false, frequency: 'twice' },
    ]
  });

  const [alarms, setAlarms] = useState<Alarm[]>([
    {
      id: '1',
      time: '06:00',
      label: 'Fajr Reminder',
      enabled: true,
      days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
    }
  ]);

  // Check if user has completed onboarding
  useEffect(() => {
    const hasCompletedOnboarding = localStorage.getItem('hasCompletedOnboarding');
    if (hasCompletedOnboarding) {
      setCurrentScreen('main-tabs');
    }
  }, []);

  const handleOnboardingComplete = () => {
    localStorage.setItem('hasCompletedOnboarding', 'true');
    setCurrentScreen('main-tabs');
  };

  const handleNavigate = (destination: string) => {
    if (destination === 'profile') {
      setCurrentScreen('profile');
    } else if (destination === 'apps' || destination === 'alarms' || destination === 'prayer' || destination === 'quran') {
      setActiveTab(destination as NavTab);
      setCurrentScreen('main-tabs');
    } else if (destination === 'test-lock') {
      setCurrentScreen('app-lock-input');
    } else if (destination === 'test-alarm') {
      setCurrentScreen('alarm-dismissal');
    }
  };

  const handleFeelingSubmit = (feeling: string) => {
    setCurrentFeeling(feeling);
    setCurrentScreen('ayat-display');
  };

  const handleAyatComplete = () => {
    setCurrentScreen('main-tabs');
    setActiveTab('home');
  };

  const handleAlarmDismiss = () => {
    setCurrentScreen('main-tabs');
    setActiveTab('home');
  };

  // Render appropriate screen
  if (currentScreen === 'onboarding') {
    return <Onboarding onComplete={handleOnboardingComplete} />;
  }

  if (currentScreen === 'profile') {
    return <ProfileScreen onBack={() => setCurrentScreen('main-tabs')} />;
  }

  if (currentScreen === 'app-lock-input') {
    return (
      <AppLockInputScreen
        appName="Instagram"
        onSubmit={handleFeelingSubmit}
      />
    );
  }

  if (currentScreen === 'ayat-display') {
    return (
      <AyatDisplayScreen
        feeling={currentFeeling}
        onComplete={handleAyatComplete}
        onSkip={handleAyatComplete}
      />
    );
  }

  if (currentScreen === 'alarm-dismissal') {
    return (
      <AlarmDismissalScreen
        time="06:00 AM"
        label="Fajr Reminder"
        onDismiss={handleAlarmDismiss}
      />
    );
  }

  // Main app with tabs
  return (
    <div className="size-full">
      {activeTab === 'home' && (
        <HomeScreen onNavigate={handleNavigate} />
      )}

      {activeTab === 'apps' && (
        <div className="min-h-screen pb-24">
          <LockedApps
            settings={settings}
            onSettingsChange={setSettings}
            onTestLock={() => handleNavigate('test-lock')}
          />
        </div>
      )}

      {activeTab === 'alarms' && (
        <div className="min-h-screen pb-24">
          <Alarms
            alarms={alarms}
            onAlarmsChange={setAlarms}
          />
          <div className="px-6 pb-6">
            <button
              onClick={() => handleNavigate('test-alarm')}
              className="text-sm text-blue-600 hover:underline"
            >
              Test alarm dismissal →
            </button>
          </div>
        </div>
      )}

      {activeTab === 'prayer' && (
        <div className="min-h-screen pb-24">
          <PrayerTimesMinimal />
        </div>
      )}

      {activeTab === 'quran' && (
        <div className="min-h-screen pb-24">
          <QuranRecitation />
        </div>
      )}

      <BottomNavigation activeTab={activeTab} onTabChange={setActiveTab} />
    </div>
  );
}