#!/usr/bin/env python3
with open('D:/Agent/fish/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Patch 3: syncEnvData - show trend arrow
old3 = """async function syncEnvData() {
            if(!currentCoords) return;
            try {
                const data = await fetchWeather(currentCoords.lat, currentCoords.lon);
                $('pressure-value').textContent = data.pressure;
                updateWeatherText(data.weatherCode);
                $('water-temp-value').textContent = data.waterTemp;
                updateWindDisplay(data.windSpeed, data.windDir);
            } catch {}
        }"""

new3 = """async function syncEnvData() {
            if(!currentCoords) return;
            try {
                const data = await fetchWeather(currentCoords.lat, currentCoords.lon);
                const pTrend = getPressureTrend(data.hourlyPressure);
                $('pressure-value').innerHTML = data.pressure + ` <span class="text-xs ${pTrend.trend==='rising'?'text-emerald-400':pTrend.trend==='falling'?'text-rose-400':'text-slate-400'}">${pTrend.arrow}</span>`;
                updateWeatherText(data.weatherCode);
                $('water-temp-value').textContent = data.waterTemp;
                updateWindDisplay(data.windSpeed, data.windDir);
            } catch {}
        }"""

assert old3 in content, 'Patch 3 FAILED'
content = content.replace(old3, new3, 1)
print('Patch 3 OK')

# Patch 4a: generateExpertTips signature
old4a = "function generateExpertTips(weatherCode, windLevel, waterTemp, isSaltwater, tempDiffData) {"
new4a = "function generateExpertTips(weatherCode, windLevel, waterTemp, isSaltwater, tempDiffData, pressureTrend, moonPhase, season) {"
assert old4a in content, 'Patch 4a FAILED'
content = content.replace(old4a, new4a, 1)
print('Patch 4a OK')

# Patch 4b: add season/moon/pressure tips
old4b = """            if(isSaltwater) {
                tips.push(t('tip_saltwater'));
            }
            return tips.length ? tips : [t('tip_none')];"""

new4b = """            // Phase 1: season insight
            if(season && SEASON_TIPS[season]) {
                tips.push('<span class=\"text-emerald-400 font-semibold\"><i class=\"fas fa-calendar\"></i> ' + SEASON_NAMES[season] + '\uff1a</span>' + SEASON_TIPS[season]);
            }
            // Phase 1: moon phase
            if(moonPhase && moonPhase.name) {
                tips.push('<span class=\"text-indigo-400 font-semibold\">' + moonPhase.name + '</span> ' + (moonPhase.tip || '\u6708\u76f8\u6b63\u5e38\uff0c\u6309\u5e38\u89c4\u51fa\u9493'));
            }
            // Phase 1: pressure trend
            if(pressureTrend && pressureTrend.text) {
                const trendColors = {rising:'text-emerald-400',falling:'text-rose-400',stable:'text-slate-300'};
                tips.push('<span class=\"' + (trendColors[pressureTrend.trend]||'text-slate-300') + ' font-semibold\"><i class=\"fas fa-gauge-high\"></i> ' + pressureTrend.arrow + ' \u6c14\u538b\u8d8b\u52bf\uff1a</span> ' + pressureTrend.text);
            }
            if(isSaltwater) {
                tips.push(t('tip_saltwater'));
            }
            return tips.length ? tips : [t('tip_none')];"""

assert old4b in content, 'Patch 4b FAILED'
content = content.replace(old4b, new4b, 1)
print('Patch 4b OK')

# Patch 5: calculatePrediction - compute and pass
old5 = """                const tips = generateExpertTips(weatherData.weatherCode, wind, wt, $('fishing-type').value==='saltwater', tempDiffData);"""

new5 = """                const season = getSeason(dt.getMonth() + 1, lat);
                const moonPhase = calculateMoonPhase(dt);
                const pressureTrend = getPressureTrend(weatherData.hourlyPressure);
                const tips = generateExpertTips(weatherData.weatherCode, wind, wt, $('fishing-type').value==='saltwater', tempDiffData, pressureTrend, moonPhase, season);"""

assert old5 in content, 'Patch 5 FAILED'
content = content.replace(old5, new5, 1)
print('Patch 5 OK')

with open('D:/Agent/fish/index.html', 'w', encoding='utf-8') as f:
    f.write(content)

print('ALL DONE!')
print(f'File size: {len(content)} bytes')
