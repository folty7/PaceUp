# PaceUp docs

---

## Stručný popis aplikácie:

PaceUp umožní používateľom sledovať svoje bežecké aktivity a vyhodnocovať progres smerom k stanovenému cieľu.

Aplikácia načíta dáta z **mock REST API** a zobrazí ich v prehľadnom rozhraní. Projekt je realizovaný ako **MVP (Minimum Viable Product)** vo Flutteri s dôrazom na **asynchrónne programovanie**, **prácu s REST API** a **základné Flutter UI komponenty**.

---

## Podobné aplikácie:

1. **Strava** – platforma pre sledovanie športových aktivít s komunitnými funkciami
    
    🔗 https://www.strava.com
    
    📱 [Google Play](https://play.google.com/store/apps/details?id=com.strava)
    
2. **Nike Run Club** – aplikácia na sledovanie behov, výziev a tréningových plánov
    
    🔗 https://www.nike.com/nrc-app
    
    📱 [Google Play](https://play.google.com/store/apps/details?id=com.nike.plusgps)
    

---

## Minimálna funkcionalita (MVP):

✅ **Jednoduchý vstup do aplikácie** – tlačidlo "Začať ako TestUser" (bez prihlásenia)

✅ **Načítanie bežeckých aktivít z mock REST API** – vzdialenosť, čas, dátum

✅ **Výber cieľa** – dropdown na výber z predpripravených cieľov (5K, 10K, polmaratón, maratón)

✅ **Výpočet a zobrazenie progresu** – percentuálne dokončenie cieľa na základe celkovej vzdialenosti

✅ **Lokálne uloženie vybraného cieľa** – pomocou `shared_preferences`

---

## Obrazovky aplikácie (screens):

### 1. **Dashboard (Domovská obrazovka)**

- Zobrazenie aktuálneho cieľa (napr. "Cieľ: 10 km")
- Progress bar s percentom splnenia (napr. "65% dokončené")
- Celková nabehaná vzdialenosť
- Tlačidlo **"Načítať aktivity"** – zavolá API a aktualizuje dáta
- Dropdown na **zmenu cieľa**

### 2. **Zoznam aktivít**

- ListView načítaných bežeckých aktivít z API
- Každá položka zobrazuje: dátum, vzdialenosť, čas, tempo
- Použitie `FutureBuilder` na asynchrónne načítanie dát

### 3. *(Voliteľné)* **Obrazovka výberu cieľa**

- Samostatná obrazovka s kartami pre každý cieľ (5K, 10K, 21K, 42K)
- Po výbere cieľa sa uloží a vráti na Dashboard

---

## Technologický stack:

| Vrstva | Technológia | Účel / Popis |
| --- | --- | --- |
| **Frontend / UI** | Flutter (Dart) | Mobilná aplikácia s Material Design |
| **REST API** | Mock REST API (MockAPI.io alebo hardcoded JSON) | Simulácia backend API pre asynchrónne volania |
| **HTTP klient** | `http` package | Načítanie dát z API (`GET` request) |
| **Asynchrónne programovanie** | `async/await`, `Future`, `FutureBuilder` | Práca s asynchrónnymi operáciami |
| **Lokálne úložisko** | `shared_preferences` | Uloženie vybraného cieľa a základných nastavení |
| **State management** | `setState()` + `FutureBuilder` | Jednoduché riadenie stavu bez externých knižníc |
| **UI komponenty** | Material Design (Flutter widgets) | `ListView`, `Card`, `LinearProgressIndicator`, `DropdownButton` |

---

## Dátový model (JSON z API):

**Príklad odpovede z mock API:**

```json
[
  {
    "id": 1,
    "distance": 5.2,
    "duration": 28,
    "date": "2025-01-05",
    "pace": 5.38
  },
  {
    "id": 2,
    "distance": 3.8,
    "duration": 21,
    "date": "2025-01-03",
    "pace": 5.52
  }
]

```

**Dart model trieda:**

```dart
class Activity {
  final int id;
  final double distance; // km
  final int duration;    // minúty
  final String date;
  final double pace;     // min/km

  Activity({
    required this.id,
    required this.distance,
    required this.duration,
    required this.date,
    required this.pace,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      distance: json['distance'].toDouble(),
      duration: json['duration'],
      date: json['date'],
      pace: json['pace'].toDouble(),
    );
  }
}

```

---

## Výpočet progresu k cieľu:

**Logika:**

1. Používateľ si vyberie cieľ (napr. 10 km)
2. Aplikácia načíta všetky aktivity z API
3. Spočíta celkovú nabehanú vzdialenosť
4. Vypočíta percento: `(celková vzdialenosť / cieľ) * 100`

**Príklad kódu:**

```dart
double calculateProgress(List<Activity> activities, double goalDistance) {
  double totalDistance = activities.fold(0, (sum, activity) => sum + activity.distance);
  return (totalDistance / goalDistance) * 100;
}

```

---

## Flow aplikácie:

```
1. Spustenie aplikácie
   ↓
2. Dashboard (zobrazí aktuálny cieľ a progres)
   ↓
3. Tlačidlo "Načítať aktivity"
   ↓
4. HTTP GET request na mock API
   ↓
5. Parsovanie JSON → List<Activity>
   ↓
6. Výpočet progresu
   ↓
7. Zobrazenie v UI (FutureBuilder)
   ↓
8. Používateľ môže zmeniť cieľ (dropdown)
   ↓
9. Uloženie do shared_preferences

```

---

## Použité Flutter packages:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0              # HTTP requesty
  shared_preferences: ^2.2.2 # Lokálne úložisko

```

---

## Čo projekt demonštruje:

✅ **Asynchrónne programovanie** – `async/await`, `Future`, `FutureBuilder`

✅ **Práca s REST API** – HTTP GET request, parsovanie JSON

✅ **Flutter UI** – `ListView`, `Card`, `LinearProgressIndicator`, `DropdownButton`

✅ **Lokálne úložisko** – ukladanie dát pomocou `shared_preferences`

✅ **Základná business logika** – výpočet progresu, práca s dátami

---

## Možné rozšírenia (mimo MVP):

- 🔹 Pridanie animácií pri načítavaní dát
- 🔹 Grafy progresu v čase (package: `fl_chart`)
- 🔹 Notifikácie pri dosiahnutí cieľa
- 🔹 Export dát do CSV
- 🔹 Integrácia so skutočným API (Strava, Runkeeper)