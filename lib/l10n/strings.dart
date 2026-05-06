enum AppLanguage { english, malayalam, hindi, manglish }

class Strings {
  static const fallback = AppLanguage.english;

  static const values = <String, Map<AppLanguage, String>>{
    'app_name': {
      AppLanguage.english: 'Asmita',
      AppLanguage.malayalam: 'അസ്മിത',
      AppLanguage.hindi: 'अस्मिता',
      AppLanguage.manglish: 'Asmita',
    },
    'wellness_companion': {
      AppLanguage.english: 'Your Wellness Companion',
      AppLanguage.malayalam: 'നിങ്ങളുടെ ആരോഗ്യ കൂട്ടായി',
      AppLanguage.hindi: 'आपकी स्वास्थ्य साथी',
      AppLanguage.manglish: 'Ningalude wellness koottukari',
    },
    'personal_tracking': {
      AppLanguage.english: 'Personal Tracking',
      AppLanguage.malayalam: 'സ്വകാര്യ ട്രാക്കിംഗ്',
      AppLanguage.hindi: 'व्यक्तिगत ट्रैकिंग',
      AppLanguage.manglish: 'Personal tracking',
    },
    'personal_tracking_subtitle': {
      AppLanguage.english:
          'Log your cycle, track symptoms, and get gentle insights.',
      AppLanguage.malayalam:
          'Cycle, symptoms, gentle insights എല്ലാം സ്വകാര്യമായി.',
      AppLanguage.hindi:
          'अपना cycle, symptoms और gentle insights निजी रूप से देखें.',
      AppLanguage.manglish:
          'Cycle, symptoms, insights ellam private aayi track cheyyam.',
    },
    'asha_mode': {
      AppLanguage.english: 'ASHA Worker',
      AppLanguage.malayalam: 'ആശാ പ്രവർത്തക',
      AppLanguage.hindi: 'आशा कार्यकर्ता',
      AppLanguage.manglish: 'ASHA Worker',
    },
    'asha_worker_subtitle': {
      AppLanguage.english: 'Community screening tools for ASHA workers.',
      AppLanguage.malayalam: 'ASHA workers-inu community screening tools.',
      AppLanguage.hindi: 'ASHA workers ke liye community screening tools.',
      AppLanguage.manglish: 'ASHA workers-inu screening tools.',
    },
    'select_language': {
      AppLanguage.english: 'SELECT LANGUAGE',
      AppLanguage.malayalam: 'ഭാഷ തിരഞ്ഞെടുക്കുക',
      AppLanguage.hindi: 'भाषा चुनें',
      AppLanguage.manglish: 'Bhasha select cheyyu',
    },
    'coming_soon': {
      AppLanguage.english: 'Available Now',
      AppLanguage.malayalam: 'Available now',
      AppLanguage.hindi: 'Available now',
      AppLanguage.manglish: 'Available now',
    },
    'period_start': {
      AppLanguage.english: 'Period started',
      AppLanguage.malayalam: 'ആർത്തവം ആരംഭിച്ചു',
      AppLanguage.hindi: 'मासिक धर्म शुरू हुआ',
      AppLanguage.manglish: 'Period thudangi',
    },
    'home': {
      AppLanguage.english: 'Home',
      AppLanguage.malayalam: 'ഹോം',
      AppLanguage.hindi: 'होम',
      AppLanguage.manglish: 'Home',
    },
    'calendar': {
      AppLanguage.english: 'Calendar',
      AppLanguage.malayalam: 'കലണ്ടർ',
      AppLanguage.hindi: 'कैलेंडर',
      AppLanguage.manglish: 'Calendar',
    },
    'log': {
      AppLanguage.english: 'Log',
      AppLanguage.malayalam: 'ലോഗ്',
      AppLanguage.hindi: 'लॉग',
      AppLanguage.manglish: 'Log',
    },
    'companion': {
      AppLanguage.english: 'Companion',
      AppLanguage.malayalam: 'സഖി',
      AppLanguage.hindi: 'सखी',
      AppLanguage.manglish: 'Sakhi',
    },
    'more': {
      AppLanguage.english: 'More',
      AppLanguage.malayalam: 'കൂടുതൽ',
      AppLanguage.hindi: 'और',
      AppLanguage.manglish: 'More',
    },
    'works_offline': {
      AppLanguage.english: 'Works offline',
      AppLanguage.malayalam: 'ഓഫ്‌ലൈനായി പ്രവർത്തിക്കുന്നു',
      AppLanguage.hindi: 'ऑफलाइन काम करता है',
      AppLanguage.manglish: 'Offline aayi work cheyyum',
    },
    'no_data_sent': {
      AppLanguage.english: 'No data sent',
      AppLanguage.malayalam: 'ഡാറ്റ അയക്കുന്നില്ല',
      AppLanguage.hindi: 'कोई डेटा नहीं भेजा जाता',
      AppLanguage.manglish: 'Data onnum ayakkilla',
    },
    'worth_discussing': {
      AppLanguage.english:
          'Your cycle patterns over the last 3 months are worth discussing with a doctor or ASHA worker.',
      AppLanguage.malayalam:
          'കഴിഞ്ഞ 3 മാസത്തെ cycle pattern ഒരു ഡോക്ടറുമായോ ആശാ പ്രവർത്തകയുമായോ സംസാരിക്കാൻ നല്ലതാണ്.',
      AppLanguage.hindi:
          'पिछले 3 महीनों के cycle pattern पर डॉक्टर या आशा कार्यकर्ता से बात करना अच्छा रहेगा.',
      AppLanguage.manglish:
          'Kazhinja 3 months cycle pattern doctor/ASHA worker-ode discuss cheyyan nallathaanu.',
    },
  };

  static String t(String key, AppLanguage language) =>
      values[key]?[language] ?? values[key]?[fallback] ?? key;
}
