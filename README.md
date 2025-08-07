# Masjid Silencer

*Auto‑mute your Android phone when you arrive at the closest masjid.*

---

## Features

- **Auto‑silence** – one toggle and your ringer switches to **Silent** whenever you enter a mosque radius, then restores on exit.
- **Official masjid database** – tap **Update** in *Settings* to download the latest CSV (`uae_mosques.csv`) from GitHub; the first 80 entries are armed as geofences.
- **My Custom Locations** – add your own coordinates + label; long‑press to delete; tap the 📧 icon to mail the record to `Akhmad6093@gmail.com` for inclusion in the public list.
- **Manual test buttons** – *Silence Now / Restore* (Home) and *Test Silence (2 s)* (Settings) to prove DND permission works.
- **Persistent notification** – shows *Masjid Silencer active* while auto‑silence is enabled so you always know it’s running.

---

## Screenshots


### Home
![alt text](https://github.com/Astrobubu/MasjidSilencerApp/blob/main/screenshot1.jpg) 

### Settings
![alt text](https://github.com/Astrobubu/MasjidSilencerApp/blob/main/screenshot2.jpg) 

---

## Getting Started

```bash
# clone the repo
flutter pub get          # install dependencies
flutter run              # launch on a device / emulator
```

### Permissions prompted at first run

- **Location – “Allow all the time”** (background geofencing)
- **Do‑Not‑Disturb access** (change ringer mode)
- **Ignore Battery Optimisations** (prevent OEMs from killing GPS)

---

## Limitations & Work‑arounds

- **Background reliability** – Some OEM skins (Xiaomi MIUI, Huawei EMUI, etc.) stop background services aggressively. Add *Masjid Silencer* to the system’s *Unrestricted* / *Don’t optimise* list if auto‑silence stops after a while.
- **100‑geofence system cap** – Android only allows 100 regions per app; code registers every custom location then the first 80 official mosques to stay under the limit.
- **Very small radii** (<100 m) are ignored by Google Play Services.

---

## Updating the Official DB

1. Open **Settings → Official DB** and tap **Update**.
2. CSV fetched from [https://raw.githubusercontent.com/Astrobubu/MasjidSilencerApp/main/uae\_mosques.csv](https://raw.githubusercontent.com/Astrobubu/MasjidSilencerApp/main/uae_mosques.csv) is cached locally.
3. Toggle **Auto‑silence** off → on (or restart the app) to re‑arm geofences.

---

\## Contributing

- Fork → create a feature branch → Pull Request.
- Or just mail a new location via the 📧 button next to any *My Custom Location* entry.

---

\## License

[MIT](LICENSE) © 2025 Akhmad K.

