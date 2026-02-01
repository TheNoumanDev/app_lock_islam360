import { Home, Lock, AlarmClock, Clock, BookOpen } from 'lucide-react';

export type NavTab = 'home' | 'apps' | 'alarms' | 'prayer' | 'quran';

interface BottomNavigationProps {
  activeTab: NavTab;
  onTabChange: (tab: NavTab) => void;
}

export function BottomNavigation({ activeTab, onTabChange }: BottomNavigationProps) {
  const tabs: Array<{ id: NavTab; icon: typeof Home; label: string }> = [
    { id: 'home', icon: Home, label: 'Home' },
    { id: 'apps', icon: Lock, label: 'Apps' },
    { id: 'alarms', icon: AlarmClock, label: 'Alarms' },
    { id: 'prayer', icon: Clock, label: 'Prayer' },
    { id: 'quran', icon: BookOpen, label: 'Quran' },
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 safe-area-bottom z-50">
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
                <Icon className={`w-5 h-5 ${isActive ? 'fill-blue-600/20' : ''}`} />
                <span className="text-xs font-medium">{tab.label}</span>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
