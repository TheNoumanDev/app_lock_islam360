import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Button } from '@/app/components/ui/button';
import { ChevronLeft, ChevronRight, Shield, BookOpen, AlarmClock, Heart } from 'lucide-react';

interface OnboardingProps {
  onComplete: () => void;
}

const slides = [
  {
    icon: Shield,
    title: "Lock Distracting Apps",
    description: "Choose which apps to lock. Get inspired with Quran verses and Hadith before opening them. Configure locks to activate: every time, once/twice/thrice daily, or only during prayer times.",
    color: "bg-blue-500"
  },
  {
    icon: BookOpen,
    title: "Turn Distractions into Dhikr",
    description: "When you open a locked app, share how you're feeling. We'll show you a relevant Ayat or Hadith to reflect on before continuing. Shake to skip in emergencies.",
    color: "bg-purple-500"
  },
  {
    icon: AlarmClock,
    title: "Wake Up with Purpose",
    description: "Set alarms that require mindful dismissal. Choose your method: read a dhikr and tap done, solve a simple math problem, slide to dismiss, or shake your phone.",
    color: "bg-orange-500"
  },
  {
    icon: BookOpen,
    title: "Read Quran Daily",
    description: "Track your Quran reading progress. Always continue from where you left off. Build a consistent reading habit with streak tracking.",
    color: "bg-green-500"
  },
  {
    icon: Heart,
    title: "Support the Mission",
    description: "Help us keep this app ad-free and continuously improving. Your contribution helps spread Islamic knowledge.",
    color: "bg-pink-500",
    subscription: true
  }
];

export function Onboarding({ onComplete }: OnboardingProps) {
  const [currentSlide, setCurrentSlide] = useState(0);

  const handleNext = () => {
    if (currentSlide < slides.length - 1) {
      setCurrentSlide(currentSlide + 1);
    } else {
      onComplete();
    }
  };

  const handleSkip = () => {
    onComplete();
  };

  const slide = slides[currentSlide];
  const Icon = slide.icon;

  return (
    <div className="h-screen bg-white flex flex-col">
      {/* Skip Button */}
      <div className="flex justify-end p-6">
        <button
          onClick={handleSkip}
          className="text-gray-500 hover:text-gray-700 font-medium"
        >
          Skip
        </button>
      </div>

      {/* Content */}
      <div className="flex-1 flex flex-col items-center justify-center px-8 pb-20">
        <AnimatePresence mode="wait">
          <motion.div
            key={currentSlide}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.3 }}
            className="flex flex-col items-center text-center max-w-md"
          >
            {/* Illustration */}
            <div className={`w-32 h-32 rounded-full ${slide.color} bg-opacity-10 flex items-center justify-center mb-8`}>
              <Icon className={`w-16 h-16 ${slide.color.replace('bg-', 'text-')}`} />
            </div>

            {/* Title */}
            <h1 className="text-3xl font-bold text-black mb-4">
              {slide.title}
            </h1>

            {/* Description */}
            <p className="text-gray-600 leading-relaxed mb-8">
              {slide.description}
            </p>

            {/* Subscription Card */}
            {slide.subscription && (
              <div className="w-full bg-gradient-to-br from-blue-50 to-purple-50 rounded-2xl p-6 mb-6 border-2 border-blue-100">
                <div className="text-center mb-4">
                  <div className="text-4xl font-bold text-black mb-2">₹299<span className="text-xl text-gray-600">/month</span></div>
                  <Button className="w-full h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-xl mb-3">
                    Subscribe Now
                  </Button>
                  <p className="text-xs text-gray-500">Cancel anytime • 7-day free trial</p>
                </div>
              </div>
            )}
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Bottom Section */}
      <div className="px-8 pb-12">
        {/* Dot Indicators */}
        <div className="flex justify-center gap-2 mb-6">
          {slides.map((_, index) => (
            <button
              key={index}
              onClick={() => setCurrentSlide(index)}
              className={`h-2 rounded-full transition-all ${
                index === currentSlide
                  ? 'w-8 bg-blue-600'
                  : 'w-2 bg-gray-300'
              }`}
            />
          ))}
        </div>

        {/* Next/Continue Button */}
        {slide.subscription ? (
          <button
            onClick={onComplete}
            className="w-full text-center text-blue-600 font-medium"
          >
            Continue for free
          </button>
        ) : (
          <Button
            onClick={handleNext}
            className="w-full h-14 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-lg font-medium"
          >
            {currentSlide === slides.length - 1 ? 'Get Started' : 'Next'}
            <ChevronRight className="w-5 h-5 ml-2" />
          </Button>
        )}
      </div>
    </div>
  );
}
