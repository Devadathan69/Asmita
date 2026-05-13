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
    'offline_ai_companion': {
      AppLanguage.english: 'Offline AI companion',
      AppLanguage.malayalam: 'ഓഫ്‌ലൈൻ AI കൂട്ടുകാരി',
      AppLanguage.hindi: 'ऑफ़लाइन AI साथी',
      AppLanguage.manglish: 'Offline AI koottukaari',
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
    'private_setup': {
      AppLanguage.english: 'Private setup',
      AppLanguage.malayalam: 'സ്വകാര്യ സജ്ജീകരണം',
      AppLanguage.hindi: 'निजी सेटअप',
      AppLanguage.manglish: 'Private setup',
    },
    'name_optional': {
      AppLanguage.english: 'Name or nickname (optional)',
      AppLanguage.malayalam: 'പേര് അല്ലെങ്കിൽ വിളിപ്പേര് (ഓപ്ഷണൽ)',
      AppLanguage.hindi: 'नाम या निकनेम (वैकल्पिक)',
      AppLanguage.manglish: 'Name allenkil nickname (optional)',
    },
    'date_of_birth': {
      AppLanguage.english: 'Date of birth',
      AppLanguage.malayalam: 'ജനന തീയതി',
      AppLanguage.hindi: 'जन्म तिथि',
      AppLanguage.manglish: 'Janicha date',
    },
    'age': {
      AppLanguage.english: 'Age',
      AppLanguage.malayalam: 'പ്രായം',
      AppLanguage.hindi: 'उम्र',
      AppLanguage.manglish: 'Age',
    },
    'height_cm': {
      AppLanguage.english: 'Height (cm)',
      AppLanguage.malayalam: 'ഉയരം (സെ.മീ)',
      AppLanguage.hindi: 'लंबाई (सेमी)',
      AppLanguage.manglish: 'Height (cm)',
    },
    'weight_kg': {
      AppLanguage.english: 'Weight (kg)',
      AppLanguage.malayalam: 'ഭാരം (കി.ഗ്രാം)',
      AppLanguage.hindi: 'वजन (किलो)',
      AppLanguage.manglish: 'Weight (kg)',
    },
    'bmi_context': {
      AppLanguage.english: 'BMI context',
      AppLanguage.malayalam: 'BMI വിവരം',
      AppLanguage.hindi: 'BMI संदर्भ',
      AppLanguage.manglish: 'BMI context',
    },
    'last_period_start': {
      AppLanguage.english: 'Last period start',
      AppLanguage.malayalam: 'അവസാന ആർത്തവം തുടങ്ങിയ ദിവസം',
      AppLanguage.hindi: 'आखिरी पीरियड शुरू होने की तारीख',
      AppLanguage.manglish: 'Last period thudangiya date',
    },
    'start_using_asmita': {
      AppLanguage.english: 'Start using Asmita',
      AppLanguage.malayalam: 'അസ്മിത ഉപയോഗിച്ച് തുടങ്ങുക',
      AppLanguage.hindi: 'Asmita शुरू करें',
      AppLanguage.manglish: 'Asmita start cheyyam',
    },
    'details_stay_phone': {
      AppLanguage.english: 'Your details stay on this phone.',
      AppLanguage.malayalam: 'നിങ്ങളുടെ വിവരങ്ങൾ ഈ ഫോണിൽ മാത്രം സൂക്ഷിക്കും.',
      AppLanguage.hindi: 'आपकी जानकारी केवल इस फोन में रहती है।',
      AppLanguage.manglish: 'Ningalude details ee phonil mathram irikkum.',
    },
    'profile_health_details': {
      AppLanguage.english: 'Profile & Health Details',
      AppLanguage.malayalam: 'പ്രൊഫൈൽ & ആരോഗ്യ വിവരങ്ങൾ',
      AppLanguage.hindi: 'प्रोफाइल और स्वास्थ्य जानकारी',
      AppLanguage.manglish: 'Profile & health details',
    },
    'language': {
      AppLanguage.english: 'Language',
      AppLanguage.malayalam: 'ഭാഷ',
      AppLanguage.hindi: 'भाषा',
      AppLanguage.manglish: 'Bhasha',
    },
    'english': {
      AppLanguage.english: 'English',
      AppLanguage.malayalam: 'English',
      AppLanguage.hindi: 'English',
      AppLanguage.manglish: 'English',
    },
    'malayalam': {
      AppLanguage.english: 'Malayalam',
      AppLanguage.malayalam: 'മലയാളം',
      AppLanguage.hindi: 'Malayalam',
      AppLanguage.manglish: 'Malayalam',
    },
    'hindi': {
      AppLanguage.english: 'Hindi',
      AppLanguage.malayalam: 'Hindi',
      AppLanguage.hindi: 'हिन्दी',
      AppLanguage.manglish: 'Hindi',
    },
    'manglish': {
      AppLanguage.english: 'Manglish',
      AppLanguage.malayalam: 'Manglish',
      AppLanguage.hindi: 'Manglish',
      AppLanguage.manglish: 'Manglish',
    },
    'pregnancy_mode': {
      AppLanguage.english: 'Pregnancy Mode',
      AppLanguage.malayalam: 'ഗർഭകാല മോഡ്',
      AppLanguage.hindi: 'गर्भावस्था मोड',
      AppLanguage.manglish: 'Pregnancy mode',
    },
    'pregnant': {
      AppLanguage.english: 'Pregnant',
      AppLanguage.malayalam: 'ഗർഭിണി',
      AppLanguage.hindi: 'गर्भवती',
      AppLanguage.manglish: 'Pregnant',
    },
    'not_pregnant': {
      AppLanguage.english: 'Not pregnant',
      AppLanguage.malayalam: 'ഗർഭിണിയല്ല',
      AppLanguage.hindi: 'गर्भवती नहीं',
      AppLanguage.manglish: 'Pregnant alla',
    },
    'pregnancy_adult_only': {
      AppLanguage.english: 'Pregnancy mode is available only for adult users.',
      AppLanguage.malayalam:
          'ഗർഭകാല മോഡ് പ്രായപൂർത്തിയായ ഉപയോക്താക്കൾക്ക് മാത്രമാണ്.',
      AppLanguage.hindi: 'गर्भावस्था मोड केवल वयस्क उपयोगकर्ताओं के लिए है।',
      AppLanguage.manglish:
          'Pregnancy mode adult users-inu mathram available aanu.',
    },
    'last_menstrual_period': {
      AppLanguage.english: 'Last menstrual period',
      AppLanguage.malayalam: 'അവസാന ആർത്തവം',
      AppLanguage.hindi: 'आखिरी मासिक धर्म',
      AppLanguage.manglish: 'Last period',
    },
    'expected_due_date': {
      AppLanguage.english: 'Expected due date',
      AppLanguage.malayalam: 'പ്രതീക്ഷിക്കുന്ന പ്രസവ തീയതി',
      AppLanguage.hindi: 'अनुमानित ड्यू डेट',
      AppLanguage.manglish: 'Expected due date',
    },
    'high_risk_pregnancy': {
      AppLanguage.english: 'Marked high-risk by doctor/ASHA',
      AppLanguage.malayalam: 'ഡോക്ടർ/ആശാ high-risk എന്ന് പറഞ്ഞിട്ടുണ്ട്',
      AppLanguage.hindi: 'डॉक्टर/ASHA ने high-risk बताया है',
      AppLanguage.manglish: 'Doctor/ASHA high-risk paranjittundo',
    },
    'pregnancy_support': {
      AppLanguage.english: 'Pregnancy Support',
      AppLanguage.malayalam: 'ഗർഭകാല സഹായം',
      AppLanguage.hindi: 'गर्भावस्था सहायता',
      AppLanguage.manglish: 'Pregnancy support',
    },
    'week': {
      AppLanguage.english: 'Week',
      AppLanguage.malayalam: 'ആഴ്ച',
      AppLanguage.hindi: 'सप्ताह',
      AppLanguage.manglish: 'Week',
    },
    'trimester': {
      AppLanguage.english: 'Trimester',
      AppLanguage.malayalam: 'ട്രൈമെസ്റ്റർ',
      AppLanguage.hindi: 'ट्राइमेस्टर',
      AppLanguage.manglish: 'Trimester',
    },
    'log_today': {
      AppLanguage.english: 'Log today',
      AppLanguage.malayalam: 'ഇന്നത്തെ വിവരങ്ങൾ ചേർക്കുക',
      AppLanguage.hindi: 'आज लॉग करें',
      AppLanguage.manglish: 'Innathe log',
    },
    'symptoms': {
      AppLanguage.english: 'Symptoms',
      AppLanguage.malayalam: 'ലക്ഷണങ്ങൾ',
      AppLanguage.hindi: 'लक्षण',
      AppLanguage.manglish: 'Symptoms',
    },
    'energy': {
      AppLanguage.english: 'Energy',
      AppLanguage.malayalam: 'എനർജി',
      AppLanguage.hindi: 'ऊर्जा',
      AppLanguage.manglish: 'Energy',
    },
    'appointments': {
      AppLanguage.english: 'Appointments',
      AppLanguage.malayalam: 'അപ്പോയിന്റ്മെന്റുകൾ',
      AppLanguage.hindi: 'अपॉइंटमेंट',
      AppLanguage.manglish: 'Appointments',
    },
    'questions_for_doctor': {
      AppLanguage.english: 'Questions for doctor',
      AppLanguage.malayalam: 'ഡോക്ടറോട് ചോദിക്കാനുള്ളത്',
      AppLanguage.hindi: 'डॉक्टर से पूछने वाले सवाल',
      AppLanguage.manglish: 'Doctor-ode chodikkan ullath',
    },
    'warning_signs': {
      AppLanguage.english: 'Warning signs',
      AppLanguage.malayalam: 'ശ്രദ്ധിക്കേണ്ട ലക്ഷണങ്ങൾ',
      AppLanguage.hindi: 'ध्यान देने वाले संकेत',
      AppLanguage.manglish: 'Shradhikkenda signs',
    },
    'get_medical_help_urgently_if': {
      AppLanguage.english: 'Get medical help urgently if:',
      AppLanguage.malayalam: 'ഇവ ഉണ്ടെങ്കിൽ ഉടൻ ആരോഗ്യ സഹായം തേടുക:',
      AppLanguage.hindi: 'इनमें से कुछ हो तो तुरंत मेडिकल मदद लें:',
      AppLanguage.manglish: 'Iva undenkil vegam medical help thedu:',
    },
    'switch_to_period_tracking': {
      AppLanguage.english: 'Switch back to period tracking?',
      AppLanguage.malayalam: 'വീണ്ടും period tracking-ലേക്ക് മാറണോ?',
      AppLanguage.hindi: 'वापस period tracking पर जाएं?',
      AppLanguage.manglish: 'Period tracking-lekku thirichu pokano?',
    },
    'switch_to_pregnancy_mode': {
      AppLanguage.english: 'Switch to pregnancy support',
      AppLanguage.malayalam: 'ഗർഭകാല സഹായത്തിലേക്ക് മാറുക',
      AppLanguage.hindi: 'गर्भावस्था सहायता पर जाएं',
      AppLanguage.manglish: 'Pregnancy support-lekku switch cheyyam',
    },
    'complete_health_profile': {
      AppLanguage.english: 'Complete your health profile',
      AppLanguage.malayalam: 'ആരോഗ്യ പ്രൊഫൈൽ പൂർത്തിയാക്കുക',
      AppLanguage.hindi: 'अपनी health profile पूरी करें',
      AppLanguage.manglish: 'Health profile complete cheyyu',
    },
    'complete_health_profile_body': {
      AppLanguage.english:
          'Add date of birth, height, and weight for better insights.',
      AppLanguage.malayalam:
          'കൂടുതൽ നല്ല insights-നായി ജനന തീയതി, ഉയരം, ഭാരം ചേർക്കുക.',
      AppLanguage.hindi:
          'बेहतर insights के लिए जन्म तिथि, लंबाई और वजन जोड़ें।',
      AppLanguage.manglish:
          'Better insights kittan DOB, height, weight add cheyyu.',
    },
    'low_energy_normal': {
      AppLanguage.english:
          'Energy feels low today. Try a 5-minute slow walk or gentle stretching if you feel comfortable. If you have pain, rest is okay too.',
      AppLanguage.malayalam:
          'ഇന്ന് energy കുറവാണെന്ന് തോന്നുന്നു. സുഖമാണെങ്കിൽ 5 മിനിറ്റ് പതുക്കെ നടക്കുകയോ ലഘു stretching ചെയ്യുകയോ ചെയ്യാം. വേദനയുണ്ടെങ്കിൽ വിശ്രമിക്കുന്നതും ശരിയാണ്.',
      AppLanguage.hindi:
          'आज energy कम लग रही है। आराम हो तो 5 मिनट धीमी walk या हल्की stretching करें। दर्द हो तो आराम करना भी ठीक है।',
      AppLanguage.manglish:
          'Innu energy kuravayi thonnunnu. Comfortable aanenkil 5-minute slow walk allenkil light stretching try cheyyu. Pain undenkil rest edukkunnathum okay aanu.',
    },
    'low_energy_pregnancy': {
      AppLanguage.english:
          'Try a 5-minute slow walk, seated ankle circles, shoulder rolls, or gentle breathing only if you feel comfortable.',
      AppLanguage.malayalam:
          'സുഖമാണെങ്കിൽ മാത്രം 5 മിനിറ്റ് പതുക്കെ നടക്കൽ, ഇരുന്ന് ankle circles, shoulder rolls, gentle breathing എന്നിവ ചെയ്യാം.',
      AppLanguage.hindi:
          'आराम हो तो ही 5 मिनट धीमी walk, बैठे-बैठे ankle circles, shoulder rolls या gentle breathing करें।',
      AppLanguage.manglish:
          'Comfortable aanenkil mathram 5-minute slow walk, seated ankle circles, shoulder rolls, gentle breathing cheyyu.',
    },
    'pregnancy_energy_safety': {
      AppLanguage.english:
          'Do this only if you feel comfortable and a doctor has not advised rest. Stop if you feel pain, dizziness, bleeding, or breathlessness.',
      AppLanguage.malayalam:
          'സുഖമുണ്ടെങ്കിൽ മാത്രവും ഡോക്ടർ rest പറഞ്ഞിട്ടില്ലെങ്കിൽ മാത്രവും ചെയ്യുക. വേദന, തലചുറ്റൽ, bleeding, ശ്വാസംമുട്ടൽ ഉണ്ടായാൽ നിർത്തുക.',
      AppLanguage.hindi:
          'यह तभी करें जब आराम लगे और डॉक्टर ने rest नहीं कहा हो। दर्द, चक्कर, bleeding या सांस फूलने पर रोक दें।',
      AppLanguage.manglish:
          'Comfortable aanenkilum doctor rest paranjittillenkilum mathram cheyyu. Pain, dizziness, bleeding, breathlessness undenkil stop cheyyu.',
    },
    'low_energy_pain_rest': {
      AppLanguage.english:
          'Pain is high today, so rest, hydration, and slow breathing are enough. Talk to a doctor or ASHA worker if this feels severe or happens often.',
      AppLanguage.malayalam:
          'ഇന്ന് വേദന കൂടുതലാണ്, അതുകൊണ്ട് വിശ്രമം, വെള്ളം കുടിക്കൽ, slow breathing മതി. ഇത് severe ആണെങ്കിലോ പലപ്പോഴും ഉണ്ടാകുന്നുവെങ്കിലോ doctor/ASHA worker-നെ കാണുക.',
      AppLanguage.hindi:
          'आज दर्द ज्यादा है, इसलिए आराम, पानी और slow breathing काफी है। यह severe हो या अक्सर हो तो doctor/ASHA worker से बात करें।',
      AppLanguage.manglish:
          'Innu pain kooduthal aanu, rest, water, slow breathing mathi. Severe aanenkil doctor/ASHA worker-ode samsarikkuka.',
    },
    'pregnancy_danger_advice': {
      AppLanguage.english:
          'Please contact an ASHA worker, doctor, or trusted adult soon. This app cannot check emergencies.',
      AppLanguage.malayalam:
          'ദയവായി ഉടൻ ആശാ worker, doctor, അല്ലെങ്കിൽ വിശ്വസിക്കുന്ന മുതിർന്നയാളെ ബന്ധപ്പെടുക. ഈ app emergency പരിശോധിക്കാനാവില്ല.',
      AppLanguage.hindi:
          'कृपया जल्द ASHA worker, doctor या भरोसेमंद बड़े व्यक्ति से बात करें। यह app emergency जांच नहीं कर सकता।',
      AppLanguage.manglish:
          'Vegam ASHA worker, doctor, allenkil trusted adult-ne contact cheyyu. Ee app emergency check cheyyan kazhiyilla.',
    },
    'add_date': {
      AppLanguage.english: 'Add date',
      AppLanguage.malayalam: 'തീയതി ചേർക്കുക',
      AppLanguage.hindi: 'तारीख जोड़ें',
      AppLanguage.manglish: 'Date add cheyyu',
    },
    'years_suffix': {
      AppLanguage.english: 'years',
      AppLanguage.malayalam: 'വയസ്',
      AppLanguage.hindi: 'साल',
      AppLanguage.manglish: 'years',
    },
    'average_cycle_length': {
      AppLanguage.english: 'Average cycle length',
      AppLanguage.malayalam: 'ശരാശരി cycle length',
      AppLanguage.hindi: 'औसत cycle length',
      AppLanguage.manglish: 'Average cycle length',
    },
    'period_duration': {
      AppLanguage.english: 'Period duration',
      AppLanguage.malayalam: 'ആർത്തവ ദിവസങ്ങൾ',
      AppLanguage.hindi: 'पीरियड की अवधि',
      AppLanguage.manglish: 'Period duration',
    },
    'save_details': {
      AppLanguage.english: 'Save details',
      AppLanguage.malayalam: 'വിവരങ്ങൾ സേവ് ചെയ്യുക',
      AppLanguage.hindi: 'जानकारी सेव करें',
      AppLanguage.manglish: 'Details save cheyyu',
    },
    'save': {
      AppLanguage.english: 'Save',
      AppLanguage.malayalam: 'സേവ്',
      AppLanguage.hindi: 'सेव',
      AppLanguage.manglish: 'Save',
    },
    'optional': {
      AppLanguage.english: 'Optional',
      AppLanguage.malayalam: 'ഓപ്ഷണൽ',
      AppLanguage.hindi: 'वैकल्पिक',
      AppLanguage.manglish: 'Optional',
    },
    'saved_private': {
      AppLanguage.english: 'Saved privately on this device',
      AppLanguage.malayalam: 'ഈ ഉപകരണത്തിൽ സ്വകാര്യമായി സേവ് ചെയ്തു',
      AppLanguage.hindi: 'इस डिवाइस में निजी रूप से सेव हुआ',
      AppLanguage.manglish: 'Ee device-il private aayi save cheythu',
    },
    'settings_privacy_local': {
      AppLanguage.english: 'Settings, privacy, and local data',
      AppLanguage.malayalam: 'Settings, privacy, local data',
      AppLanguage.hindi: 'Settings, privacy और local data',
      AppLanguage.manglish: 'Settings, privacy, local data',
    },
    'delete_all_data': {
      AppLanguage.english: 'Delete all data',
      AppLanguage.malayalam: 'എല്ലാ ഡാറ്റയും നീക്കുക',
      AppLanguage.hindi: 'सारा डेटा हटाएं',
      AppLanguage.manglish: 'Ella data-yum delete cheyyu',
    },
    'pregnancy_date_needed': {
      AppLanguage.english: 'Add date to see week-by-week guidance',
      AppLanguage.malayalam: 'ആഴ്ചപ്രകാരമുള്ള guidance കാണാൻ തീയതി ചേർക്കുക',
      AppLanguage.hindi: 'हर सप्ताह की guidance देखने के लिए तारीख जोड़ें',
      AppLanguage.manglish: 'Week-by-week guidance kanan date add cheyyu',
    },
    'pregnancy_history_private': {
      AppLanguage.english: 'Pregnancy history stays private unless deleted.',
      AppLanguage.malayalam:
          'ഡിലീറ്റ് ചെയ്യുന്നതുവരെ pregnancy history സ്വകാര്യമായി തുടരും.',
      AppLanguage.hindi: 'डिलीट करने तक pregnancy history निजी रहेगी।',
      AppLanguage.manglish:
          'Delete cheyyunnath vare pregnancy history private aayi irikkum.',
    },
    'cancel': {
      AppLanguage.english: 'Cancel',
      AppLanguage.malayalam: 'റദ്ദാക്കുക',
      AppLanguage.hindi: 'रद्द करें',
      AppLanguage.manglish: 'Cancel',
    },
    'switch': {
      AppLanguage.english: 'Switch',
      AppLanguage.malayalam: 'മാറുക',
      AppLanguage.hindi: 'बदलें',
      AppLanguage.manglish: 'Switch',
    },
    'private_offline': {
      AppLanguage.english: 'Private & offline',
      AppLanguage.malayalam: 'സ്വകാര്യവും offline-ഉം',
      AppLanguage.hindi: 'निजी और offline',
      AppLanguage.manglish: 'Private & offline',
    },
    'due_date': {
      AppLanguage.english: 'Due date',
      AppLanguage.malayalam: 'Due date',
      AppLanguage.hindi: 'Due date',
      AppLanguage.manglish: 'Due date',
    },
    'pregnancy_on': {
      AppLanguage.english: 'Pregnancy support is on.',
      AppLanguage.malayalam: 'ഗർഭകാല സഹായം ഓണാണ്.',
      AppLanguage.hindi: 'Pregnancy support चालू है।',
      AppLanguage.manglish: 'Pregnancy support on aanu.',
    },
    'weekly_guidance': {
      AppLanguage.english: 'Weekly guidance',
      AppLanguage.malayalam: 'ആഴ്ചയിലെ guidance',
      AppLanguage.hindi: 'साप्ताहिक guidance',
      AppLanguage.manglish: 'Weekly guidance',
    },
    'nutrition_wellbeing': {
      AppLanguage.english: 'Nutrition and wellbeing',
      AppLanguage.malayalam: 'ഭക്ഷണവും wellbeing-ഉം',
      AppLanguage.hindi: 'Nutrition और wellbeing',
      AppLanguage.manglish: 'Nutrition and wellbeing',
    },
    'pregnancy_guidance_1': {
      AppLanguage.english:
          'This week, focus on rest, hydration, and regular meals.',
      AppLanguage.malayalam:
          'ഈ ആഴ്ച വിശ്രമം, വെള്ളം കുടിക്കൽ, regular meals എന്നിവ ശ്രദ്ധിക്കുക.',
      AppLanguage.hindi: 'इस सप्ताह आराम, पानी और regular meals पर ध्यान दें।',
      AppLanguage.manglish: 'Ee week rest, water, regular meals okke nokku.',
    },
    'pregnancy_guidance_2': {
      AppLanguage.english: 'Keep your next ASHA or doctor visit noted.',
      AppLanguage.malayalam: 'അടുത്ത ASHA/doctor visit note ചെയ്ത് വെക്കുക.',
      AppLanguage.hindi: 'अगली ASHA या doctor visit नोट रखें।',
      AppLanguage.manglish: 'Next ASHA/doctor visit note cheythu vekku.',
    },
    'pregnancy_guidance_3': {
      AppLanguage.english:
          'If anything feels severe or unusual, contact a health worker.',
      AppLanguage.malayalam:
          'എന്തെങ്കിലും severe അല്ലെങ്കിൽ unusual ആയി തോന്നിയാൽ health worker-നെ ബന്ധപ്പെടുക.',
      AppLanguage.hindi:
          'कुछ severe या unusual लगे तो health worker से बात करें।',
      AppLanguage.manglish:
          'Enthengilum severe/unusual aayi thonniyal health worker-ne contact cheyyu.',
    },
    'pregnancy_nutrition_1': {
      AppLanguage.english: 'Drink water through the day.',
      AppLanguage.malayalam: 'ദിവസം മുഴുവൻ വെള്ളം കുടിക്കുക.',
      AppLanguage.hindi: 'दिन भर पानी पीते रहें।',
      AppLanguage.manglish: 'Divasam muzhuvan water kudikku.',
    },
    'pregnancy_nutrition_2': {
      AppLanguage.english: 'Take iron or folic acid only as prescribed.',
      AppLanguage.malayalam:
          'Iron/folic acid prescribed ആണെങ്കിൽ മാത്രം കഴിക്കുക.',
      AppLanguage.hindi: 'Iron या folic acid केवल prescribed हो तो लें।',
      AppLanguage.manglish:
          'Iron/folic acid prescribed aanenkil mathram kazhikku.',
    },
    'pregnancy_nutrition_3': {
      AppLanguage.english: 'Balanced meals and rest both count as care.',
      AppLanguage.malayalam: 'Balanced meals-ഉം rest-ഉം രണ്ടും care ആണ്.',
      AppLanguage.hindi: 'Balanced meals और rest दोनों care हैं।',
      AppLanguage.manglish: 'Balanced meals-um rest-um care aanu.',
    },
    'warning_heavy_bleeding': {
      AppLanguage.english: 'Heavy bleeding',
      AppLanguage.malayalam: 'കൂടുതൽ bleeding',
      AppLanguage.hindi: 'ज्यादा bleeding',
      AppLanguage.manglish: 'Heavy bleeding',
    },
    'warning_severe_pain': {
      AppLanguage.english: 'Severe abdominal pain',
      AppLanguage.malayalam: 'കഠിനമായ വയറുവേദന',
      AppLanguage.hindi: 'तेज पेट दर्द',
      AppLanguage.manglish: 'Severe stomach pain',
    },
    'warning_fainting_fever': {
      AppLanguage.english:
          'Fainting, fever, seizures, or severe breathlessness',
      AppLanguage.malayalam:
          'തളർച്ച, പനി, fits, അല്ലെങ്കിൽ severe breathlessness',
      AppLanguage.hindi: 'बेहोशी, बुखार, दौरा या बहुत सांस फूलना',
      AppLanguage.manglish: 'Fainting, fever, fits, severe breathlessness',
    },
    'warning_headache_swelling': {
      AppLanguage.english:
          'Severe headache, blurred vision, or face/hands swelling',
      AppLanguage.malayalam: 'കഠിന തലവേദന, blurred vision, മുഖം/കൈ വീക്കം',
      AppLanguage.hindi: 'तेज सिरदर्द, धुंधला दिखना, चेहरा/हाथ सूजना',
      AppLanguage.manglish:
          'Severe headache, blurred vision, face/hands swelling',
    },
    'warning_baby_movement': {
      AppLanguage.english: 'Reduced baby movement after movement has started',
      AppLanguage.malayalam: 'ചലനം തുടങ്ങിയത് ശേഷം baby movement കുറയുക',
      AppLanguage.hindi: 'movement शुरू होने के बाद baby movement कम होना',
      AppLanguage.manglish:
          'Movement thudangiyathinu shesham baby movement kurayuka',
    },
    'warning_water_leaking': {
      AppLanguage.english: 'Water leaking before the expected date',
      AppLanguage.malayalam: 'പ്രതീക്ഷിക്കുന്ന തീയതിക്ക് മുമ്പ് water leaking',
      AppLanguage.hindi: 'expected date से पहले पानी leak होना',
      AppLanguage.manglish: 'Expected date-nu munpu water leaking',
    },
    'music_for_cycle': {
      AppLanguage.english: 'Music for your cycle',
      AppLanguage.malayalam: 'Cycle music',
      AppLanguage.hindi: 'Cycle music',
      AppLanguage.manglish: 'Cycle music',
    },
    'stored_on_device': {
      AppLanguage.english: 'Stored on your device',
      AppLanguage.malayalam: 'Device-il stored aanu',
      AppLanguage.hindi: 'Device mein stored hai',
      AppLanguage.manglish: 'Device-il stored aanu',
    },
    'no_streaming': {
      AppLanguage.english: 'No streaming',
      AppLanguage.malayalam: 'Streaming illa',
      AppLanguage.hindi: 'Streaming nahi',
      AppLanguage.manglish: 'Streaming illa',
    },
    'now_playing': {
      AppLanguage.english: 'Now playing',
      AppLanguage.malayalam: 'Ippol playing',
      AppLanguage.hindi: 'Abhi playing',
      AppLanguage.manglish: 'Ippol playing',
    },
    'play': {
      AppLanguage.english: 'Play',
      AppLanguage.malayalam: 'Play',
      AppLanguage.hindi: 'Play',
      AppLanguage.manglish: 'Play',
    },
    'pause': {
      AppLanguage.english: 'Pause',
      AppLanguage.malayalam: 'Pause',
      AppLanguage.hindi: 'Pause',
      AppLanguage.manglish: 'Pause',
    },
    'next': {
      AppLanguage.english: 'Next',
      AppLanguage.malayalam: 'Next',
      AppLanguage.hindi: 'Next',
      AppLanguage.manglish: 'Next',
    },
    'previous': {
      AppLanguage.english: 'Previous',
      AppLanguage.malayalam: 'Previous',
      AppLanguage.hindi: 'Previous',
      AppLanguage.manglish: 'Previous',
    },
    'volume': {
      AppLanguage.english: 'Volume',
      AppLanguage.malayalam: 'Volume',
      AppLanguage.hindi: 'Volume',
      AppLanguage.manglish: 'Volume',
    },
    'calm_audio': {
      AppLanguage.english: 'Calm audio for this phase',
      AppLanguage.malayalam: 'Ee phase-inu calm audio',
      AppLanguage.hindi: 'Is phase ke liye calm audio',
      AppLanguage.manglish: 'Ee phase-inu calm audio',
    },
    'audio_file_not_found': {
      AppLanguage.english:
          'Audio file not found. Please check bundled music assets.',
      AppLanguage.malayalam: 'Audio file kandilla. Music assets check cheyyu.',
      AppLanguage.hindi: 'Audio file nahi mili. Music assets check karein.',
      AppLanguage.manglish: 'Audio file kandilla. Music assets check cheyyu.',
    },
    'unable_to_play_track': {
      AppLanguage.english: 'Unable to play this track right now.',
      AppLanguage.malayalam: 'Ippol ee track play cheyyan pattunnilla.',
      AppLanguage.hindi: 'Abhi yeh track play nahi ho pa raha.',
      AppLanguage.manglish: 'Ippol ee track play cheyyan pattunnilla.',
    },
    'music_not_added': {
      AppLanguage.english: 'Music is not added for this phase yet.',
      AppLanguage.malayalam: 'Ee phase-inu music add cheythittilla.',
      AppLanguage.hindi: 'Is phase ke liye music abhi add nahi hua.',
      AppLanguage.manglish: 'Ee phase-inu music add cheythittilla.',
    },
    'playlist': {
      AppLanguage.english: 'playlist',
      AppLanguage.malayalam: 'playlist',
      AppLanguage.hindi: 'playlist',
      AppLanguage.manglish: 'playlist',
    },
    'tracks': {
      AppLanguage.english: 'tracks',
      AppLanguage.malayalam: 'tracks',
      AppLanguage.hindi: 'tracks',
      AppLanguage.manglish: 'tracks',
    },
    'care': {
      AppLanguage.english: 'Care',
      AppLanguage.malayalam: 'Care',
      AppLanguage.hindi: 'Care',
      AppLanguage.manglish: 'Care',
    },
    'pregnancy_calendar': {
      AppLanguage.english: 'Pregnancy Calendar',
      AppLanguage.malayalam: 'Pregnancy calendar',
      AppLanguage.hindi: 'Pregnancy calendar',
      AppLanguage.manglish: 'Pregnancy calendar',
    },
    'pregnancy_calendar_subtitle': {
      AppLanguage.english: 'Appointments, logs, and week guidance',
      AppLanguage.malayalam: 'Appointments, logs, week guidance',
      AppLanguage.hindi: 'Appointments, logs aur week guidance',
      AppLanguage.manglish: 'Appointments, logs, week guidance',
    },
    'days_remaining': {
      AppLanguage.english: 'days remaining',
      AppLanguage.malayalam: 'days remaining',
      AppLanguage.hindi: 'days remaining',
      AppLanguage.manglish: 'days remaining',
    },
    'add_appointment': {
      AppLanguage.english: 'Add appointment',
      AppLanguage.malayalam: 'Appointment add cheyyu',
      AppLanguage.hindi: 'Appointment add karein',
      AppLanguage.manglish: 'Appointment add cheyyu',
    },
    'add_note': {
      AppLanguage.english: 'Add note',
      AppLanguage.malayalam: 'Note add cheyyu',
      AppLanguage.hindi: 'Note add karein',
      AppLanguage.manglish: 'Note add cheyyu',
    },
    'appointment': {
      AppLanguage.english: 'Appointment',
      AppLanguage.malayalam: 'Appointment',
      AppLanguage.hindi: 'Appointment',
      AppLanguage.manglish: 'Appointment',
    },
    'symptom_logged': {
      AppLanguage.english: 'Symptom logged',
      AppLanguage.malayalam: 'Symptom logged',
      AppLanguage.hindi: 'Symptom logged',
      AppLanguage.manglish: 'Symptom logged',
    },
    'energy_low': {
      AppLanguage.english: 'Energy low',
      AppLanguage.malayalam: 'Energy kuravu',
      AppLanguage.hindi: 'Energy low',
      AppLanguage.manglish: 'Energy kuravu',
    },
    'warning_sign_noted': {
      AppLanguage.english: 'Warning sign noted',
      AppLanguage.malayalam: 'Warning sign noted',
      AppLanguage.hindi: 'Warning sign noted',
      AppLanguage.manglish: 'Warning sign noted',
    },
    'notes': {
      AppLanguage.english: 'Notes',
      AppLanguage.malayalam: 'Notes',
      AppLanguage.hindi: 'Notes',
      AppLanguage.manglish: 'Notes',
    },
    'pregnancy_daily_log': {
      AppLanguage.english: 'Pregnancy daily log',
      AppLanguage.malayalam: 'Pregnancy daily log',
      AppLanguage.hindi: 'Pregnancy daily log',
      AppLanguage.manglish: 'Pregnancy daily log',
    },
    'water_intake': {
      AppLanguage.english: 'Water intake',
      AppLanguage.malayalam: 'Water intake',
      AppLanguage.hindi: 'Water intake',
      AppLanguage.manglish: 'Water intake',
    },
    'rest_quality': {
      AppLanguage.english: 'Rest quality',
      AppLanguage.malayalam: 'Rest quality',
      AppLanguage.hindi: 'Rest quality',
      AppLanguage.manglish: 'Rest quality',
    },
    'baby_movement': {
      AppLanguage.english: 'Baby movement felt today',
      AppLanguage.malayalam: 'Baby movement innu feel cheythu',
      AppLanguage.hindi: 'Baby movement aaj feel hua',
      AppLanguage.manglish: 'Baby movement innu feel cheythu',
    },
    'appointment_attended': {
      AppLanguage.english: 'Appointment attended',
      AppLanguage.malayalam: 'Appointment attend cheythu',
      AppLanguage.hindi: 'Appointment attend hua',
      AppLanguage.manglish: 'Appointment attend cheythu',
    },
    'medicine_if_prescribed': {
      AppLanguage.english: 'Medicine/vitamin taken, if prescribed',
      AppLanguage.malayalam: 'Prescribed aanenkil medicine/vitamin eduthu',
      AppLanguage.hindi: 'Prescribed ho to medicine/vitamin liya',
      AppLanguage.manglish: 'Prescribed aanenkil medicine/vitamin eduthu',
    },
    'questions_notes_doctor': {
      AppLanguage.english: 'Notes or questions for doctor',
      AppLanguage.malayalam: 'Doctor-odu chodikkan notes',
      AppLanguage.hindi: 'Doctor ke liye notes/questions',
      AppLanguage.manglish: 'Doctor-odu chodikkan notes',
    },
    'pregnancy_insights': {
      AppLanguage.english: 'Pregnancy Care',
      AppLanguage.malayalam: 'Pregnancy care',
      AppLanguage.hindi: 'Pregnancy care',
      AppLanguage.manglish: 'Pregnancy care',
    },
    'cycle_predictions_paused': {
      AppLanguage.english:
          'Cycle predictions are paused during pregnancy mode. Use pregnancy support, daily logs, and appointments here.',
      AppLanguage.malayalam:
          'Pregnancy mode-il cycle predictions pause cheythu. Support, daily logs, appointments ivide use cheyyu.',
      AppLanguage.hindi:
          'Pregnancy mode mein cycle predictions paused hain. Support, daily logs aur appointments use karein.',
      AppLanguage.manglish:
          'Pregnancy mode-il cycle predictions pause cheythu. Support, daily logs, appointments ivide use cheyyu.',
    },
    'recent_symptoms': {
      AppLanguage.english: 'Recent symptoms',
      AppLanguage.malayalam: 'Recent symptoms',
      AppLanguage.hindi: 'Recent symptoms',
      AppLanguage.manglish: 'Recent symptoms',
    },
    'energy_trend': {
      AppLanguage.english: 'Energy trend',
      AppLanguage.malayalam: 'Energy trend',
      AppLanguage.hindi: 'Energy trend',
      AppLanguage.manglish: 'Energy trend',
    },
    'hydration_rest_reminder': {
      AppLanguage.english: 'Hydration and rest reminder',
      AppLanguage.malayalam: 'Water and rest reminder',
      AppLanguage.hindi: 'Water aur rest reminder',
      AppLanguage.manglish: 'Water and rest reminder',
    },
    'pain_map': {
      AppLanguage.english: 'Pain map',
      AppLanguage.malayalam: 'Pain map',
      AppLanguage.hindi: 'Pain map',
      AppLanguage.manglish: 'Pain map',
    },
    'tap_discomfort': {
      AppLanguage.english: 'Tap where you feel discomfort',
      AppLanguage.malayalam: 'Discomfort ullath tap cheyyu',
      AppLanguage.hindi: 'जहां discomfort हो वहां tap करें',
      AppLanguage.manglish: 'Discomfort ullath tap cheyyu',
    },
    'pain_intensity': {
      AppLanguage.english: 'Pain intensity',
      AppLanguage.malayalam: 'Pain intensity',
      AppLanguage.hindi: 'Pain intensity',
      AppLanguage.manglish: 'Pain intensity',
    },
    'none': {
      AppLanguage.english: 'None',
      AppLanguage.malayalam: 'Illa',
      AppLanguage.hindi: 'नहीं',
      AppLanguage.manglish: 'Illa',
    },
    'mild': {
      AppLanguage.english: 'Mild',
      AppLanguage.malayalam: 'Cheruth',
      AppLanguage.hindi: 'हल्का',
      AppLanguage.manglish: 'Cheruth',
    },
    'moderate': {
      AppLanguage.english: 'Moderate',
      AppLanguage.malayalam: 'Medium',
      AppLanguage.hindi: 'मध्यम',
      AppLanguage.manglish: 'Medium',
    },
    'strong': {
      AppLanguage.english: 'Strong',
      AppLanguage.malayalam: 'Strong',
      AppLanguage.hindi: 'तेज',
      AppLanguage.manglish: 'Strong',
    },
    'strong_pain_cycle_advice': {
      AppLanguage.english:
          'If this pain feels unusual or severe, it may be worth discussing with a doctor or trusted adult.',
      AppLanguage.malayalam:
          'Ee pain unusual allenkil severe aanenkil doctor/trusted adult-ode discuss cheyyunnath nallathaanu.',
      AppLanguage.hindi:
          'अगर यह pain unusual या severe लगे, doctor या trusted adult से बात करना अच्छा रहेगा।',
      AppLanguage.manglish:
          'Ee pain unusual allenkil severe aanenkil doctor/trusted adult-ode discuss cheyyunnath nallathaanu.',
    },
    'stop': {
      AppLanguage.english: 'Stop',
      AppLanguage.malayalam: 'Stop',
      AppLanguage.hindi: 'Stop',
      AppLanguage.manglish: 'Stop',
    },
    'open_player': {
      AppLanguage.english: 'Open player',
      AppLanguage.malayalam: 'Player open cheyyu',
      AppLanguage.hindi: 'Player open karein',
      AppLanguage.manglish: 'Player open cheyyu',
    },
    'front': {
      AppLanguage.english: 'Front',
      AppLanguage.malayalam: 'Front',
      AppLanguage.hindi: 'Front',
      AppLanguage.manglish: 'Front',
    },
    'back': {
      AppLanguage.english: 'Back',
      AppLanguage.malayalam: 'Back',
      AppLanguage.hindi: 'Back',
      AppLanguage.manglish: 'Back',
    },
    'selected': {
      AppLanguage.english: 'Selected',
      AppLanguage.malayalam: 'Selected',
      AppLanguage.hindi: 'Selected',
      AppLanguage.manglish: 'Selected',
    },
    'no_area_selected': {
      AppLanguage.english: 'No area selected yet',
      AppLanguage.malayalam: 'Ithuvare area select cheythittilla',
      AppLanguage.hindi: 'Abhi koi area selected nahi hai',
      AppLanguage.manglish: 'Ithuvare area select cheythittilla',
    },
    'tap_one_or_more': {
      AppLanguage.english: 'Tap one or more body areas.',
      AppLanguage.malayalam: 'Onno athiladhikam body areas tap cheyyu.',
      AppLanguage.hindi: 'Ek ya zyada body areas tap karein.',
      AppLanguage.manglish: 'Onno athiladhikam body areas tap cheyyu.',
    },
    'clear_selection': {
      AppLanguage.english: 'Clear selection',
      AppLanguage.malayalam: 'Selection clear cheyyu',
      AppLanguage.hindi: 'Selection clear karein',
      AppLanguage.manglish: 'Selection clear cheyyu',
    },
    'add_note_optional': {
      AppLanguage.english: 'Add a note (optional)',
      AppLanguage.malayalam: 'Note add cheyyu (optional)',
      AppLanguage.hindi: 'Note add karein (optional)',
      AppLanguage.manglish: 'Note add cheyyu (optional)',
    },
    'pain_note_example': {
      AppLanguage.english: 'Example: cramps started after lunch',
      AppLanguage.malayalam: 'Example: lunch kazhinju cramps thudangi',
      AppLanguage.hindi: 'Example: lunch ke baad cramps shuru hua',
      AppLanguage.manglish: 'Example: lunch kazhinju cramps thudangi',
    },
    'pain_region_head': {
      AppLanguage.english: 'Head',
      AppLanguage.malayalam: 'Thala',
      AppLanguage.hindi: 'Sir',
      AppLanguage.manglish: 'Thala',
    },
    'pain_region_neck': {
      AppLanguage.english: 'Neck',
      AppLanguage.malayalam: 'Kazhutthu',
      AppLanguage.hindi: 'Gardan',
      AppLanguage.manglish: 'Kazhutthu',
    },
    'pain_region_shoulders': {
      AppLanguage.english: 'Shoulders',
      AppLanguage.malayalam: 'Shoulders',
      AppLanguage.hindi: 'Shoulders',
      AppLanguage.manglish: 'Shoulders',
    },
    'pain_region_chest': {
      AppLanguage.english: 'Chest',
      AppLanguage.malayalam: 'Chest',
      AppLanguage.hindi: 'Chest',
      AppLanguage.manglish: 'Chest',
    },
    'pain_region_upper_abdomen': {
      AppLanguage.english: 'Upper abdomen',
      AppLanguage.malayalam: 'Upper abdomen',
      AppLanguage.hindi: 'Upper abdomen',
      AppLanguage.manglish: 'Upper abdomen',
    },
    'pain_region_lower_abdomen': {
      AppLanguage.english: 'Lower abdomen',
      AppLanguage.malayalam: 'Lower abdomen',
      AppLanguage.hindi: 'Lower abdomen',
      AppLanguage.manglish: 'Lower abdomen',
    },
    'pain_region_upper_back': {
      AppLanguage.english: 'Upper back',
      AppLanguage.malayalam: 'Upper back',
      AppLanguage.hindi: 'Upper back',
      AppLanguage.manglish: 'Upper back',
    },
    'pain_region_middle_back': {
      AppLanguage.english: 'Middle back',
      AppLanguage.malayalam: 'Middle back',
      AppLanguage.hindi: 'Middle back',
      AppLanguage.manglish: 'Middle back',
    },
    'pain_region_lower_back': {
      AppLanguage.english: 'Lower back',
      AppLanguage.malayalam: 'Lower back',
      AppLanguage.hindi: 'Lower back',
      AppLanguage.manglish: 'Lower back',
    },
    'pain_region_left_arm': {
      AppLanguage.english: 'Left arm',
      AppLanguage.malayalam: 'Left arm',
      AppLanguage.hindi: 'Left arm',
      AppLanguage.manglish: 'Left arm',
    },
    'pain_region_right_arm': {
      AppLanguage.english: 'Right arm',
      AppLanguage.malayalam: 'Right arm',
      AppLanguage.hindi: 'Right arm',
      AppLanguage.manglish: 'Right arm',
    },
    'pain_region_left_thigh': {
      AppLanguage.english: 'Left thigh',
      AppLanguage.malayalam: 'Left thigh',
      AppLanguage.hindi: 'Left thigh',
      AppLanguage.manglish: 'Left thigh',
    },
    'pain_region_right_thigh': {
      AppLanguage.english: 'Right thigh',
      AppLanguage.malayalam: 'Right thigh',
      AppLanguage.hindi: 'Right thigh',
      AppLanguage.manglish: 'Right thigh',
    },
    'pain_region_left_lower_leg': {
      AppLanguage.english: 'Left lower leg',
      AppLanguage.malayalam: 'Left lower leg',
      AppLanguage.hindi: 'Left lower leg',
      AppLanguage.manglish: 'Left lower leg',
    },
    'pain_region_right_lower_leg': {
      AppLanguage.english: 'Right lower leg',
      AppLanguage.malayalam: 'Right lower leg',
      AppLanguage.hindi: 'Right lower leg',
      AppLanguage.manglish: 'Right lower leg',
    },
    'pain_region_hips': {
      AppLanguage.english: 'Hips',
      AppLanguage.malayalam: 'Hips',
      AppLanguage.hindi: 'Hips',
      AppLanguage.manglish: 'Hips',
    },
  };

  static String t(String key, AppLanguage language) =>
      values[key]?[language] ?? values[key]?[fallback] ?? key;
}
