import { useState } from 'react';
import { Button } from '@/app/components/ui/button';
import { Card } from '@/app/components/ui/card';
import { Switch } from '@/app/components/ui/switch';
import { Input } from '@/app/components/ui/input';
import { Label } from '@/app/components/ui/label';
import { Lock, ChevronDown } from 'lucide-react';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/app/components/ui/select';

export interface Settings {
  requireFeeling: boolean;
  requirePassword: boolean;
  password: string;
  contentFrequency: 'every-time' | 'once' | 'twice' | 'thrice' | 'prayer-times';
  apps: Array<{
    name: string;
    enabled: boolean;
    frequency?: 'every-time' | 'once' | 'twice' | 'thrice' | 'prayer-times';
  }>;
}

interface LockedAppsProps {
  settings: Settings;
  onSettingsChange: (settings: Settings) => void;
  onTestLock: () => void;
}

export function LockedApps({ settings, onSettingsChange, onTestLock }: LockedAppsProps) {
  const handleToggleApp = (index: number) => {
    const newApps = [...settings.apps];
    newApps[index].enabled = !newApps[index].enabled;
    onSettingsChange({ ...settings, apps: newApps });
  };

  const handleAppFrequencyChange = (index: number, frequency: string) => {
    const newApps = [...settings.apps];
    newApps[index].frequency = frequency as Settings['contentFrequency'];
    onSettingsChange({ ...settings, apps: newApps });
  };

  const frequencyOptions = [
    { value: 'every-time', label: 'Every time' },
    { value: 'once', label: 'Once per day' },
    { value: 'twice', label: 'Twice per day' },
    { value: 'thrice', label: 'Thrice per day' },
    { value: 'prayer-times', label: 'During prayer times' },
  ];

  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <div className="bg-white border-b border-gray-100 px-6 py-6">
        <h1 className="text-2xl font-bold text-black">Locked Apps</h1>
        <p className="text-sm text-gray-600 mt-1">Choose which apps to lock and configure behavior</p>
      </div>

      <div className="px-6 py-6 space-y-6">
        {/* Apps List */}
        <div className="space-y-3">
          {settings.apps.map((app, index) => (
            <Card key={app.name} className="p-4 border-gray-100 shadow-sm">
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-blue-50 rounded-xl flex items-center justify-center">
                      <Lock className="w-5 h-5 text-blue-600" />
                    </div>
                    <div>
                      <h4 className="font-semibold text-black">{app.name}</h4>
                    </div>
                  </div>
                  <Switch
                    checked={app.enabled}
                    onCheckedChange={() => handleToggleApp(index)}
                  />
                </div>

                {/* Frequency Dropdown - Only show when enabled */}
                {app.enabled && (
                  <div className="pl-13 space-y-2">
                    <Label className="text-sm text-gray-600">Lock frequency</Label>
                    <Select
                      value={app.frequency || 'every-time'}
                      onValueChange={(value) => handleAppFrequencyChange(index, value)}
                    >
                      <SelectTrigger className="h-10 rounded-xl border-gray-200 bg-gray-50">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        {frequencyOptions.map((option) => (
                          <SelectItem key={option.value} value={option.value}>
                            {option.label}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                )}
              </div>
            </Card>
          ))}
        </div>

        {/* Settings */}
        <Card className="p-5 border-gray-100 shadow-sm space-y-4">
          <h3 className="font-semibold text-black">Lock Behavior</h3>
          
          <div className="flex items-center justify-between">
            <div>
              <Label className="text-base text-black">Require feeling input</Label>
              <p className="text-sm text-gray-600">Ask how you're feeling before showing content</p>
            </div>
            <Switch
              checked={settings.requireFeeling}
              onCheckedChange={(checked) =>
                onSettingsChange({ ...settings, requireFeeling: checked })
              }
            />
          </div>

          <div className="flex items-center justify-between">
            <div>
              <Label className="text-base text-black">Require password</Label>
              <p className="text-sm text-gray-600">Add extra security layer</p>
            </div>
            <Switch
              checked={settings.requirePassword}
              onCheckedChange={(checked) =>
                onSettingsChange({ ...settings, requirePassword: checked })
              }
            />
          </div>

          {settings.requirePassword && (
            <div className="pt-2">
              <Label className="text-sm text-gray-600 mb-2">Password</Label>
              <Input
                type="password"
                placeholder="Enter password"
                value={settings.password}
                onChange={(e) =>
                  onSettingsChange({ ...settings, password: e.target.value })
                }
                className="h-11 rounded-xl border-gray-200"
              />
            </div>
          )}
        </Card>

        {/* Test Button */}
        <Button
          onClick={onTestLock}
          className="w-full h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-xl"
        >
          Test App Lock
        </Button>
      </div>
    </div>
  );
}