import { useState } from 'react';
import { Button } from '@/app/components/ui/button';
import { Card } from '@/app/components/ui/card';
import { Input } from '@/app/components/ui/input';
import { Label } from '@/app/components/ui/label';
import { Switch } from '@/app/components/ui/switch';
import { Plus, Trash2, AlarmClock, Bell } from 'lucide-react';

export interface Alarm {
  id: string;
  time: string;
  label: string;
  enabled: boolean;
  days: string[];
}

interface AlarmsProps {
  alarms: Alarm[];
  onAlarmsChange: (alarms: Alarm[]) => void;
}

export function Alarms({ alarms, onAlarmsChange }: AlarmsProps) {
  const [showAddAlarm, setShowAddAlarm] = useState(false);
  const [newAlarmTime, setNewAlarmTime] = useState('07:00');
  const [newAlarmLabel, setNewAlarmLabel] = useState('');
  const [selectedDays, setSelectedDays] = useState<string[]>(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);

  const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  const handleAddAlarm = () => {
    const newAlarm: Alarm = {
      id: Date.now().toString(),
      time: newAlarmTime,
      label: newAlarmLabel || 'Alarm',
      enabled: true,
      days: selectedDays
    };

    onAlarmsChange([...alarms, newAlarm]);
    setNewAlarmTime('07:00');
    setNewAlarmLabel('');
    setSelectedDays(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
    setShowAddAlarm(false);
  };

  const handleToggleAlarm = (id: string) => {
    onAlarmsChange(
      alarms.map(alarm =>
        alarm.id === id ? { ...alarm, enabled: !alarm.enabled } : alarm
      )
    );
  };

  const handleDeleteAlarm = (id: string) => {
    onAlarmsChange(alarms.filter(alarm => alarm.id !== id));
  };

  const toggleDay = (day: string) => {
    setSelectedDays(prev =>
      prev.includes(day)
        ? prev.filter(d => d !== day)
        : [...prev, day]
    );
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-50 to-white pb-20">
      {/* Header */}
      <div className="bg-white border-b border-gray-100">
        <div className="max-w-4xl mx-auto px-6 py-6">
          <h1 className="text-2xl font-bold text-black">Islamic Alarms</h1>
          <p className="text-sm text-gray-600 mt-1">Dismiss by reading Ayat</p>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-6 py-6 space-y-6">
        {/* Info Card */}
        <Card className="bg-blue-50 p-4 border-blue-100">
          <div className="flex gap-3">
            <Bell className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
            <div className="text-sm text-gray-700">
              <p className="font-medium text-black mb-1">Mindful Dismissal</p>
              <p>Alarms can only be dismissed by reading an Ayat or using emergency shake to skip.</p>
            </div>
          </div>
        </Card>

        {/* Add Alarm Button */}
        {!showAddAlarm && (
          <Button
            onClick={() => setShowAddAlarm(true)}
            className="w-full h-14 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-base font-medium"
          >
            <Plus className="w-5 h-5 mr-2" />
            Add New Alarm
          </Button>
        )}

        {/* Add Alarm Form */}
        {showAddAlarm && (
          <Card className="p-6 space-y-4 border-gray-100 shadow-sm">
            <h3 className="text-lg font-semibold text-black">New Alarm</h3>

            <div className="space-y-2">
              <Label className="text-sm font-medium text-black">Time</Label>
              <Input
                type="time"
                value={newAlarmTime}
                onChange={(e) => setNewAlarmTime(e.target.value)}
                className="h-14 rounded-xl border-gray-200 text-lg"
              />
            </div>

            <div className="space-y-2">
              <Label className="text-sm font-medium text-black">Label (Optional)</Label>
              <Input
                placeholder="e.g., Morning Dhikr"
                value={newAlarmLabel}
                onChange={(e) => setNewAlarmLabel(e.target.value)}
                className="h-12 rounded-xl border-gray-200"
              />
            </div>

            <div className="space-y-2">
              <Label className="text-sm font-medium text-black">Repeat Days</Label>
              <div className="flex gap-2">
                {weekDays.map(day => (
                  <button
                    key={day}
                    onClick={() => toggleDay(day)}
                    className={`flex-1 h-10 rounded-lg text-sm font-medium transition-colors ${
                      selectedDays.includes(day)
                        ? 'bg-blue-600 text-white'
                        : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                    }`}
                  >
                    {day}
                  </button>
                ))}
              </div>
            </div>

            <div className="flex gap-2 pt-2">
              <Button
                onClick={() => setShowAddAlarm(false)}
                variant="outline"
                className="flex-1 h-12 rounded-xl"
              >
                Cancel
              </Button>
              <Button
                onClick={handleAddAlarm}
                disabled={selectedDays.length === 0}
                className="flex-1 h-12 bg-blue-600 hover:bg-blue-700 rounded-xl"
              >
                Add Alarm
              </Button>
            </div>
          </Card>
        )}

        {/* Alarms List */}
        <div className="space-y-3">
          {alarms.length === 0 ? (
            <Card className="p-12 text-center border-gray-100 shadow-sm">
              <AlarmClock className="w-16 h-16 text-gray-300 mx-auto mb-4" />
              <p className="text-gray-500">No alarms set yet</p>
              <p className="text-sm text-gray-400 mt-1">Add your first alarm above</p>
            </Card>
          ) : (
            alarms.map(alarm => (
              <Card key={alarm.id} className="p-5 border-gray-100 shadow-sm">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4 flex-1">
                    <Switch
                      checked={alarm.enabled}
                      onCheckedChange={() => handleToggleAlarm(alarm.id)}
                    />
                    <div className="flex-1">
                      <div className="flex items-baseline gap-3">
                        <span className={`text-3xl font-bold ${
                          alarm.enabled ? 'text-black' : 'text-gray-400'
                        }`}>
                          {alarm.time}
                        </span>
                        <span className={`text-sm ${
                          alarm.enabled ? 'text-gray-600' : 'text-gray-400'
                        }`}>
                          {alarm.label}
                        </span>
                      </div>
                      <div className="flex gap-1 mt-2">
                        {alarm.days.map(day => (
                          <span
                            key={day}
                            className={`text-xs px-2 py-1 rounded ${
                              alarm.enabled
                                ? 'bg-blue-50 text-blue-600'
                                : 'bg-gray-100 text-gray-400'
                            }`}
                          >
                            {day}
                          </span>
                        ))}
                      </div>
                    </div>
                  </div>
                  <Button
                    onClick={() => handleDeleteAlarm(alarm.id)}
                    variant="ghost"
                    size="sm"
                    className="text-gray-400 hover:text-red-600"
                  >
                    <Trash2 className="w-5 h-5" />
                  </Button>
                </div>
              </Card>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
