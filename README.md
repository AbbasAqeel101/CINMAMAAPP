# 🎬 سينمانا - دليل المشروع

## هيكل المشروع
```
CinemanaApp/
├── CinemanaApp.swift          ← نقطة الدخول
├── Models/
│   └── Models.swift           ← نماذج البيانات (Media, User, Category)
├── Network/
│   └── NetworkManager.swift   ← التواصل مع API + بيانات تجريبية
├── ViewModels/
│   └── HomeViewModel.swift    ← منطق الواجهة الرئيسية
└── Views/
    ├── HomeView.swift         ← الواجهة الرئيسية
    ├── DetailView.swift       ← صفحة تفاصيل الفيلم/المسلسل
    ├── PlayerView.swift       ← مشغل الفيديو
    ├── SearchView.swift       ← صفحة البحث
    └── ProfileView.swift      ← صفحة الملف الشخصي + تسجيل الدخول
```

## كيفية البدء في Xcode

1. افتح Xcode → New Project → App
2. اختر SwiftUI كـ Interface
3. احذف الملفات الافتراضية
4. أضف الملفات من هذا المجلد
5. شغّل التطبيق! ✅

## تخصيص التطبيق

### ربط API الخاص بك
في ملف `NetworkManager.swift`:
```swift
private let baseURL = "https://your-api.com/api/v1"  // ← غيّر هذا
```

### إضافة أفلام حقيقية
في `MockData` داخل `NetworkManager.swift`، استبدل البيانات التجريبية ببيانات من API.

### إضافة روابط الفيديو
في نموذج `Media`، أضف الرابط في `streamURL`:
```swift
Media(id: 1, ..., streamURL: "https://your-server.com/video.m3u8")
```

## الميزات الموجودة ✅
- [x] الواجهة الرئيسية مع بانر وفئات
- [x] بطاقات الأفلام مع الصور والتقييم
- [x] صفحة التفاصيل
- [x] مشغل فيديو (AVKit)
- [x] البحث مع debounce
- [x] صفحة الملف الشخصي
- [x] تسجيل الدخول (واجهة جاهزة)

## الميزات القادمة 🔜
- [ ] نظام المفضلة
- [ ] سجل المشاهدة
- [ ] التحميل للمشاهدة بدون انترنت
- [ ] دعم Google & Facebook Login
- [ ] دعم الاشتراكات
