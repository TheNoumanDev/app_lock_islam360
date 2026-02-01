export interface PrayerTime {
  name: string;
  time: string;
  completed: boolean;
}

export function getTodaysPrayerTimes(): PrayerTime[] {
  // Mock prayer times - in a real app, these would be calculated based on location
  return [
    { name: 'Fajr', time: '05:30', completed: true },
    { name: 'Dhuhr', time: '12:45', completed: true },
    { name: 'Asr', time: '15:30', completed: false },
    { name: 'Maghrib', time: '18:15', completed: false },
    { name: 'Isha', time: '19:45', completed: false },
  ];
}

export function getNextPrayer(): { name: string; time: string; timeUntil: string } {
  const prayers = getTodaysPrayerTimes();
  const now = new Date();
  const currentTime = now.getHours() * 60 + now.getMinutes();

  for (const prayer of prayers) {
    const [hours, minutes] = prayer.time.split(':').map(Number);
    const prayerTime = hours * 60 + minutes;

    if (prayerTime > currentTime) {
      const minutesUntil = prayerTime - currentTime;
      const hoursUntil = Math.floor(minutesUntil / 60);
      const minsUntil = minutesUntil % 60;
      
      let timeUntil = '';
      if (hoursUntil > 0) {
        timeUntil = `${hoursUntil}h ${minsUntil}m`;
      } else {
        timeUntil = `${minsUntil}m`;
      }

      return {
        name: prayer.name,
        time: prayer.time,
        timeUntil
      };
    }
  }

  // If no prayer left today, return Fajr tomorrow
  return {
    name: 'Fajr',
    time: '05:30',
    timeUntil: 'Tomorrow'
  };
}

export interface CalendarEvent {
  title: string;
  date: string;
  time: string;
}

export function generatePrayerCalendarEvents(): CalendarEvent[] {
  // Generate prayer events for the next 7 days
  const events: CalendarEvent[] = [];
  const prayers = getTodaysPrayerTimes();
  
  for (let day = 0; day < 7; day++) {
    const date = new Date();
    date.setDate(date.getDate() + day);
    const dateStr = date.toISOString().split('T')[0];
    
    prayers.forEach(prayer => {
      events.push({
        title: `${prayer.name} Prayer`,
        date: dateStr,
        time: prayer.time
      });
    });
  }
  
  return events;
}
