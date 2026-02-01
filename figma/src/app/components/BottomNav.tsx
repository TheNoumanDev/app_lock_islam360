import { Home, Lock, AlarmClock, Clock, BookOpen } from 'lucide-react';

export type Tab = 'home' | 'locked-apps' | 'alarms' | 'prayer-times' | 'quran';

interface BottomNavProps {
  activeTab: Tab;
  onTabChange: (tab: Tab) => void;
}

export function BottomNav({ activeTab, onTabChange }: BottomNavProps) {
  const tabs = [
    { id: 'home' as Tab, icon: Home, label: 'Home' },
    { id: 'locked-apps' as Tab, icon: Lock, label: 'Apps' },
    { id: 'alarms' as Tab, icon: AlarmClock, label: 'Alarms' },
    { id: 'prayer-times' as Tab, icon: Clock, label: 'Prayer' },
    { id: 'quran' as Tab, icon: BookOpen, label: 'Quran' },
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 safe-area-bottom">
      <div className="max-w-4xl mx-auto">
        <div className="grid grid-cols-5 h-16">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.id;
            
            return (
              <button
                key={tab.id}
                onClick={() => onTabChange(tab.id)}
                className={`flex flex-col items-center justify-center gap-1 transition-colors ${
                  isActive ? 'text-blue-600' : 'text-gray-400'
                }`}
              >
                <Icon className={`w-5 h-5 ${isActive ? 'fill-blue-600/10' : ''}`} />
                <span className="text-xs font-medium">{tab.label}</span>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
