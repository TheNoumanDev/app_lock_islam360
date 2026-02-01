import { motion } from 'motion/react';
import { Droplets } from 'lucide-react';

interface PrayerVesselProps {
  completedPrayers: number;
  totalPrayers: number;
}

export function PrayerVessel({ completedPrayers, totalPrayers }: PrayerVesselProps) {
  const fillPercentage = (completedPrayers / totalPrayers) * 100;

  return (
    <div className="relative w-full max-w-xs mx-auto">
      {/* Vessel Container */}
      <div className="relative h-64 flex items-end justify-center">
        {/* Vessel Shape (SVG) */}
        <svg
          viewBox="0 0 200 280"
          className="w-full h-full"
          style={{ filter: 'drop-shadow(0 4px 6px rgba(0, 0, 0, 0.1))' }}
        >
          {/* Vessel Outline */}
          <path
            d="M 60 20 L 50 260 Q 50 270 60 270 L 140 270 Q 150 270 150 260 L 140 20 Q 140 10 130 10 L 70 10 Q 60 10 60 20 Z"
            fill="white"
            stroke="#e5e7eb"
            strokeWidth="2"
          />
          
          {/* Water Fill */}
          <defs>
            <clipPath id="vesselClip">
              <path d="M 60 20 L 50 260 Q 50 270 60 270 L 140 270 Q 150 270 150 260 L 140 20 Q 140 10 130 10 L 70 10 Q 60 10 60 20 Z" />
            </clipPath>
            <linearGradient id="waterGradient" x1="0%" y1="0%" x2="0%" y2="100%">
              <stop offset="0%" stopColor="#3b82f6" stopOpacity="0.8" />
              <stop offset="100%" stopColor="#1d4ed8" stopOpacity="0.9" />
            </linearGradient>
          </defs>
          
          <g clipPath="url(#vesselClip)">
            <motion.rect
              x="48"
              y="10"
              width="104"
              height="260"
              fill="url(#waterGradient)"
              initial={{ y: 270 }}
              animate={{ 
                y: 270 - (260 * fillPercentage / 100)
              }}
              transition={{ 
                duration: 1.5, 
                ease: "easeOut",
                delay: 0.2
              }}
            />
            
            {/* Water Surface Animation */}
            <motion.ellipse
              cx="100"
              cy="270"
              rx="48"
              ry="8"
              fill="#60a5fa"
              opacity="0.6"
              animate={{ 
                cy: 270 - (260 * fillPercentage / 100),
                opacity: [0.4, 0.7, 0.4]
              }}
              transition={{ 
                cy: { duration: 1.5, ease: "easeOut", delay: 0.2 },
                opacity: { duration: 2, repeat: Infinity, ease: "easeInOut" }
              }}
            />
          </g>
          
          {/* Measurement Lines */}
          {[20, 40, 60, 80].map((percent) => (
            <g key={percent}>
              <line
                x1="45"
                y1={270 - (260 * percent / 100)}
                x2="155"
                y2={270 - (260 * percent / 100)}
                stroke="#e5e7eb"
                strokeWidth="1"
                strokeDasharray="4 4"
                opacity="0.5"
              />
            </g>
          ))}
        </svg>

        {/* Center Stats */}
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <Droplets className="w-8 h-8 text-blue-600 mb-2" />
          <div className="text-4xl font-bold text-black">{completedPrayers}/{totalPrayers}</div>
          <div className="text-sm text-gray-600 mt-1">Prayers Today</div>
          <div className="text-2xl font-bold text-blue-600 mt-2">{Math.round(fillPercentage)}%</div>
        </div>
      </div>

      {/* Droplets Animation */}
      {completedPrayers > 0 && (
        <div className="absolute top-0 left-1/2 transform -translate-x-1/2">
          {[...Array(3)].map((_, i) => (
            <motion.div
              key={i}
              initial={{ y: -20, opacity: 0 }}
              animate={{ 
                y: 100,
                opacity: [0, 1, 0]
              }}
              transition={{
                duration: 2,
                delay: i * 0.7,
                repeat: Infinity,
                ease: "easeIn"
              }}
              className="absolute"
              style={{ left: `${(i - 1) * 20}px` }}
            >
              <Droplets className="w-4 h-4 text-blue-400" />
            </motion.div>
          ))}
        </div>
      )}
    </div>
  );
}
