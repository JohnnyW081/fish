#!/usr/bin/env python3
"""Add i18n keys and update JS to use t() instead of hardcoded Chinese."""
with open('D:/Agent/fish/index.html', 'r', encoding='utf-8') as f:
    c = f.read()

# ===== 1. Add i18n keys to ALL 4 languages BEFORE each map_attribution =====
# This ensures each language gets its own translated keys

zh_keys = """\n                tip_label_position: '钓位：',
                tip_label_bait: '饵料：',
                tip_label_method: '钓法：',
                tip_label_bottom: '底',
                tip_label_depth: '水深',
                tip_label_meter: '米',
                tip_label_hook: '钩 + ',
                tip_label_tackle: '线组建议：',
                tip_label_pressure: '气压趋势：',
                tip_label_moon_fallback: '月相正常，按常规出钓',
                moon_0: '🌑 新月', moon_1: '🌒 蛾眉月', moon_2: '🌓 上弦月', moon_3: '🌔 盈凸月',
                moon_4: '🌕 满月', moon_5: '🌖 亏凸月', moon_6: '🌗 下弦月', moon_7: '🌘 残月',
                moon_tip_0: '新月光线暗，大鱼警惕性低，白天可钓深水区',
                moon_tip_2: '上弦月，傍晚至午夜为最佳窗口期',
                moon_tip_4: '满月前后，夜间光线充足，夜钓效果极佳',
                moon_tip_6: '下弦月，清晨窗口好',
                pressure_stable: '气压平稳（变化<1.5hPa），鱼类活动正常',
                pressure_rising: '气压上升中（+{diff}hPa），溶氧增加，鱼群活跃度高',
                pressure_falling: '气压下降中（{diff}hPa），鱼群活性降低，建议等气压稳定再出钓',
                season_spring: '春季', season_summer: '夏季', season_autumn: '秋季', season_winter: '冬季',
                season_tip_spring: '鱼类进入产卵期，浅滩水温回升快，建议近岸浅水区作钓',
                season_tip_summer: '高温季节，鱼类趋深趋阴，建议早晚出钓避开正午暴晒',
                season_tip_autumn: '秋季育肥期，鱼类摄食活跃，全天均可出钓',
                season_tip_winter: '水温低，鱼群集中深水区越冬，建议午间出钓，钓深3米以上',
                // 中文"""
en_keys = """\n                tip_label_position: ' Position:',
                tip_label_bait: ' Bait:',
                tip_label_method: ' Method:',
                tip_label_bottom: 'bottom',
                tip_label_depth: 'Depth ',
                tip_label_meter: 'm',
                tip_label_hook: ' hook + ',
                tip_label_tackle: 'Tackle:',
                tip_label_pressure: 'Pressure:',
                tip_label_moon_fallback: 'Normal moon phase, fish as usual',
                moon_0: '🌑 New Moon', moon_1: '🌒 Waxing Crescent', moon_2: '🌓 First Quarter', moon_3: '🌔 Waxing Gibbous',
                moon_4: '🌕 Full Moon', moon_5: '🌖 Waning Gibbous', moon_6: '🌗 Last Quarter', moon_7: '🌘 Waning Crescent',
                moon_tip_0: 'Dark moon, big fish less cautious, fish deep water during day',
                moon_tip_2: 'First quarter, dusk to midnight is the best window',
                moon_tip_4: 'Full moon, bright nights, excellent for night fishing',
                moon_tip_6: 'Last quarter, early morning window is best',
                pressure_stable: 'Stable pressure (<1.5hPa change), normal fish activity',
                pressure_rising: 'Pressure rising (+{diff}hPa), higher oxygen, active fish',
                pressure_falling: 'Pressure falling ({diff}hPa), fish less active, wait for stable pressure',
                season_spring: 'Spring', season_summer: 'Summer', season_autumn: 'Autumn', season_winter: 'Winter',
                season_tip_spring: 'Spawning season, shallow waters warm up fast, fish nearshore shallows',
                season_tip_summer: 'Hot season, fish go deep/shady, fish dawn/dusk avoid midday sun',
                season_tip_autumn: 'Fall fattening season, fish feed actively, fish all day',
                season_tip_winter: 'Cold water, fish cluster in deep areas, fish midday at 3m+',
                // English"""
ja_keys = """\n                tip_label_position: ' 釣位：',
                tip_label_bait: ' エサ：',
                tip_label_method: ' 釣法：',
                tip_label_bottom: '底',
                tip_label_depth: '水深',
                tip_label_meter: 'm',
                tip_label_hook: ' 針 + ',
                tip_label_tackle: 'タックル：',
                tip_label_pressure: '気圧傾向：',
                tip_label_moon_fallback: '月相正常、通常通り釣り',
                moon_0: '🌑 新月', moon_1: '🌒 三日月', moon_2: '🌓 上弦の月', moon_3: '🌔 盈凸月',
                moon_4: '🌕 満月', moon_5: '🌖 亏凸月', moon_6: '🌗 下弦の月', moon_7: '🌘 残月',
                moon_tip_0: '新月、大型魚の警戒心低下、日中は深場を狙え',
                moon_tip_2: '上弦月、夕方から真夜中がベスト',
                moon_tip_4: '満月前後、夜光十分、夜釣りに最適',
                moon_tip_6: '下弦月、早朝が狙い目',
                pressure_stable: '気圧安定（変化<1.5hPa）、魚の活動正常',
                pressure_rising: '気圧上昇中（+{diff}hPa）、溶存酸素増加、魚活性高',
                pressure_falling: '気圧下降中（{diff}hPa）、魚活性低下、安定後に出船',
                season_spring: '春', season_summer: '夏', season_autumn: '秋', season_winter: '冬',
                season_tip_spring: '産卵期、浅場の水温上昇、近岸浅場を狙え',
                season_tip_summer: '高温期、魚は深場・陰へ、朝夕出船推奨',
                season_tip_autumn: '秋季、魚の摂食活発、終日釣り可能',
                season_tip_winter: '低水温、魚は深場に集中、昼間出船、3m以上',
                // 日本語"""
ko_keys = """\n                tip_label_position: ' 포인트：',
                tip_label_bait: ' 미끼：',
                tip_label_method: ' 낚시법：',
                tip_label_bottom: '바닥',
                tip_label_depth: '수심 ',
                tip_label_meter: 'm',
                tip_label_hook: ' 바늘 + ',
                tip_label_tackle: '채비 추천：',
                tip_label_pressure: '기압 경향：',
                tip_label_moon_fallback: '월상 정상, 평소대로 출조',
                moon_0: '🌑 신월', moon_1: '🌒 초승달', moon_2: '🌓 상현달', moon_3: '🌔 팔월',
                moon_4: '🌕 보름달', moon_5: '🌖 노목', moon_6: '🌗 하현달', moon_7: '🌘 그믐달',
                moon_tip_0: '신월, 대어 경계심 낮음, 주간 심층 낚시 추천',
                moon_tip_2: '상현달, 황혼~자정 최적 시간',
                moon_tip_4: '보름달 전후, 야간 광량 충분, 야간 낚시 최적',
                moon_tip_6: '하현달, 이른 아침 추천',
                pressure_stable: '기압 안정(<1.5hPa 변화), 어류 활동 정상',
                pressure_rising: '기압 상승중(+{diff}hPa), 용존산소 증가, 어군 활발',
                pressure_falling: '기압 하강중({diff}hPa), 어군 활동 저하, 안정 후 출조',
                season_spring: '봄', season_summer: '여름', season_autumn: '가을', season_winter: '겨울',
                season_tip_spring: '산란기, 얕은 곳 수온 상승, 근해 얕은 곳 추천',
                season_tip_summer: '고온기, 어류 심층/그늘 선호, 아침저녁 출조 추천',
                season_tip_autumn: '가을 비육기, 어류 섭식 활발, 종일 낚시 가능',
                season_tip_winter: '저수온, 어군 심층 집중, 오후 출조, 3m 이상',
                // 한국어"""

# Insert keys before each map_attribution line
c = c.replace("                map_attribution: '© 高德地图',", zh_keys + "\n                map_attribution: '© 高德地图',", 1)
c = c.replace("                map_attribution: '© AutoNavi',\n            },\n            ja:", en_keys + "\n                map_attribution: '© AutoNavi',\n            },\n            ja:", 1)

# For ja - there are now 3 AutoNavi lines (zh, en, ja unchanged so far)
# Find ja's map_attribution. After the previous replaces, the third one is ja's.
lines = c.split('\n')
ja_auto_idx = None
for i, line in enumerate(lines):
    if "map_attribution: '© AutoNavi'" in line:
        if ja_auto_idx is None:
            ja_auto_idx = i  # skip first two (zh was changed to © 高德地图, en was already replaced)
        elif ja_auto_idx == i:
            pass  # skip second (en's)
        else:
            ja_auto_idx = i
            break

if ja_auto_idx:
    # Insert ja keys before this line
    indent = '                '
    ja_lines = ja_keys.split('\n')
    for j, kl in enumerate(ja_lines):
        lines.insert(ja_auto_idx + j, kl)
    c = '\n'.join(lines)
    print(f'  Added ja keys at line {ja_auto_idx} ✅')

# For ko - find the last remaining map_attribution for '© AutoNavi'
idx = c.rfind("                map_attribution: '© AutoNavi',")
if idx > 0:
    c = c[:idx] + ko_keys + "\n" + c[idx:]
    print(f'  Added ko keys ✅')

# Now check total marker count
print(f'  Total map_attribution lines: {c.count("map_attribution")}')

# ===== 2. Update JS functions to use t() =====

# 2a. SEASON_NAMES
c = c.replace(
    "const SEASON_NAMES = {spring:'春季',summer:'夏季',autumn:'秋季',winter:'冬季'};",
    "const SEASON_NAMES = {spring:t('season_spring'),summer:t('season_summer'),autumn:t('season_autumn'),winter:t('season_winter')};")

# 2b. SEASON_TIPS
c = c.replace("""        const SEASON_TIPS = {
            spring:'鱼类进入产卵期，浅滩水温回升快，建议近岸浅水区作钓',
            summer:'高温季节，鱼类趋深趋阴，建议早晚出钓避开正午暴晒',
            autumn:'秋季育肥期，鱼类摄食活跃，全天均可出钓',
            winter:'水温低，鱼群集中深水区越冬，建议午间出钓，钓深3米以上'
        };""",
"""        const SEASON_TIPS = {
            spring:t('season_tip_spring'),
            summer:t('season_tip_summer'),
            autumn:t('season_tip_autumn'),
            winter:t('season_tip_winter')
        };""")

# 2c. Moon phase names array
c = c.replace(
    "const names = ['🌑 新月','🌒 蛾眉月','🌓 上弦月','🌔 盈凸月','🌕 满月','🌖 亏凸月','🌗 下弦月','🌘 残月'];",
    "const names = [t('moon_0'),t('moon_1'),t('moon_2'),t('moon_3'),t('moon_4'),t('moon_5'),t('moon_6'),t('moon_7')];")

# 2d. Moon phase tips dict
c = c.replace("""            const tips = {
                0:'新月光线暗，大鱼警惕性低，白天可钓深水区',
                2:'上弦月，傍晚至午夜为最佳窗口期',
                4:'满月前后，夜间光线充足，夜钓效果极佳',
                6:'下弦月，清晨窗口好'
            };""",
"""            const tips = {};
            tips[0]=t('moon_tip_0'); tips[2]=t('moon_tip_2'); tips[4]=t('moon_tip_4'); tips[6]=t('moon_tip_6');""")

# 2e. Moon phase fallback in return
c = c.replace(
    "tip:tips[idx]||'月相正常，按常规出钓'",
    "tip:tips[idx]||t('tip_label_moon_fallback')")

# 2f. Pressure trend texts
c = c.replace(
    "text:'气压平稳（变化<1.5hPa），鱼类活动正常'",
    "text:t('pressure_stable')")
c = c.replace(
    "text:`气压上升中（+${diff.toFixed(1)}hPa），溶氧增加，鱼群活跃度高`",
    "text:t('pressure_rising',{diff:diff.toFixed(1)})")
c = c.replace(
    "text:`气压下降中（${diff.toFixed(1)}hPa），鱼群活性降低，建议等气压稳定再出钓`",
    "text:t('pressure_falling',{diff:diff.toFixed(1)})")

# 2g. Species-specific tip labels in generateExpertTips
c = c.replace(
    "fishSpecies.name + '钓位：'",
    "fishSpecies.name + t('tip_label_position')")
c = c.replace(
    "fishSpecies.name + '饵料：'",
    "fishSpecies.name + t('tip_label_bait')")
c = c.replace(
    "fishSpecies.name + '钓法：'",
    "fishSpecies.name + t('tip_label_method')")
c = c.replace(
    "（钓' + (fishSpecies.depth || '底') + '，水深'",
    "（' + t('tip_label_fishing') + (fishSpecies.depth || t('tip_label_bottom')) + '，" + t('tip_label_depth')")
# The above is tricky because there's also '底' hardcoded. Let me handle it differently.
# Actually let me just replace the whole method line
c = c.replace(
    "tips.push('<span class=\"text-cyan-400 font-semibold\"><i class=\"fas fa-water\"></i> ' + fishSpecies.name + t('tip_label_method') + '</span>（' + t('tip_label_fishing') + (fishSpecies.depth || '底') + '，" + t('tip_label_depth') + fishSpecies.depthRange[0] + '-' + fishSpecies.depthRange[1] + '米');",
    "tips.push('<span class=\"text-cyan-400 font-semibold\"><i class=\"fas fa-water\"></i> ' + fishSpecies.name + t('tip_label_method') + '</span>' + t('tip_label_fishing') + (fishSpecies.depth || t('tip_label_bottom')) + '，" + t('tip_label_depth') + fishSpecies.depthRange[0] + '-' + fishSpecies.depthRange[1] + t('tip_label_meter') + ');")

# Actually the above is too fragile. Let me check what's actually in the file.
import re
# Find the method line
method_match = re.search(r"tips\.push\('<span class=\"text-cyan-400[^']*' \+ fishSpecies\.name \+ t\('tip_label_method'\)[^;]+;", c)
if method_match:
    print(f'  Method line found: {method_match.group()[:80]}...')

# 2h. Tackle label - already using t('tip_label_tackle') via a separate push

# Let me check the actual generateExpertTips function for the current line
idx = c.find("tips.push('<span class=\"text-cyan-400")
if idx >= 0:
    end = c.find(';', idx)
    line = c[idx:end+1]
    print(f'  Method line: {line[:120]}...')

    # Fix the 米 at the end
    if '米' in line and "t('tip_label_meter')" not in line:
        c = c.replace(
            " + fishSpecies.depthRange[1] + '米');",
            " + fishSpecies.depthRange[1] + t('tip_label_meter'));")

# 2h. Tackle line
c = c.replace(
    "fishSpecies.hook + '钩 + '",
    "fishSpecies.hook + t('tip_label_hook')")

# 2i. Pressure trend label
c = c.replace(
    "pressureTrend.arrow + ' 气压趋势：</span> '",
    "pressureTrend.arrow + ' ' + t('tip_label_pressure') + '</span> '")

# 2j. Moon phase fallback in tips.push
c = c.replace(
    "moonPhase.tip || '月相正常，按常规出钓'",
    "moonPhase.tip || t('tip_label_moon_fallback')")

# ===== Save =====
with open('D:/Agent/fish/index.html', 'w', encoding='utf-8') as f:
    f.write(c)
print(f'\n✅ File saved ({len(c)} bytes)')
