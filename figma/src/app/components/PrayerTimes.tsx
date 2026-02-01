import { useState } from 'react';
import { Button } from '@/app/components/ui/button';
import { Card } from '@/app/components/ui/card';
import { Switch } from '@/app/components/ui/switch';
import { Input } from '@/app/components/ui/input';
import { Label } from '@/app/components/ui/label';
import { Calendar, MapPin, Download, Clock, Check, Settings as SettingsIcon } from 'lucide-react';
import { getTodaysPrayerTimes, generatePrayerCalendarEvents } from '@/app/data/prayerTimes';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/app/components/ui/select';
import { calculationMethods, asrMethods, highLatitudeRules, defaultPrayerSettings, PrayerSettings } from '@/app/data/prayerSettings';

export function PrayerTimes() {
  const [prayers, setPrayers] = useState(getTodaysPrayerTimes());
  const [calendarSyncEnabled, setCalendarSyncEnabled] = useState(false);
  const [showSettings, setShowSettings] = useState(false);
  const [settings, setSettings] = useState<PrayerSettings>(defaultPrayerSettings);

  const handleTogglePrayer = (index: number) => {
    const newPrayers = [...prayers];
    newPrayers[index].completed = !newPrayers[index].completed;
    setPrayers(newPrayers);
  };

  const handleSyncToCalendar = () => {
    const events = generatePrayerCalendarEvents();
    const icsContent = generateICSFile(events);
    const blob = new Blob([icsContent], { type: 'text/calendar' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = 'prayer-times.ics';
    link.click();
    
    setCalendarSyncEnabled(true);
  };

  const completedPrayers = prayers.filter(p => p.completed).length;
  const totalPrayers = prayers.length;
  const completionPercentage = Math.round((completedPrayers / totalPrayers) * 100);

  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-50 to-white pb-20">
      {/* Header */}
      <div className="bg-white border-b border-gray-100">
        <div className="max-w-4xl mx-auto px-6 py-6 flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-black">Prayer Times</h1>
            <div className="flex items-center gap-2 mt-2">
              <MapPin className="w-4 h-4 text-gray-500" />
              <p className="text-sm text-gray-600">
                {settings.location.city}, {settings.location.country}
              </p>
            </div>
          </div>
          <Button
            onClick={() => setShowSettings(!showSettings)}
            variant="outline"
            className="rounded-xl border-gray-200"
          >
            <SettingsIcon className="w-5 h-5" />
          </Button>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-6 py-6 space-y-6">
        {/* Settings Panel */}
        {showSettings && (
          <Card className="p-6 space-y-6 border-gray-100 shadow-sm">
            <h3 className="text-lg font-semibold text-black">Prayer Settings</h3>

            {/* Calculation Method */}
            <div className="space-y-2">
              <Label className="text-base font-medium text-black">Calculation Method</Label>
              <Select
                value={settings.calculationMethod}
                onValueChange={(value) =>
                  setSettings({ ...settings, calculationMethod: value })
                }
              >
                <SelectTrigger className="h-12 rounded-xl border-gray-200">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {calculationMethods.map((method) => (
                    <SelectItem key={method.id} value={method.id}>
                      <div>
                        <div className="font-medium">{method.name}</div>
                        <div className="text-xs text-gray-500">{method.description}</div>
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <p className="text-sm text-gray-600">
                Choose the calculation method used in your region or by your mosque
              </p>
            </div>

            {/* Location */}
            <div className="space-y-3">
              <Label className="text-base font-medium text-black">Location</Label>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <Label className="text-sm text-gray-600">City</Label>
                  <Input
                    value={settings.location.city}
                    onChange={(e) =>
                      setSettings({
                        ...settings,
                        location: { ...settings.location, city: e.target.value }
                      })
                    }
                    className="h-12 rounded-xl border-gray-200 mt-1"
                  />
                </div>
                <div>
                  <Label className="text-sm text-gray-600">Country</Label>
                  <Input
                    value={settings.location.country}
                    onChange={(e) =>
                      setSettings({
                        ...settings,
                        location: { ...settings.location, country: e.target.value }
                      })
                    }
                    className="h-12 rounded-xl border-gray-200 mt-1"
                  />
                </div>
              </div>
            </div>

            {/* Asr Method */}
            <div className="space-y-2">
              <Label className="text-base font-medium text-black">Asr Calculation</Label>
              <Select
                value={settings.asrMethod}
                onValueChange={(value: 'standard' | 'hanafi') =>
                  setSettings({ ...settings, asrMethod: value })
                }
              >
                <SelectTrigger className="h-12 rounded-xl border-gray-200">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {asrMethods.map((method) => (
                    <SelectItem key={method.id} value={method.id}>
                      <div>
                        <div className="font-medium">{method.name}</div>
                        <div className="text-xs text-gray-500">{method.description}</div>
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* High Latitude Rule */}
            <div className="space-y-2">
              <Label className="text-base font-medium text-black">High Latitude Adjustment</Label>
              <Select
                value={settings.highLatitudeRule}
                onValueChange={(value: any) =>
                  setSettings({ ...settings, highLatitudeRule: value })
                }
              >
                <SelectTrigger className="h-12 rounded-xl border-gray-200">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {highLatitudeRules.map((rule) => (
                    <SelectItem key={rule.id} value={rule.id}>
                      <div>
                        <div className="font-medium">{rule.name}</div>
                        <div className="text-xs text-gray-500">{rule.description}</div>
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <p className="text-sm text-gray-600">
                For regions with extreme day/night cycles (above 48° latitude)
              </p>
            </div>
          </Card>
        )}

        {/* Progress Card */}
        <Card className="p-6 border-gray-100 shadow-sm">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="text-lg font-semibold text-black">Today's Progress</h3>
              <p className="text-sm text-gray-600 mt-1">
                {completedPrayers} of {totalPrayers} prayers completed
              </p>
            </div>
            <div className="text-right">
              <div className="text-3xl font-bold text-blue-600">{completionPercentage}%</div>
            </div>
          </div>
          <div className="w-full bg-gray-200 rounded-full h-3">
            <div
              className="bg-gradient-to-r from-blue-600 to-blue-500 h-3 rounded-full transition-all duration-500"
              style={{ width: `${completionPercentage}%` }}
            />
          </div>
        </Card>

        {/* Calendar Sync */}
        <Card className="p-6 border-gray-100 shadow-sm space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <Calendar className="w-5 h-5 text-blue-600" />
              <div>
                <h3 className="font-semibold text-black">Calendar Sync</h3>
                <p className="text-sm text-gray-600">Add prayer times to your calendar</p>
              </div>
            </div>
            <Switch
              checked={calendarSyncEnabled}
              onCheckedChange={() => !calendarSyncEnabled && handleSyncToCalendar()}
            />
          </div>
          
          {!calendarSyncEnabled && (
            <Button
              onClick={handleSyncToCalendar}
              variant="outline"
              className="w-full h-12 rounded-xl border-gray-200"
            >
              <Download className="w-4 h-4 mr-2" />
              Download Prayer Times (.ics)
            </Button>
          )}

          {calendarSyncEnabled && (
            <div className="bg-green-50 rounded-xl p-3 flex items-center gap-2">
              <Check className="w-5 h-5 text-green-600" />
              <span className="text-sm text-green-700">Prayer times synced to calendar</span>
            </div>
          )}
        </Card>

        {/* Prayer Times List */}
        <div className="space-y-3">
          <h3 className="text-lg font-semibold text-black px-2">Today's Prayers</h3>
          
          {prayers.map((prayer, index) => (
            <Card
              key={prayer.name}
              className={`p-5 border-gray-100 shadow-sm cursor-pointer transition-all ${
                prayer.completed ? 'bg-green-50 border-green-200' : ''
              }`}
              onClick={() => handleTogglePrayer(index)}
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                  <div
                    className={`w-12 h-12 rounded-full flex items-center justify-center ${
                      prayer.completed
                        ? 'bg-green-500 text-white'
                        : 'bg-blue-50 text-blue-600'
                    }`}
                  >
                    {prayer.completed ? (
                      <Check className="w-6 h-6" />
                    ) : (
                      <Clock className="w-6 h-6" />
                    )}
                  </div>
                  <div>
                    <h4 className="text-xl font-semibold text-black">{prayer.name}</h4>
                    <p className={`text-sm ${
                      prayer.completed ? 'text-green-600' : 'text-gray-600'
                    }`}>
                      {prayer.completed ? 'Completed' : 'Tap to mark as completed'}
                    </p>
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-2xl font-bold text-black">{prayer.time}</div>
                </div>
              </div>
            </Card>
          ))}
        </div>

        {/* Info */}
        <Card className="bg-blue-50 p-4 border-blue-100">
          <p className="text-sm text-gray-700">
            <span className="font-medium text-black">Note:</span> Prayer times are calculated based on your selected method. 
            Times may vary slightly from your local mosque.
          </p>
        </Card>
      </div>
    </div>
  );
}

// Helper function to generate ICS file content
function generateICSFile(events: { title: string; date: string; time: string }[]): string {
  let ics = `BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Islam360//Prayer Times//EN
CALSCALE:GREGORIAN
METHOD:PUBLISH
X-WR-CALNAME:Prayer Times
X-WR-TIMEZONE:UTC
`;

  events.forEach((event, index) => {
    const [hours, minutes] = event.time.split(':');
    const startDate = new Date(event.date);
    startDate.setHours(parseInt(hours), parseInt(minutes), 0);
    
    const endDate = new Date(startDate);
    endDate.setMinutes(endDate.getMinutes() + 30);

    const formatDate = (date: Date) => {
      return date.toISOString().replace(/[-:]/g, '').split('.')[0] + 'Z';
    };

    ics += `BEGIN:VEVENT
UID:prayer-${index}-${Date.now()}@islam360.app
DTSTAMP:${formatDate(new Date())}
DTSTART:${formatDate(startDate)}
DTEND:${formatDate(endDate)}
SUMMARY:${event.title}
DESCRIPTION:Time for ${event.title}
STATUS:CONFIRMED
SEQUENCE:0
BEGIN:VALARM
TRIGGER:-PT15M
ACTION:DISPLAY
DESCRIPTION:${event.title} in 15 minutes
END:VALARM
END:VEVENT
`;
  });

  ics += 'END:VCALENDAR';
  return ics;
}
