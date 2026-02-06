
# Weather App (Flutter)

A modern Flutter weather application that fetches real time weather data using the OpenWeather API.  
Built as part of my Flutter portfolio to demonstrate API integration, state handling, persistence, and clean UI design.

## ✨ Features

- 🔍 Search weather by city name  
- 🌡️ Real time temperature & conditions  
- 💧 Extra info: feels like, humidity, wind speed  
- 💾 Remembers last searched city  
- 🌓 Light & Dark mode (saved automatically)  
- ⏳ Skeleton loading UI  
- 🌐 Web ready (runs on Windows, Web, Android)

## 🛠️ Tech Stack

- **Flutter**
- **Dart**
- **OpenWeather API**
- `http` : API requests  
- `shared_preferences` – local persistence  
- Material 3 UI

## 🚀 Getting Started

1. Clone the repo:

```bash
git clone https://github.com/Emma005991/weather-app.git
cd weather-app
````

2. Install dependencies:

```bash
flutter pub get
```

3. Add your OpenWeather API key in `lib/main.dart`:

```dart
static const String apiKey = "YOUR_API_KEY";
```

4. Run the app:

```bash
flutter run
```

## 🎯 Purpose

This project is part of my Flutter portfolio. It demonstrates:

* API consumption
* Async programming
* State management
* UI/UX design
* Cross platform Flutter development

---

Built by **Emmanuel** 



