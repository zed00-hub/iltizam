# 🛡️ تطبيق "التـزام" (Eltizam) - دبابة الالتزام

> تطبيق انضباط وعادات يومية نخبوي مصمم وفق أعلى معايير هندسة البرمجيات والتصميم العصري (Ultra-Modern Dark OLED).

---

## 🌟 الميزات الجوهرية للتطبيق:

1. **محرك العادات الأربعة المتكامل**:
   - **عادات نعم/لا مع وسوم نوعية**: مثل *صلاة الفجر في المسجد* مع وسوم (في المسجد، مع تكبيرة الإحرام، في البيت، قضاء).
   - **عادات دورية وأسبوعية**: مثل *تمرين رياضي 4 أيام في الأسبوع*، مع احتساب إتمام الأسبوع كوحدة سلسلة ناجحة وتتبع الأسابيع المتتالية.
   - **عادات كمية ورقمية**: مثل *ورد القرآن الكريم (20 صفحة)* أو *شرب 3 لترات ماء*، مع أزرار الزيادة السريعة وشريط التقدم.
   - **عادات مرتبطة بالوقت والتركيز**: مثل *جلسة عمل عميق أو قراءة* بمؤقت بومودورو وستوب ووتش تفاعلي مدمج.

2. **محرك السلاسل والانضباط (Streak & Resilience Engine)**:
   - **حساب الأيام المستحقة**: تُحسب السلسلة الحالية (Current Streak) والأفضل تاريخياً (Best Streak) بناءً على الأيام المجدولة لكل عادة وليس الأيام التقويمية فقط.
   - **مؤشر قوة العادة (Habit Strength Score %)**: خوارزمية ذكية تعتمد على التراكم والذاكرة الأسية (Exponential Memory Decay) بحيث لا ينهار جهد شهر كامل لصفر بسبب تعثر عارض في يوم واحد.
   - **نظام التجميد (Streak Freeze)**: إمكانية تجميد السلسلة وحمايتها في الظروف القهرية دون احتسابها كيوم إنجاز مزيف.
   - **قاعدة اليومين (Never Miss Twice)**: تنبيه فوري ووسام حماية مشدد عند تفويت يوم سابق لمنع الانقطاع المتتالي.

3. **الهوية البصرية والتلعيب الراقي**:
   - واجهة Dark OLED فاخرة بلمسات زمردية (`#10B981`) وذهبية (`#F59E0B`).
   - خط **Cairo** العربي المتناسق والمدعوم كاملاً لاتجاه اليمين إلى اليسار (RTL).
   - شبكة مربعات نشاط (GitHub-style Contribution Heatmap) لعرض الالتزام على مدار الأسابيع والشهور.
   - نظام خبرة (XP) ورتب تصاعدية تبدأ من (مبتدئ) حتى تصل إلى الرتبة الكبرى: **دبابة التزام** 🏆.
   - أوسمة وشارات إنجاز للأرقام القياسية وصلاة الفجر والسلاسل الطويلة.

4. **العمل بدون إنترنت والأمان المحلي (Offline-First)**:
   - يعمل محلياً بالكامل وفائق السرعة (Zero Latency).
   - ميزة تصدير واستيراد النسخ الاحتياطية بصيغة JSON لنقل البيانات بأمان.

---

## 🚀 كيفية تشغيل التطبيق:

### 1. التشغيل السريع في المتصفح (Web / Chrome):
انقر نقراً مزدوجاً على الملف:
```cmd
run_eltizam_web.bat
```
أو عبر الطرفية (Terminal):
```powershell
$env:PATH = "C:\src\flutter\bin;$env:PATH"
flutter run -d chrome
```

### 2. تشغيل الاختبارات الوحدوية:
```powershell
$env:PATH = "C:\src\flutter\bin;$env:PATH"
flutter test
```

---

## 📁 هيكلية المشروع (Clean Architecture):
```
lib/
├── core/
│   ├── constants/ (الألوان، الخطوط، الثيمات)
│   ├── theme/ (AppTheme Dark OLED / Light)
│   └── utils/ (DateUtils, Haptics)
├── features/
│   └── habits/
│       ├── domain/
│       │   ├── models/ (Habit, HabitRecord, HabitType, UserLevel)
│       │   └── services/ (StreakEngine, HabitStrengthCalculator, GamificationEngine)
│       ├── data/ (LocalStorageService, HabitRepository)
│       └── presentation/
│           ├── providers/ (Riverpod Notifiers & Computed Metrics)
│           ├── widgets/ (HabitCard, HeatmapCalendar, FocusTimerDialog, ProgressRingHeader, ...)
│           └── screens/ (DashboardScreen, HabitDetailScreen, AnalyticsScreen, SettingsScreen)
└── main.dart
```
