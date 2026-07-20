# 🎣 DiaoLaMe (钓拉么)

> Smart Fishing Environment Prediction & Tactical Decision System

[🇨🇳 中文](README.md) · [🇯🇵 日本語](README.ja.md) · [🇰🇷 한국어](README.ko.md)

---

**DiaoLaMe** is a beautifully designed, lightweight web tool for fishing enthusiasts. The system integrates global real-time weather data with dynamic water temperature algorithms, transforming complex raw data into an intuitive 0-100 fishing index with customized tactical advice — so you know the conditions before you go.

## ✨ Key Features

### 1. Core Prediction Algorithm (Five-Axis Matrix)
A five-dimensional weighted algorithm for in-depth environmental analysis:

| Dimension | Weight | Description |
|:----|:----:|:----|
| Time Factor | 30% | Dawn/dusk periods, circadian rhythm |
| Pressure Stability | 20% | Real-time barometric tracking for fish activity |
| Weather Stability | 20% | Filters sudden weather changes |
| Wind & Oxygen | 15% | Wind effects on surface water oxygenation |
| Water Temperature | 15% | Water temp estimation from air temp trends |

### 2. Interactive Map (Leaflet)
- **Clean visuals**: Minimalist white map tiles
- **Immersive layout**: Full-width edge-to-edge map
- **Smart zoom**: Auto-focus on your fishing spot within 3km radius

### 3. Environmental Alerts
- **Temperature Warning**: Red alert when 7-day温差 (temp difference) exceeds 12°C — a key predictor of fish stopping feeding
- **Dynamic Tactics**: Auto-switches between freshwater and saltwater modes, suggesting baits, depths, and rigs
- **Pressure Trend**: Real-time arrow indicator (rising/falling/stable)
- **Moon Phase**: Calculates lunar phase for night fishing assessment

### 4. Multi-language
- 🇨🇳 Chinese · 🇬🇧 English · 🇯🇵 Japanese · 🇰🇷 Korean

## 🛠️ Tech Stack

| Technology | Purpose |
|:----|:----|
| Tailwind CSS | Responsive layout & typography |
| Leaflet.js | Map engine |
| Open-Meteo | Weather, wind, temperature data |
| Open-Meteo Marine | Sea Surface Temperature (SST) |
| Amap (高德) | Geocoding & reverse geocoding |

## 🚀 Deployment

### Quick Start
Open `index.html` directly in your browser — no installation needed.

### Online (Recommended)
HTTPS is required for geolocation API accuracy:

#### Vercel (Preferred)
1. Connect your GitHub repository
2. Vercel auto-detects and deploys as a static site

#### GitHub Pages
1. Push code to your repository
2. Enable Pages in Settings → Pages

## 🎮 How to Use

1. **Pick your spot**: Search an address or click anywhere on the map
2. **Set preferences**: Switch freshwater/saltwater mode, set fishing time
3. **Get prediction**: Click "Start Prediction" for real-time environmental scoring
4. **Review tactics**: Read expert tips generated based on current conditions

## 📄 Data Notes

- **Water Temperature**: Coastal areas use Open-Meteo Marine API SST data; inland areas fall back to air temperature estimation
- **Temperature Analysis**: Based on 7-day SST or air temperature daily range to assess water temperature fluctuation impact on fish activity

## ⚠️ Disclaimer

Prediction scores and suggestions are based on meteorological algorithm models for reference only. Actual fishing results are affected by local water visibility, fishing pressure, real-time water flow, and other uncontrollable factors. Always prioritize safety and comply with local environmental and fishing regulations.

---

© 2026 DiaoLaMe | 24/7 Automated Analysis
