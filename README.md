# PaceUp - Bežecká aplikácia

Jednoduchá Flutter aplikácia na sledovanie bežeckých aktivít a progresu voči cieľu.

## Ako spustiť aplikáciu

```bash
# 1. Nainštaluj závislosti
flutter pub get

# 2. Spusti aplikáciu
flutter run
```

## Štruktúra projektu

```
lib/
├── main.dart                    # Hlavný vstupný bod aplikácie
├── models/
│   └── activity.dart            # Model pre bežeckú aktivitu
├── services/
│   └── api_service.dart         # Service s mock API a biznis logikou
└── screens/
    ├── dashboard_screen.dart    # Hlavná obrazovka s cieľom a progressom
    └── activities_screen.dart   # Zoznam aktivít
```

## Funkcie (MVP)

✅ Dashboard s výberom cieľa (5K, 10K, polmaratón, maratón)
✅ Progress bar zobrazujúci % splnenia cieľa
✅ Načítanie mock aktivít (tlačidlo "Načítať aktivity")
✅ Zoznam aktivít s detailmi (vzdialenosť, čas, tempo, dátum)
✅ Uloženie vybraného cieľa pomocou shared_preferences

## Ako to funguje

1. Aplikácia sa spustí na Dashboard obrazovke
2. Používateľ si vyberie cieľ z dropdownu (default: 10K)
3. Stlačí tlačidlo "Načítať aktivity"
4. Aplikácia načíta mock dáta z ApiService
5. Zobrazí sa progress bar a celková vzdialenosť
6. Po kliknutí na "Zobraziť aktivity" sa otvorí zoznam všetkých aktivít

## Technológie

- **Flutter 3.38.5** + Dart 3.10.4
- **http** - HTTP requesty (zatiaľ mock dáta)
- **shared_preferences** - lokálne uloženie cieľa
- **Material Design** - UI komponenty

## Mock dáta

Aplikácia zatiaľ používa hardcoded mock dáta v `api_service.dart`. Pre reálne API stačí upraviť metódu `fetchActivities()` na skutočný HTTP GET request.
