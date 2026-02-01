// Prayer calculation methods based on different Islamic schools of thought (Fiqh)
export interface CalculationMethod {
  id: string;
  name: string;
  description: string;
}

export const calculationMethods: CalculationMethod[] = [
  {
    id: 'mwl',
    name: 'Muslim World League',
    description: 'Used in Europe, Far East, parts of US'
  },
  {
    id: 'isna',
    name: 'Islamic Society of North America (ISNA)',
    description: 'Used in North America'
  },
  {
    id: 'egypt',
    name: 'Egyptian General Authority of Survey',
    description: 'Used in Africa, Syria, Iraq, Lebanon, Malaysia'
  },
  {
    id: 'makkah',
    name: 'Umm Al-Qura University, Makkah',
    description: 'Used in Saudi Arabia'
  },
  {
    id: 'karachi',
    name: 'University of Islamic Sciences, Karachi',
    description: 'Used in Pakistan, Bangladesh, India, Afghanistan'
  },
  {
    id: 'tehran',
    name: 'Institute of Geophysics, University of Tehran',
    description: 'Used in Iran, some Shia communities'
  },
  {
    id: 'jafari',
    name: 'Shia Ithna-Ashari (Jafari)',
    description: 'Used by Shia Muslims'
  },
  {
    id: 'dubai',
    name: 'Dubai (Gulf Region)',
    description: 'Used in UAE and Gulf countries'
  },
  {
    id: 'kuwait',
    name: 'Kuwait',
    description: 'Used in Kuwait'
  },
  {
    id: 'qatar',
    name: 'Qatar',
    description: 'Used in Qatar'
  },
  {
    id: 'singapore',
    name: 'Singapore',
    description: 'Used in Singapore'
  },
  {
    id: 'turkey',
    name: 'Turkey',
    description: 'Diyanet İşleri Başkanlığı'
  },
  {
    id: 'russia',
    name: 'Spiritual Administration of Muslims of Russia',
    description: 'Used in Russia'
  }
];

export interface PrayerSettings {
  calculationMethod: string;
  location: {
    city: string;
    country: string;
    latitude?: number;
    longitude?: number;
  };
  asrMethod: 'standard' | 'hanafi';
  highLatitudeRule: 'none' | 'middle-of-the-night' | 'one-seventh' | 'angle-based';
}

export const defaultPrayerSettings: PrayerSettings = {
  calculationMethod: 'mwl',
  location: {
    city: 'New York',
    country: 'USA',
    latitude: 40.7128,
    longitude: -74.0060
  },
  asrMethod: 'standard',
  highLatitudeRule: 'none'
};

// Asr calculation methods
export const asrMethods = [
  {
    id: 'standard',
    name: 'Standard (Shafi\'i, Maliki, Hanbali)',
    description: 'Shadow length = object length + Fajr shadow'
  },
  {
    id: 'hanafi',
    name: 'Hanafi',
    description: 'Shadow length = 2 × object length + Fajr shadow'
  }
];

// High latitude adjustment rules (for regions with extreme day/night cycles)
export const highLatitudeRules = [
  {
    id: 'none',
    name: 'None',
    description: 'No adjustment (default)'
  },
  {
    id: 'middle-of-the-night',
    name: 'Middle of the Night',
    description: 'Fajr/Isha based on middle of the night'
  },
  {
    id: 'one-seventh',
    name: 'One-Seventh of the Night',
    description: 'Fajr/Isha based on 1/7th of night duration'
  },
  {
    id: 'angle-based',
    name: 'Angle-Based',
    description: 'Uses approximation based on angle'
  }
];
