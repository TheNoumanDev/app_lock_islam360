import { useState, useEffect } from 'react';
import { Card } from '@/app/components/ui/card';
import { Switch } from '@/app/components/ui/switch';
import { Button } from '@/app/components/ui/button';
import { Sun, Moon, Sunrise, Sunset, Star, ChevronLeft, ChevronRight, Download, Calendar as CalendarIcon } from 'lucide-react';

export function PrayerTimesMinimal() {
  const [calendarSyncEnabled, setCalendarSyncEnabled] = useState(false);
  const [currentMonth, setCurrentMonth] = useState(new Date());
  const [namazStreak, setNamazStreak] = useState(25);

  const prayers = [
    { name: 'Fajr', time: '5:30 AM', icon: Sunrise, completed: false, current: true },
    { name: 'Dhuhr', time: '1:15 PM', icon: Sun, completed: false, current: false },
    { name: 'Asr', time: '4:45 PM', icon: Sun, completed: false, current: false },
    { name: 'Maghrib', time: '7:10 PM', icon: Sunset, completed: false, current: false },
    { name: 'Isha', time: '8:30 PM', icon: Moon, completed: false, current: false },
  ];

  // Get next prayer
  const nextPrayer = prayers[0];
  const [timeUntil, setTimeUntil] = useState('00:45:20');

  // Countdown effect
  useEffect(() => {
    const timer = setInterval(() => {
      // This is a mock countdown - in real app, calculate actual time difference
      const parts = timeUntil.split(':');
      let hours = parseInt(parts[0]);
      let minutes = parseInt(parts[1]);
      let seconds = parseInt(parts[2]);

      seconds--;
      if (seconds < 0) {
        seconds = 59;
        minutes--;
        if (minutes < 0) {
          minutes = 59;
          hours--;
          if (hours < 0) {
            hours = 0;
            minutes = 0;
            seconds = 0;
          }
        }
      }

      setTimeUntil(
        `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`
      );
    }, 1000);

    return () => clearInterval(timer);
  }, [timeUntil]);

  // Calendar generation
  const getDaysInMonth = (date: Date) => {
    const year = date.getFullYear();
    const month = date.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const daysInMonth = lastDay.getDate();
    const startingDayOfWeek = firstDay.getDay();

    const days = [];
    for (let i = 0; i < startingDayOfWeek; i++) {
      days.push(null);
    }
    for (let i = 1; i <= daysInMonth; i++) {
      days.push(i);
    }
    return days;
  };

  const days = getDaysInMonth(currentMonth);
  const monthName = currentMonth.toLocaleString('default', { month: 'long', year: 'numeric' });
  const today = new Date().getDate();

  const handlePreviousMonth = () => {
    setCurrentMonth(new Date(currentMonth.getFullYear(), currentMonth.getMonth() - 1));
  };

  const handleNextMonth = () => {
    setCurrentMonth(new Date(currentMonth.getFullYear(), currentMonth.getMonth() + 1));
  };

  const handleSyncToCalendar = () => {
    setCalendarSyncEnabled(true);
    // Generate and download ICS file
  };

  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <div className="bg-white border-b border-gray-100 px-6 py-6">
        <h1 className="text-2xl font-bold text-black text-center">Namaz</h1>
      </div>

      <div className="px-6 py-6 space-y-6 max-w-md mx-auto">
        {/* Next Prayer Card */}
        <Card className="p-6 border-gray-100 shadow-sm text-center">
          <div className="flex items-center justify-center gap-2 mb-3">
            <Sunrise className="w-5 h-5 text-blue-600" />
            <h3 className="text-lg font-semibold text-black">{nextPrayer.name}</h3>
          </div>
          <div className="text-5xl font-bold text-blue-600 mb-2">{timeUntil}</div>
          <p className="text-sm text-gray-600">{nextPrayer.time}</p>
        </Card>

        {/* Today's Prayer Times */}
        <div className="space-y-2">
          <h3 className="text-base font-semibold text-black mb-3">Today's Prayer Times</h3>
          {prayers.map((prayer, index) => {
            const Icon = prayer.icon;
            return (
              <div
                key={prayer.name}
                className={`flex items-center justify-between py-3 px-4 rounded-xl transition-colors ${
                  prayer.current ? 'bg-blue-50 border-2 border-blue-600' : 'border border-gray-200'
                }`}
              >
                <div className="flex items-center gap-3">
                  <Icon className={`w-5 h-5 ${prayer.current ? 'text-blue-600' : 'text-gray-600'}`} />
                  <span className={`font-medium ${prayer.current ? 'text-blue-600' : 'text-black'}`}>
                    {prayer.name}
                  </span>
                </div>
                <span className={`font-semibold ${prayer.current ? 'text-blue-600' : 'text-gray-900'}`}>
                  {prayer.time}
                </span>
              </div>
            );
          })}
        </div>

        {/* Sync with Calendar */}
        <Card className="p-4 border-gray-100 shadow-sm">
          <div className="flex items-center justify-between">
            <div>
              <h4 className="font-medium text-black">Sync with Calendar</h4>
              <p className="text-xs text-gray-500">Add prayer times to your device calendar</p>
            </div>
            <Switch
              checked={calendarSyncEnabled}
              onCheckedChange={() => !calendarSyncEnabled && handleSyncToCalendar()}
            />
          </div>
        </Card>

        {/* Calendar */}
        <Card className="p-4 border-gray-100 shadow-sm">
          {/* Calendar Header */}
          <div className="flex items-center justify-between mb-4">
            <button
              onClick={handlePreviousMonth}
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <ChevronLeft className="w-5 h-5 text-gray-600" />
            </button>
            <h4 className="font-semibold text-blue-600">{monthName}</h4>
            <button
              onClick={handleNextMonth}
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <ChevronRight className="w-5 h-5 text-gray-600" />
            </button>
          </div>

          {/* Day labels */}
          <div className="grid grid-cols-7 gap-1 mb-2">
            {['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) => (
              <div key={day} className="text-center text-xs font-medium text-gray-500 py-1">
                {day}
              </div>
            ))}
          </div>

          {/* Calendar days */}
          <div className="grid grid-cols-7 gap-1">
            {days.map((day, index) => (
              <div
                key={index}
                className={`aspect-square flex items-center justify-center text-sm rounded-lg ${
                  day === null
                    ? ''
                    : day === today
                    ? 'bg-blue-600 text-white font-semibold'
                    : 'text-gray-700 hover:bg-gray-100 cursor-pointer'
                }`}
              >
                {day}
              </div>
            ))}
          </div>
        </Card>

        {/* Namaz Streaks */}
        <Card className="p-6 border-gray-100 shadow-sm text-center">
          <div className="flex items-center justify-center gap-2 mb-3">
            <Star className="w-6 h-6 text-blue-600" />
            <h3 className="text-base font-semibold text-black">Namaz Streaks</h3>
          </div>
          <div className="text-5xl font-bold text-blue-600 mb-2">{namazStreak}</div>
          <p className="text-sm text-gray-600">Consecutive days of prayer!</p>
        </Card>
      </div>
    </div>
  );
}
