<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="description" content="钓了么 - 基于实时气象、风况的智能钓鱼预测工具">
    <meta name="theme-color" content="#0f172a">
    <!-- Favicon -->
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🎣</text></svg>">
    <!-- PWA Manifest -->
    <link rel="manifest" href="/manifest.json">
    <title>钓了么 - 智能钓鱼预测</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Leaflet CSS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="" />
    <!-- Leaflet JS -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
    
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: { sans: ['Inter', 'sans-serif'] },
                    colors: {
                        ocean: { 900: '#0f172a', 800: '#1e293b', 700: '#334155' },
                        glass: { 100: 'rgba(255,255,255,0.08)', 200: 'rgba(255,255,255,0.15)', border: 'rgba(255,255,255,0.1)' }
                    },
                    boxShadow: { 'glow': '0 0 20px rgba(56,189,248,0.15)', 'btn': '0 4px 14px rgba(56,189,248,0.39)' }
                }
            }
        }
    </script>
    <style>
        body { font-family: 'Inter', sans-serif; background: linear-gradient(to bottom right, #0f172a, #1e293b); }
        .glass-card { background: rgba(30,41,59,0.65); backdrop-filter: blur(16px); border: 1px solid rgba(255,255,255,0.08); box-shadow: 0 4px 30px rgba(0,0,0,0.25); }
        .input-field { background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.1); color: white; transition: all 0.2s; }
        .input-field:focus { background: rgba(0,0,0,0.45); border-color: #38bdf8; box-shadow: 0 0 0 3px rgba(56,189,248,0.2); outline: none; }
        .progress-bar { height:6px; background:rgba(255,255,255,0.08); border-radius:3px; overflow:hidden; }
        .progress-fill { height:100%; transition:width 1.2s ease-out; background:linear-gradient(to right, #38bdf8, #0ea5e9); }
        .fade-in-up { animation:fadeInUp 0.6s ease-out forwards; }
        @keyframes fadeInUp { from{opacity:0;transform:translateY(20px);} to{opacity:1;transform:translateY(0);} }
        .spinner { border:3px solid rgba(255,255,255,0.1); border-left-color:#38bdf8; border-radius:50%; width:28px; height:28px; animation:spin 1s linear infinite; }
        @keyframes spin { to{transform:rotate(360deg);} }
        
        /* ==================== 高德地图样式 ==================== */
        #map {
            width: calc(100% + 2rem); 
            height: 400px; 
            margin: 1rem -1rem; 
            border-radius: 0; 
            border: 1px solid rgba(255,255,255,0.1);
            z-index: 1; 
            overflow: hidden;
            background: white;
        }

        .leaflet-container {
            background: white !important;
        }

        .leaflet-control-attribution {
            background: rgba(255, 255, 255, 0.8) !important;
            color: #555 !important;
            font-size: 10px;
            padding: 2px 4px !important;
            border: none !important;
        }
        
        /* 移除所有卡片的圆角，但保留输入框和按钮的 */
        .glass-card, #temp-diff-container, .expert-tip-item {
            border-radius: 0 !important;
        }

        /* 专家建议区域的醒目样式 */
        .expert-tip-item {
            border-left-width: 3px;
            padding-left: 12px;
            margin-bottom: 12px;
            background: rgba(255, 255, 255, 0.05);
        }
    </style>
</head>
<body class="min-h-screen text-white pb-12 relative overflow-x-hidden">
    <div class="fixed inset-0 pointer-events-none -z-10">
        <div class="absolute top-[-20%] left-[-20%] w-[600px] h-[600px] bg-cyan-600/10 rounded-full blur-3xl"></div>
        <div class="absolute bottom-[-10%] right: [-10%] w-[500px] h-[500px] bg-blue-600/10 rounded-full blur-3xl"></div>
    </div>
    <div class="container mx-auto px-4 pt-8 max-w-5xl">
        <header class="text-center mb-6 md:mb-10 fade-in-up" style="animation-delay:0.1s">
            <div class="inline-flex items-center gap-3 mb-2 md:mb-3">
                <div class="w-10 h-10 md:w-12 md:h-12 bg-gradient-to-br from-cyan-500 to-blue-600 rounded-2xl flex items-center justify-center shadow-lg shadow-cyan-500/40">
                    <i class="fas fa-fish text-white text-lg md:text-xl"></i>
                </div>
                <h1 class="text-2xl md:text-4xl font-bold tracking-tight">钓了么</h1>
            </div>
            <p class="text-slate-400 text-xs md:text-sm">实时气象 · 风况 · 水文 · 智能预测</p>
        </header>
        <main class="grid grid-cols-1 lg:grid-cols-12 gap-6">
            <!-- 左侧主要输入区域 -->
            <section class="lg:col-span-7 space-y-6">
                <!-- 基础设置 -->
                <div class="glass-card p-4 md:p-6 fade-in-up" style="animation-delay:0.2s">
                    <div class="flex items-center gap-3 mb-4 md:mb-5 text-cyan-400">
                        <i class="fas fa-location-dot text-lg"></i>
                        <h2 class="text-base font-semibold uppercase tracking-wider">基础设置</h2>
                    </div>
                    <div class="space-y-4 md:space-y-5">
                        <div class="relative">
                            <label for="location" class="block text-xs text-slate-400 mb-2">钓点位置</label>
                            <div class="flex gap-2 md:gap-3">
                                <div class="relative flex-1">
                                    <i class="fas fa-search absolute left-4 top-1/2 -translate-y-1/2 text-slate-500"></i>
                                    <input id="location" type="text" placeholder="输入城市名，点击搜索" class="input-field w-full pl-12 py-3 rounded-xl text-sm placeholder-slate-500 focus:placeholder-slate-400">
                                </div>
                                <!-- 搜索/确定按钮 -->
                                <button id="search-location-btn" class="w-10 h-10 md:w-12 md:h-12 rounded-xl bg-gradient-to-br from-cyan-600 to-blue-600 hover:from-cyan-500 hover:to-blue-500 border border-white/10 flex items-center justify-center transition-all" title="搜索地点">
                                    <i class="fas fa-search"></i>
                                </button>
                                <!-- GPS定位按钮 -->
                                <button id="get-location" class="w-10 h-10 md:w-12 md:h-12 rounded-xl bg-white/10 hover:bg-white/20 border border-white/10 flex items-center justify-center transition-all" title="使用GPS定位">
                                    <i class="fas fa-crosshairs text-lg"></i>
                                </button>
                            </div>
                        </div>
                        
                        <!-- 地图模块：高德地图，无圆角，200m 精准视窗 -->
                        <div id="map"></div>
                        <p class="text-xs text-slate-500 text-center mt-2"><i class="fas fa-satellite-dish"></i> 高德地图 · 200m 战术视图 · 点击任意位置更新</p>

                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label class="block text-xs text-slate-400 mb-2">水域类型</label>
                                <select id="fishing-type" class="input-field w-full px-4 py-3 rounded-xl text-sm appearance-none">
                                    <option value="freshwater">淡水钓</option>
                                    <option value="saltwater">海钓</option>
                                </select>
                            </div>
                            <div>
                                <label for="time" class="block text-xs text-slate-400 mb-2">出钓时间</label>
                                <input id="time" type="datetime-local" class="input-field w-full px-4 py-3 rounded-xl text-sm">
                            </div>
                        </div>
                    </div>
                </div>
                <!-- 实时环境参数 -->
                <div class="glass-card p-4 md:p-6 fade-in-up" style="animation-delay:0.3s">
                    <div class="flex items-center justify-between mb-4 md:mb-5">
                        <div class="flex items-center gap-3 text-cyan-400">
                            <i class="fas fa-sliders text-lg"></i>
                            <h2 class="text-base font-semibold uppercase tracking-wider">实时环境参数</h2>
                        </div>
                        <span class="text-xs text-slate-500">自动获取</span>
                    </div>
                    <div class="space-y-4">
                        <div class="input-field w-full px-4 py-3 rounded-xl text-sm text-cyan-300 flex flex-wrap items-center justify-between gap-3">
                            <div class="flex items-center gap-2"><i class="fas fa-cloud-sun"></i> <span id="weather-text">--</span></div>
                            <div class="flex items-center gap-2"><i class="fas fa-wind"></i> <span id="wind-level">-- 级</span></div>
                            <div class="flex items-center gap-2"><i class="fas fa-compass"></i> <span id="wind-direction">--</span></div>
                            <div class="flex items-center gap-2"><i class="fas fa-gauge-high"></i> <span id="pressure-value">--</span> hPa</div>
                            <div class="flex items-center gap-2"><i class="fas fa-temperature-low"></i> <span id="water-temp-value">--</span> °C</div>
                        </div>
                        <p class="text-xs text-slate-400 text-center">数据基于 <span id="location-display">历史定位</span> 的实时气象</p>
                    </div>
                </div>
                <!-- 温差分析提示 -->
                <div id="temp-diff-container" class="glass-card p-4 hidden fade-in-up">
                    <div class="flex items-center gap-3 text-amber-400">
                        <i class="fas fa-temperature-high text-lg"></i>
                        <h3 class="text-sm font-semibold">未来一周温差分析</h3>
                    </div>
                    <div id="temp-diff-content" class="text-xs text-slate-300 mt-2">
                        <!-- 内容由JS动态生成 -->
                    </div>
                </div>
                <!-- 主按钮 -->
                <button id="calculate-btn" class="w-full bg-gradient-to-r from-cyan-600 to-blue-600 hover:from-cyan-500 hover:to-blue-500 text-white font-semibold py-3 md:py-4 rounded-xl shadow-lg shadow-cyan-500/30 transition-all duration-300 transform active:scale-95">
                    <i class="fas fa-wand-magic-sparkles mr-2"></i> 开始智能预测
                </button>
                <!-- 加载动画 -->
                <div id="loading" class="hidden glass-card p-6 text-center">
                    <div class="spinner mx-auto mb-4"></div>
                    <p class="text-slate-300">正在获取实时气象与一周温差数据...</p>
                </div>
            </section>
            
            <!-- 右侧预测结果区域 -->
            <section class="lg:col-span-5 space-y-6 order-1 lg:order-2">
                <!-- 预测指数 -->
                <div class="glass-card p-4 md:p-6 relative overflow-hidden fade-in-up" style="animation-delay:0.4s">
                    <h3 class="text-slate-400 text-xs font-semibold uppercase tracking-wider mb-3 md:mb-4">预测指数</h3>
                    <div class="flex items-baseline gap-3 mb-4 md:mb-6">
                        <span id="score" class="text-6xl md:text-7xl font-black tracking-tighter text-white">--</span>
                        <span class="text-xl text-slate-500 font-medium">/100</span>
                    </div>
                    <div id="result-message" class="px-4 py-2 rounded-lg text-sm font-medium text-center bg-white/5 border border-white/10 mb-6 md:mb-8">
                        请输入数据开始预测
                    </div>
                    <div class="space-y-4 md:space-y-5">
                        <div class="factor"><div class="flex justify-between text-xs mb-1"><span class="text-slate-400">时间因素</span><span id="time-factor" class="font-mono font-bold">--</span></div><div class="progress-bar"><div id="time-progress" class="progress-fill w-0"></div></div></div>
                        <div class="factor"><div class="flex justify-between text-xs mb-1"><span class="text-slate-400">天气因素</span><span id="weather-factor" class="font-mono font-bold">--</span></div><div class="progress-bar"><div id="weather-progress" class="progress-fill w-0"></div></div></div>
                        <div class="factor"><div class="flex justify-between text-xs mb-1"><span class="text-slate-400">风况因素</span><span id="wind-factor" class="font-mono font-bold">--</span></div><div class="progress-bar"><div id="wind-progress" class="progress-fill w-0"></div></div></div>
                        <div class="factor"><div class="flex justify-between text-xs mb-1"><span class="text-slate-400">气压因素</span><span id="pressure-factor" class="font-mono font-bold">--</span></div><div class="progress-bar"><div id="pressure-progress" class="progress-fill w-0"></div></div></div>
                        <div class="factor"><div class="flex justify-between text-xs mb-1"><span class="text-slate-400">水温因素</span><span id="water-temp-factor" class="font-mono font-bold">--</span></div><div class="progress-bar"><div id="water-temp-progress" class="progress-fill w-0"></div></div></div>
                    </div>
                </div>
                <!-- 专家建议 -->
                <div class="glass-card p-4 md:p-6 border-l-4 border-l-yellow-500 fade-in-up" style="animation-delay:0.5s">
                    <div class="flex items-center gap-3 mb-3 md:mb-4">
                        <i class="fas fa-lightbulb text-yellow-400 text-xl md:text-2xl"></i>
                        <h3 class="text-yellow-400 font-semibold text-lg">专家建议</h3>
                    </div>
                    <div id="expert-tips" class="text-sm text-slate-200 space-y-3 md:space-y-4 mt-3">
                        <p>正在加载地图数据...</p>
                    </div>
                </div>
            </section>
        </main>
        <footer class="text-center mt-8 md:mt-12 text-slate-600 text-xs">
            © 2026 钓了么 | 仅供娱乐参考，实际钓鱼请结合当地水情与安全
        </footer>
    </div>
    <script>
        // ==================== 配置 ====================
        const AMAP_KEY = '4156f446d0e20e7e20b4c686a45ffa14';
        const AMAP_GEOCODE_BASE = 'https://restapi.amap.com/v3/geocode/geo';
        const AMAP_REVERSE_GEOCODE_BASE = 'https://restapi.amap.com/v3/geocode/regeo';
        const OPENMETEO_BASE = 'https://api.open-meteo.com/v1/forecast';
        
        // ==================== 工具函数 ====================
        const $ = id => document.getElementById(id);
        function debounce(fn, delay = 300) {
            let t; return (...a) => { clearTimeout(t); t = setTimeout(()=>fn(...a), delay); };
        }
        function getProgressColor(s) {
            return s>=80 ? 'bg-gradient-to-r from-emerald-500 to-teal-500' :
                   s>=60 ? 'bg-gradient-to-r from-amber-500 to-yellow-500' :
                   'bg-gradient-to-r from-rose-500 to-red-600';
        }
        function getMessage(s) {
            if(s>=85) return {t:"🎯 爆护预警！绝佳时机！", c:'text-emerald-400 bg-emerald-950/30 border-emerald-500/30'};
            if(s>=70) return {t:"🐟 鱼情不错，值得一战！", c:'text-cyan-400 bg-cyan-950/30 border-cyan-500/30'};
            if(s>=50) return {t:"⚖️ 条件一般，需耐心等待", c:'text-yellow-400 bg-yellow-950/30 border-yellow-500/30'};
            return {t:"😴 鱼口较差，建议换天", c:'text-rose-400 bg-rose-950/30 border-rose-500/30'};
        }
        
        // ==================== 统一错误处理 ====================
        function handleApiError(err, ctx='操作') {
            console.error(`API Error [${ctx}]:`, err);
            let msg = '发生未知错误，请稍后再试';
            if(err.message.includes('fetch')) msg = '网络连接失败，请检查网络';
            else if(err.message.includes('429')) msg = 'API调用频率过高，请稍等1分钟';
            else if(err.message.includes('位置未找到')) msg = '未能找到该位置，请检查拼写';
            else if(err.message.includes('天气数据')) msg = '天气数据暂不可用，使用默认值';
            const el = $('result-message');
            el.textContent = msg;
            el.className = `px-4 py-2 rounded-lg text-sm font-medium text-center border bg-rose-500/10 border-rose-500/30 text-rose-300 mb-8`;
        }
        
        // ==================== 数据映射 ====================
        function windSpeedToLevel(speed) {
            if(speed < 1) return {level:0, text:'无风'};
            if(speed < 6) return {level:1, text:'1级轻风'};
            if(speed < 11) return {level:2, text:'2级轻风'};
            if(speed < 16) return {level:3, text:'3级和风'};
            if(speed < 21) return {level:4, text:'4级和风'};
            if(speed < 28) return {level:5, text:'5级劲风'};
            if(speed < 34) return {level:6, text:'6级强风'};
            return {level:7, text:'≥7级大风'};
        }
        function windDirectionToText(deg) {
            const dirs = ['北','东北','东','东南','南','西南','西','西北'];
            return dirs[Math.round(deg / 45) % 8];
        }
        function mapWeatherCodeToScore(code) {
            if([0,1,2,3].includes(code)) return 90; // 晴~阴
            if([45,48].includes(code)) return 40; // 雾
            if([51,53,55,56,57,61,63,65,66,67].includes(code)) return code<=61?80:code<=65?60:30;
            if([71,73,75,77,85,86].includes(code)) return 50;
            if([80,81,82,95,96,99].includes(code)) return code<=82?70:20;
            return 50;
        }
        
        // ==================== 得分计算 ====================
        function calculateTimeScore(h) { return ((h>=4&&h<=8)||(h>=16&&h<=20))?95:(h>=9&&h<=15)?40:70; }
        function calculateWindScore(level) { return level<=2?90:level<=4?75:level<=5?50:level<=6?30:15; }
        function calculatePressureScore(p) { return p>=1015&&p<=1025?95:p>=1005?85:p>1025&&p<=1035?70:p>=995?60:p<995?30:40; }
        function calculateWaterTempScore(t) { return t>=18&&t<=25?95:t>=15?85:t>25&&t<=28?75:t>=10?60:(t<10||t>28)?20:40; }
        
        // ==================== 高德地图API ====================
        async function getCoords(name) {
            try {
                const url = `${AMAP_GEOCODE_BASE}?key=${AMAP_KEY}&address=${encodeURIComponent(name)}`;
                const res = await fetch(url);
                const data = await res.json();
                if(data.status !== '1' || !data.geocodes || data.geocodes.length === 0) {
                    throw new Error('位置未找到');
                }
                const location = data.geocodes[0].location.split(',');
                return {lat: parseFloat(location[1]), lon: parseFloat(location[0])};
            } catch(e){ 
                console.error('高德地理编码失败:', e);
                handleApiError(e,'位置'); 
                return null; 
            }
        }
        
        async function reverseGeocode(lat, lon) {
            try {
                const url = `${AMAP_REVERSE_GEOCODE_BASE}?key=${AMAP_KEY}&location=${lon},${lat}`;
                const res = await fetch(url);
                const data = await res.json();
                if(data.status === '1' && data.regeocode) {
                    return data.regeocode.formatted_address;
                }
                return `Lat: ${lat.toFixed(2)}, Lon: ${lon.toFixed(2)}`;
            } catch {
                return `Lat: ${lat.toFixed(2)}, Lon: ${lon.toFixed(2)}`;
            }
        }
        
        async function fetchWeather(lat, lon) {
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
        }
        
        // 获取一周温差数据
        async function fetchWeeklyTempDiff(lat, lon) {
            try {
                const url = `${OPENMETEO_BASE}?latitude=${lat}&longitude=${lon}&daily=temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=7`;
                const res = await fetch(url);
                if(!res.ok) throw new Error('一周数据API失败');
                const {daily} = await res.json();
                
                let maxSingleDayDiff = 0;
                let totalWeeklyDiff = 0;
                
                if (daily && daily.temperature_2m_max && daily.temperature_2m_min) {
                    const maxTemps = daily.temperature_2m_max;
                    const minTemps = daily.temperature_2m_min;
                    const days = maxTemps.length;
                    
                    for (let i = 0; i < days; i++) {
                        const diff = maxTemps[i] - minTemps[i];
                        if (diff > maxSingleDayDiff) maxSingleDayDiff = diff;
                        totalWeeklyDiff += diff;
                    }
                    return {
                        singleDayMax: Math.round(maxSingleDayDiff),
                        weeklyAvgDiff: Math.round(totalWeeklyDiff / days),
                        raw: { maxTemps, minTemps }
                    };
                }
                return { singleDayMax: 0, weeklyAvgDiff: 0 };
            } catch(e) {
                console.warn("一周温差数据获取失败:", e);
                return { singleDayMax: 0, weeklyAvgDiff: 0 };
            }
        }

        // ==================== 地图逻辑 ====================
        let map;
        let marker;
        let currentCoords = null;

        // 自定义发光图标 (改为荧光绿色)
        const myIcon = L.divIcon({
            className: 'custom-div-icon',
            html: `<div style="
                background-color: #00ff00; 
                width: 14px; 
                height: 14px; 
                border-radius: 50%; 
                box-shadow: 0 0 20px #00ff00, 0 0 10px #00ff00;
                border: 2px solid white;
            "></div>`,
            iconSize: [14, 14],
            iconAnchor: [7, 7]
        });

        function initMap() {
            // 优先加载历史位置，否则默认北京
            const savedLat = localStorage.getItem('lastLat');
            const savedLon = localStorage.getItem('lastLon');
            const startView = (savedLat && savedLon) ? [savedLat, savedLon] : [39.9042, 116.4074];
            
            const startZoom = (savedLat && savedLon) ? 13.5 : 5;

            map = L.map('map', {
                zoomSnap: 0.5,
                attributionControl: true
            }).setView(startView, startZoom);
            
            // 使用高德地图瓦片服务
            L.tileLayer('https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}', {
                attribution: '© 高德地图',
                maxZoom: 18,
            }).addTo(map);

            // 地图点击事件
            map.on('click', async function(e) {
                const { lat, lng } = e.latlng;
                updateMapMarker(lat, lng);
                await handleMapClick(lat, lng);
            });
        }

        function updateMapMarker(lat, lng) {
            if (marker) {
                marker.setLatLng([lat, lng]);
            } else {
                marker = L.marker([lat, lng], { icon: myIcon }).addTo(map);
            }
            
            map.setView([lat, lng], 16.5);
        }

        async function handleMapClick(lat, lng) {
            localStorage.setItem('lastLat', lat);
            localStorage.setItem('lastLon', lng);

            try {
                const address = await reverseGeocode(lat, lng);
                $('location').value = address;
                $('location-display').textContent = address;
            } catch (e) {
                $('location').value = `Lat: ${lat.toFixed(2)}, Lon: ${lng.toFixed(2)}`;
                $('location-display').textContent = "自定义坐标";
            }
            
            currentCoords = { lat, lon: lng };
            await syncEnvData();
        }

        // ==================== UI 更新 ====================
        function updateProgress(id, score) {
            const bar = $(`${id}-progress`), txt = $(`${id}-factor`);
            if(!bar||!txt) return;
            txt.textContent = score;
            requestAnimationFrame(() => {
                bar.style.width = score + '%';
                bar.className = `progress-fill ${getProgressColor(score)}`;
            });
        }
        function updateWindDisplay(speed, dir) {
            const {level, text} = windSpeedToLevel(speed);
            $('wind-level').textContent = `${level}级 (${text})`;
            $('wind-direction').textContent = windDirectionToText(dir);
        }
        function updateWeatherText(code) {
            const text = {
                0:'晴朗',1:'晴间多云',2:'多云',3:'阴天',
                45:'有雾',61:'小雨',63:'中雨',65:'大雨',
                95:'雷暴',71:'小雪'
            }[code] || '未知天气';
            $('weather-text').textContent = text;
        }
        
        // 更新温差分析UI
        function updateTempDiffUI(diffData) {
            const container = $('temp-diff-container');
            const content = $('temp-diff-content');
            
            if (diffData.singleDayMax > 0) {
                container.classList.remove('hidden');
                
                let diffText = '';
                let diffColor = 'text-slate-300';
                
                if (diffData.singleDayMax >= 12) {
                    diffColor = 'text-rose-400';
                    diffText = `<p><i class="fas fa-exclamation-triangle"></i> <strong>警告：</strong>未来一周温差较大（最大日温差 ${diffData.singleDayMax}°C）。鱼类可能因水温波动导致活性不稳定，建议选择温差较小的时段出钓。</p>`;
                } else if (diffData.singleDayMax >= 8) {
                    diffColor = 'text-amber-400';
                    diffText = `<p><i class="fas fa-exclamation-circle"></i> <strong>注意：</strong>未来一周有温差变化（最大日温差 ${diffData.singleDayMax}°C），出钓时请关注水温变化趋势。</p>`;
                } else {
                    diffColor = 'text-emerald-400';
                    diffText = `<p><i class="fas fa-check-circle"></i> <strong>稳定：</strong>未来一周温差适宜（最大日温差 ${diffData.singleDayMax}°C），水温稳定有利于鱼类活动。</p>`;
                }
                
                content.innerHTML = `<div class="${diffColor}">${diffText}</div>`;
            } else {
                container.classList.add('hidden');
            }
        }

        // ==================== 专家建议生成 ====================
        function generateExpertTips(weatherCode, windLevel, waterTemp, isSaltwater, tempDiffData) {
            const tips = [];
            const { singleDayMax } = tempDiffData || {};
            
            if (singleDayMax && singleDayMax >= 12) {
                tips.push(`<span class="text-rose-400 font-semibold"><i class="fas fa-temperature-high"></i> 高温差预警：</span> 水温骤降导致"温跃层"下压。鱼群已大范围撤离上层，**必须钓远、钓深**（建议3米以上），避免浅滩无效窝。</span>`);
            } else if (singleDayMax && singleDayMax >= 8) {
                tips.push(`<span class="text-amber-400 font-semibold"><i class="fas fa-temperature-half"></i> 温差提示：</span> 未来几天有明显温差，鱼类可能停口。建议在温度相对稳定的清晨或傍晚，寻找深浅交界处作钓。</span>`);
            } else {
                tips.push(`<span class="text-emerald-400 font-semibold"><i class="fas fa-snowflake"></i> 温差稳定：</span> 近期水温波动小，是出钓的好时机。鱼类活性较为持续，可灵活选择钓位。</span>`);
            }

            if(windLevel >= 5) {
                tips.push(`<span class="text-pink-400 font-semibold"><i class="fas fa-map-marker-alt"></i> 位置选择：</span> 风力强劲，鱼群避浪。建议寻找**背风湾**、**洄水湾**或障碍物后的静水区，这些区域溶氧高且避风。</span>`);
            } else if(weatherCode >= 61 && weatherCode <= 65) {
                tips.push(`<span class="text-pink-400 font-semibold"><i class="fas fa-map-marker-alt"></i> 位置选择：</span> 雨天溶氧增加，食物被冲入下游。重点关注**进水口**、**闸下**、**汇流处**及浅滩弯道。</span>`);
            } else if(waterTemp > 28) {
                tips.push(`<span class="text-pink-400 font-semibold"><i class="fas fa-map-marker-alt"></i> 位置选择：</span> 水温过高，鱼趋阴凉。建议作钓于**深潭**、**树荫下**或**水草茂盛**的阴凉处。</span>`);
            } else if(waterTemp < 12) {
                tips.push(`<span class="text-pink-400 font-semibold"><i class="fas fa-map-marker-alt"></i> 位置选择：</span> 水温偏低，鱼群集中在深水区。建议寻找**深坑**、**主河道**或**深水湾**。</span>`);
            } else {
                tips.push(`<span class="text-pink-400 font-semibold"><i class="fas fa-map-marker-alt"></i> 位置选择：</span> 气候平稳。建议选择**深浅交界处**、**水草区边缘**或**水下障碍物**（如倒树、乱石堆）旁。</span>`);
            }

            if(waterTemp < 12) {
                tips.push(`<span class="text-cyan-400 font-semibold"><i class="fas fa-water"></i> 水深建议：</span> 建议钓**2-4米**深水区，采用底钓，搜索鱼窝。</span>`);
            } else if(waterTemp > 28) {
                tips.push(`<span class="text-cyan-400 font-semibold"><i class="fas fa-water"></i> 水深建议：</span> 建议钓**0.5-1.5米**中上层或阴凉处，采用钓浮或行程钓法。</span>`);
            } else if(windLevel >= 5) {
                tips.push(`<span class="text-cyan-400 font-semibold"><i class="fas fa-water"></i> 水深建议：</span> 建议钓**1.5-3米**，长竿短线在背风处作钓。</span>`);
            } else {
                tips.push(`<span class="text-cyan-400 font-semibold"><i class="fas fa-water"></i> 水深建议：</span> 建议钓**1-2.5米**，采用底钓结合浮钓，灵活搜索。</span>`);
            }
            
            if(weatherCode >= 61 && weatherCode <= 65) { // 雨天
                tips.push(`<span class="text-yellow-400 font-semibold"><i class="fas fa-bacon"></i> 饵料选择：</span> 雨天水体浑浊，推荐腥香浓郁饵料：红虫、蚯蚓、商品饵加腥味雪花粉。</span>`);
            } else if(windLevel >= 4) {
                tips.push(`<span class="text-yellow-400 font-semibold"><i class="fas fa-bacon"></i> 饵料选择：</span> 有风时鱼警觉性高，推荐自然饵或腥味较轻的商品饵（如麝香、虾粉）。</span>`);
            } else if(waterTemp > 25) {
                tips.push(`<span class="text-yellow-400 font-semibold"><i class="fas fa-bacon"></i> 饵料选择：</span> 高温季节鱼口轻，建议清淡饵或活饵：玉米、蚯蚓、草鱼用青草。</span>`);
            } else {
                tips.push(`<span class="text-yellow-400 font-semibold"><i class="fas fa-bacon"></i> 饵料选择：</span> 常规天气推荐经典组合：商品饵料（如基础粉末）+麝香+虾粉，或红虫+蚯蚓。</span>`);
            }
            
            if(isSaltwater) {
                tips.push(`<span class="text-indigo-400 font-semibold"><i class="fas fa-anchor"></i> 海钓提示：</span> 海钓建议使用沙虫、虾、蟹饵，注意潮汐变化（本系统已结合气象条件进行分析）。</span>`);
            }
            return tips.length ? tips : ["<p>暂无特别建议，祝你爆护！</p>"];
        }
        
        // ==================== 主逻辑 ====================
        async function syncEnvData() {
            if(!currentCoords) return;
            try {
                const data = await fetchWeather(currentCoords.lat, currentCoords.lon);
                $('pressure-value').textContent = data.pressure;
                updateWeatherText(data.weatherCode);
                $('water-temp-value').textContent = data.waterTemp;
                updateWindDisplay(data.windSpeed, data.windDir);
            } catch {}
        }
        
        async function calculatePrediction() {
            const loading = $('loading'), btn = $('calculate-btn'), msgEl = $('result-message');
            loading.classList.remove('hidden'); btn.disabled = true;
            try {
                let lat, lon;
                const loc = $('location').value.trim();
                if(loc){
                    const coords = await getCoords(loc);
                    if(!coords) throw new Error('位置未找到');
                    currentCoords = coords; lat = coords.lat; lon = coords.lon;
                    $('location-display').textContent = loc;
                    updateMapMarker(lat, lon);
                    localStorage.setItem('lastLat', lat);
                    localStorage.setItem('lastLon', lon);
                } else if(currentCoords){
                    ({lat, lon} = currentCoords);
                    $('location-display').textContent = "自定义坐标";
                } else {
                    throw new Error('请先输入位置或使用定位');
                }
                
                const [weatherData, tempDiffData] = await Promise.all([
                    fetchWeather(lat, lon).catch(()=> ({pressure:1013, weatherCode:3, waterTemp:20, windSpeed:3, windDir:0})),
                    fetchWeeklyTempDiff(lat, lon)
                ]);

                $('pressure-value').textContent = weatherData.pressure;
                updateWeatherText(weatherData.weatherCode);
                $('water-temp-value').textContent = weatherData.waterTemp;
                const windInfo = windSpeedToLevel(weatherData.windSpeed);
                $('wind-level').textContent = `${windInfo.level}级 (${windInfo.text})`;
                $('wind-direction').textContent = windDirectionToText(weatherData.windDir);
                
                updateTempDiffUI(tempDiffData);

                const dt = new Date($('time').value);
                if(isNaN(dt.getTime())) throw new Error('请选择有效时间');
                const hour = dt.getHours();
                const p = weatherData.pressure;
                const wt = weatherData.waterTemp;
                const wind = windInfo.level;
                
                const baseScores = {
                    time: calculateTimeScore(hour),
                    weather: mapWeatherCodeToScore(weatherData.weatherCode),
                    wind: calculateWindScore(wind),
                    pressure: calculatePressureScore(p),
                    waterTemp: calculateWaterTempScore(wt)
                };
                
                let tempDiffPenalty = 0;
                if (tempDiffData.singleDayMax >= 15) tempDiffPenalty = 40;
                else if (tempDiffData.singleDayMax >= 12) tempDiffPenalty = 25;
                else if (tempDiffData.singleDayMax >= 10) tempDiffPenalty = 15;
                else if (tempDiffData.singleDayMax >= 8) tempDiffPenalty = 8;
                
                let total = Math.round(
                    baseScores.time * 0.3 + 
                    baseScores.weather * 0.2 + 
                    baseScores.wind * 0.15 + 
                    baseScores.pressure * 0.2 + 
                    baseScores.waterTemp * 0.15
                );
                
                total = Math.max(0, total - tempDiffPenalty);
                
                const msg = getMessage(total);
                $('score').textContent = total;
                msgEl.textContent = msg.t;
                msgEl.className = `px-4 py-2 rounded-lg text-sm font-medium text-center border ${msg.c} mb-8`;
                
                updateProgress('time', baseScores.time);
                updateProgress('weather', baseScores.weather);
                updateProgress('wind', baseScores.wind);
                updateProgress('pressure', baseScores.pressure);
                updateProgress('water-temp', baseScores.waterTemp);

                const tips = generateExpertTips(weatherData.weatherCode, wind, wt, $('fishing-type').value==='saltwater', tempDiffData);
                $('expert-tips').innerHTML = tips.map(t=>`<div class="expert-tip-item">${t}</div>`).join('');
            } catch(e){
                handleApiError(e, '预测');
            } finally {
                loading.classList.add('hidden');
                btn.disabled = false;
            }
        }
        
        // ==================== 事件绑定 ====================
        document.addEventListener('DOMContentLoaded', () => {
            const now = new Date();
            now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
            $('time').value = now.toISOString().slice(0,16);
            
            initMap();

            const savedLat = localStorage.getItem('lastLat');
            const savedLon = localStorage.getItem('lastLon');
            if(savedLat && savedLon) {
                currentCoords = { lat: parseFloat(savedLat), lon: parseFloat(savedLon) };
                updateMapMarker(currentCoords.lat, currentCoords.lon);
                $('location-display').textContent = "历史定位";
                syncEnvData();
                $('expert-tips').innerHTML = "<p>已恢复上次的钓点数据。</p>";
            }

            const executeLocationSearch = async () => {
                const v = $('location').value.trim();
                if(v.length < 2) return;
                
                const btn = $('search-location-btn');
                const originalIcon = '<i class="fas fa-search"></i>';
                btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
                
                const coords = await getCoords(v);
                if(coords){
                    currentCoords = coords;
                    localStorage.setItem('lastLat', coords.lat);
                    localStorage.setItem('lastLon', coords.lon);
                    
                    $('location-display').textContent = v;
                    updateMapMarker(coords.lat, coords.lon);
                    await syncEnvData();
                }
                btn.innerHTML = originalIcon;
            };

            const handleLocChange = debounce(executeLocationSearch, 900);
            
            $('location').addEventListener('blur', handleLocChange);
            $('location').addEventListener('change', handleLocChange);
            
            $('location').addEventListener('keypress', (e) => {
                if (e.key === 'Enter') {
                    e.preventDefault(); 
                    executeLocationSearch();
                }
            });

            $('search-location-btn').addEventListener('click', executeLocationSearch);
            
            $('get-location').addEventListener('click', async()=>{
                const btn = $('get-location');
                btn.disabled=true; btn.innerHTML='<i class="fas fa-spinner fa-spin"></i>';
                try{
                    const pos = await new Promise((r,j)=>navigator.geolocation.getCurrentPosition(r,j,{timeout:8000}));
                    currentCoords = {lat:pos.coords.latitude, lon:pos.coords.longitude};
                    $('location').value = await reverseGeocode(currentCoords.lat, currentCoords.lon);
                    $('location-display').textContent = "GPS定位";
                    updateMapMarker(currentCoords.lat, currentCoords.lon);
                    localStorage.setItem('lastLat', currentCoords.lat);
                    localStorage.setItem('lastLon', currentCoords.lon);
                    await syncEnvData();
                }catch(e){handleApiError(e,'定位');}
                finally{btn.disabled=false; btn.innerHTML='<i class="fas fa-crosshairs"></i>';}
            });
            
            $('calculate-btn').addEventListener('click', calculatePrediction);
        });
    </script>
</body>
</html>
