#!/usr/bin/env python3
import sys

with open('D:/Agent/fish/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Patch 2: fetchWeather with hourly pressure
old2 = """async function fetchWeather(lat, lon) {
            try {
                const url = `${OPENMETEO_BASE}?latitude=${lat}&longitude=${lon}&current=pressure_msl,weather_code,temperature_2m,wind_speed_10m,wind_direction_10m&timezone=auto`;
                const res = await fetch(url);
                if(!res.ok) throw new Error('天气API失败');
                const {current} = await res.json();
                return {
                    pressure: Math.round(current.pressure_msl),
                    weatherCode: current.weather_code,
                    waterTemp: Math.max(5, Math.min(35, Math.round(current.temperature_2m + 2))),
                    windSpeed: current.wind_speed_10m,
                    windDir: current.wind_direction_10m
                };
            } catch(e){
                handleApiError(e,'天气');
                return {pressure:1013, weatherCode:3, waterTemp:20, windSpeed:3, windDir:0};
            }
        }"""

new2 = """async function fetchWeather(lat, lon) {
            try {
                const url = `${OPENMETEO_BASE}?latitude=${lat}&longitude=${lon}&current=pressure_msl,weather_code,temperature_2m,wind_speed_10m,wind_direction_10m&hourly=pressure_msl&past_hours=12&forecast_hours=1&timezone=auto`;
                const res = await fetch(url);
                if(!res.ok) throw new Error('天气API失败');
                const data = await res.json();
                const {current, hourly} = data;
                const hourlyP = hourly?.pressure_msl?.filter(v=>v!==null) || [];
                return {
                    pressure: Math.round(current.pressure_msl),
                    weatherCode: current.weather_code,
                    waterTemp: Math.max(5, Math.min(35, Math.round(current.temperature_2m + 2))),
                    windSpeed: current.wind_speed_10m,
                    windDir: current.wind_direction_10m,
                    hourlyPressure: hourlyP
                };
            } catch(e){
                handleApiError(e,'天气');
                return {pressure:1013, weatherCode:3, waterTemp:20, windSpeed:3, windDir:0, hourlyPressure:[]};
            }
        }"""

assert old2 in content, 'Patch 2 FAILED: fetchWeather not found'
content = content.replace(old2, new2, 1)
print('Patch 2 OK')

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

assert old3 in content, 'Patch 3 FAILED: syncEnvData not found'
content = content.replace(old3, new3, 1)
print('Patch 3 OK')

# Patch 4a: generateExpertTips signature
old4a = "function generateExpertTips(weatherCode, windLevel, waterTemp, isSaltwater, tempDiffData) {"
new4a = "function generateExpertTips(weatherCode, windLevel, waterTemp, isSaltwater, tempDiffData, pressureTrend, moonPhase, season) {"
assert old4a in content, 'Patch 4a FAILED'
content = content.replace(old4a, new4a, 1)
print('Patch 4a OK')

# Patch 4b: add season/moon/pressure tips before saltwater
old4b = """            if(isSaltwater) {
                tips.push(t('tip_saltwater'));
            }
            return tips.length ? tips : [t('tip_none')];"""

new4b = """            // Phase 1: season insight
            if(season && SEASON_TIPS[season]) {
                tips.push('<span class=\"text-emerald-400 font-semibold\"><i class=\"fas fa-calendar\"></i> ' + SEASON_NAMES[season] + '：</span>' + SEASON_TIPS[season]);
            }
            // Phase 1: moon phase
            if(moonPhase && moonPhase.name) {
                tips.push('<span class=\"text-indigo-400 font-semibold\">' + moonPhase.name + '</span> ' + (moonPhase.tip || '月相正常，按常规出钓'));
            }
            // Phase 1: pressure trend
            if(pressureTrend && pressureTrend.text) {
                const trendColors = {rising:'text-emerald-400',falling:'text-rose-400',stable:'text-slate-300'};
                tips.push('<span class=\"' + (trendColors[pressureTrend.trend]||'text-slate-300') + ' font-semibold\"><i class=\"fas fa-gauge-high\"></i> ' + pressureTrend.arrow + ' 气压趋势：</span> ' + pressureTrend.text);
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

print('ALL PATCHES APPLIED SUCCESSFULLY!')
print(f'Final file size: {len(content)} bytes')
