import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../utils/water_calculator.dart';
import 'settings_screen.dart';
import 'schedule_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fillController;
  late Animation<double> _fillAnim;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _fillController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fillAnim =
        CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic);
    _fillController.forward();
  }

  @override
  void dispose() {
    _fillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
              title: Row(children: [
                Icon(Icons.water_drop_rounded, color: s.primary, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text('Hello, ${p.profile.name} 👋',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 17)),
                ),
              ]),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF0A1628), const Color(0xFF112240)]
                        : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: s.primary),
                onPressed: p.toggleTheme,
              ),
              IconButton(
                icon: Icon(Icons.settings_rounded, color: s.primary),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _progressCard(p, s),
                const SizedBox(height: 16),
                _quickLogCard(p, s),
                const SizedBox(height: 16),
                _statsRow(p, s),
                const SizedBox(height: 16),
                _tabBar(s),
                const SizedBox(height: 12),
                if (_selectedTab == 0)
                  _weeklyChart(p, s)
                else
                  _todayLog(p),
                const SizedBox(height: 16),
                _scheduleCard(p, s),
                const SizedBox(height: 90),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogDialog(context, p),
        icon: const Icon(Icons.add),
        label: const Text('Log Water'),
        backgroundColor: s.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _progressCard(AppProvider p, ColorScheme s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Today's Progress",
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                        '${p.profile.weather.emoji} ${p.profile.weather.displayName}',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ]),
            ),
            AnimatedBuilder(
              animation: _fillAnim,
              builder: (_, __) => SizedBox(
                width: 80,
                height: 80,
                child: Stack(alignment: Alignment.center, children: [
                  CircularProgressIndicator(
                    value: (p.progress * _fillAnim.value).clamp(0.0, 1.0),
                    strokeWidth: 8,
                    backgroundColor: s.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(s.primary),
                    strokeCap: StrokeCap.round,
                  ),
                  Text(
                    '${(p.progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: s.primary),
                  ),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _fillAnim,
            builder: (_, __) => SizedBox(
              height: 140,
              child: CustomPaint(
                painter: WaterBottlePainter(
                  fillLevel: (p.progress * _fillAnim.value).clamp(0.0, 1.0),
                  fillColor: s.primary,
                  bgColor: s.surfaceVariant,
                ),
                size: const Size(double.infinity, 140),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: _chip('💧 Drunk',
                    WaterCalculator.formatMl(p.consumedTodayMl.toDouble()),
                    const Color(0xFF2196F3))),
            const SizedBox(width: 10),
            Expanded(
                child: _chip('🎯 Left',
                    WaterCalculator.formatMl(p.remainingMl),
                    const Color(0xFFFF7043))),
            const SizedBox(width: 10),
            Expanded(
                child: _chip('📊 Goal',
                    WaterCalculator.formatMl(p.dailyGoalMl),
                    const Color(0xFF4CAF50))),
          ]),
        ]),
      ),
    );
  }

  Widget _chip(String lbl, String val, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
          color: c.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(lbl,
            style: TextStyle(fontSize: 10, color: c),
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(val,
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: c),
            textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _quickLogCard(AppProvider p, ColorScheme s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quick Log', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [150, 200, 250, 300, 500].map((ml) {
                  return GestureDetector(
                    onTap: () {
                      p.logWater(ml);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('✅ $ml ml logged!'),
                        backgroundColor: const Color(0xFF4CAF50),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [s.primary.withOpacity(0.85), s.primary]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: s.primary.withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Column(children: [
                        const Icon(Icons.water_drop_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(height: 4),
                        Text('$ml',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        const Text('ml',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 10)),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ]),
      ),
    );
  }

  Widget _statsRow(AppProvider p, ColorScheme s) {
    final logs = p.todayLogs;
    final avg =
        logs.isEmpty ? 0 : (p.consumedTodayMl / logs.length).round();
    final next = DateTime.now()
        .add(Duration(minutes: p.profile.reminderIntervalMinutes));
    final h = next.hour > 12 ? next.hour - 12 : (next.hour == 0 ? 12 : next.hour);
    final m = next.minute.toString().padLeft(2, '0');
    final ap = next.hour >= 12 ? 'PM' : 'AM';
    return Row(children: [
      Expanded(child: _mini('🥤 Drinks', '${logs.length}', s.primary)),
      const SizedBox(width: 10),
      Expanded(child: _mini('📏 Avg', '$avg ml', const Color(0xFF9C27B0))),
      const SizedBox(width: 10),
      Expanded(
          child: _mini('⏰ Next', '$h:$m $ap', const Color(0xFFFF7043))),
    ]);
  }

  Widget _mini(String lbl, String val, Color c) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Text(lbl,
              style: TextStyle(fontSize: 11, color: c),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(val,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: c)),
        ]),
      ),
    );
  }

  Widget _tabBar(ColorScheme s) {
    return Row(children: [
      Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedTab = 0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _selectedTab == 0 ? s.primary : s.surfaceVariant,
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            child: Text('📊 Weekly',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _selectedTab == 0 ? Colors.white : null,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ),
      Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedTab = 1),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _selectedTab == 1 ? s.primary : s.surfaceVariant,
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(12)),
            ),
            child: Text("📋 Log",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _selectedTab == 1 ? Colors.white : null,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    ]);
  }

  Widget _weeklyChart(AppProvider p, ColorScheme s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('7-Day History',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              FutureBuilder<Map<String, int>>(
                future: p.getWeekHistory(),
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return const SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator()));
                  }
                  final entries = snap.data!.entries.toList();
                  final maxY = math.max(
                    p.dailyGoalMl,
                    entries
                        .fold(0.0,
                            (prev, e) => math.max(prev, e.value.toDouble())),
                  );
                  return SizedBox(
                    height: 200,
                    child: BarChart(BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY * 1.2,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: s.surface,
                          getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
                            WaterCalculator.formatMl(rod.toY),
                            TextStyle(
                                color: s.primary,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, _) {
                              final idx = val.toInt();
                              if (idx < 0 || idx >= entries.length) {
                                return const SizedBox();
                              }
                              return Text(entries[idx].key,
                                  style: const TextStyle(fontSize: 11));
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                            color: s.outline.withOpacity(0.2),
                            strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: entries.asMap().entries.map((e) {
                        final frac = e.value.value / p.dailyGoalMl;
                        final color = frac >= 1.0
                            ? const Color(0xFF4CAF50)
                            : frac >= 0.75
                                ? s.primary
                                : frac >= 0.5
                                    ? const Color(0xFFFF9800)
                                    : const Color(0xFFFF5252);
                        return BarChartGroupData(x: e.key, barRods: [
                          BarChartRodData(
                            toY: e.value.value.toDouble(),
                            color: color,
                            width: 22,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: p.dailyGoalMl,
                              color: s.surfaceVariant,
                            ),
                          ),
                        ]);
                      }).toList(),
                    )),
                  );
                },
              ),
            ]),
      ),
    );
  }

  Widget _todayLog(AppProvider p) {
    final logs = p.todayLogs.reversed.toList();
    if (logs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(children: [
              const Icon(Icons.water_drop_outlined,
                  size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text('No water logged today yet.',
                  style: Theme.of(context).textTheme.bodyMedium),
            ]),
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Today's Log",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...logs.take(15).map((log) {
                final h = log.time.hour > 12
                    ? log.time.hour - 12
                    : (log.time.hour == 0 ? 12 : log.time.hour);
                final m = log.time.minute.toString().padLeft(2, '0');
                final ap = log.time.hour >= 12 ? 'PM' : 'AM';
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    radius: 15,
                    backgroundColor: Color(0xFF2196F3),
                    child: Icon(Icons.water_drop_rounded,
                        size: 14, color: Colors.white),
                  ),
                  title: Text('${log.amountMl} ml',
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Text('$h:$m $ap',
                      style: Theme.of(context).textTheme.bodyMedium),
                );
              }),
            ]),
      ),
    );
  }

  Widget _scheduleCard(AppProvider p, ColorScheme s) {
    final slots = p.schedule;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.schedule_rounded, color: s.primary),
                const SizedBox(width: 8),
                Text('Ideal Daily Schedule',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ScheduleScreen())),
                  child: const Text('View All'),
                ),
              ]),
              ...slots.take(5).map((sl) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(children: [
                      Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: s.primary)),
                      const SizedBox(width: 12),
                      Text(sl.timeLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      const Spacer(),
                      Text('${sl.amountMl} ml',
                          style: TextStyle(color: s.primary)),
                    ]),
                  )),
              if (slots.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                      '... and ${slots.length - 5} more reminders',
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
            ]),
      ),
    );
  }

  void _showLogDialog(BuildContext context, AppProvider p) {
    int amount = 250;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.water_drop_rounded, color: Color(0xFF2196F3)),
            SizedBox(width: 8),
            Text('Log Water Intake'),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$amount ml',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary)),
            Slider(
              value: amount.toDouble(),
              min: 50,
              max: 1000,
              divisions: 19,
              label: '$amount ml',
              onChanged: (v) => setS(() => amount = v.round()),
            ),
            Wrap(
              spacing: 8,
              children: [100, 150, 200, 250, 300, 500].map((ml) {
                return ActionChip(
                  label: Text('$ml ml'),
                  onPressed: () => setS(() => amount = ml),
                  backgroundColor: amount == ml
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  labelStyle:
                      TextStyle(color: amount == ml ? Colors.white : null),
                );
              }).toList(),
            ),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                p.logWater(amount);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('✅ Logged $amount ml'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ));
              },
              child: const Text('Log It!'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Water Bottle Painter ───
class WaterBottlePainter extends CustomPainter {
  final double fillLevel;
  final Color fillColor;
  final Color bgColor;

  WaterBottlePainter({
    required this.fillLevel,
    required this.fillColor,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bw = math.min(size.width * 0.38, 148.0);
    final bh = size.height * 0.86;
    final cx = size.width / 2;
    final top = (size.height - bh) / 2;
    final nw = bw * 0.34;
    final nh = bh * 0.15;
    final bodyTop = top + nh;
    final bodyH = bh - nh;
    final btm = bodyTop + bodyH;

    Path bottlePath() {
      return Path()
        ..moveTo(cx - nw / 2, top)
        ..lineTo(cx + nw / 2, top)
        ..lineTo(cx + bw / 2, bodyTop)
        ..lineTo(cx + bw / 2, btm)
        ..quadraticBezierTo(cx + bw / 2, btm + 8, cx + bw / 2 - 8, btm + 8)
        ..lineTo(cx - bw / 2 + 8, btm + 8)
        ..quadraticBezierTo(cx - bw / 2, btm + 8, cx - bw / 2, btm)
        ..lineTo(cx - bw / 2, bodyTop)
        ..close();
    }

    final bottle = bottlePath();
    canvas.drawPath(bottle, Paint()..color = bgColor);

    if (fillLevel > 0.005) {
      final fillY = bodyTop + bodyH * (1 - fillLevel);
      final fp = Path()
        ..moveTo(cx - bw / 2, fillY)
        ..lineTo(cx + bw / 2, fillY)
        ..lineTo(cx + bw / 2, btm)
        ..quadraticBezierTo(cx + bw / 2, btm + 8, cx + bw / 2 - 8, btm + 8)
        ..lineTo(cx - bw / 2 + 8, btm + 8)
        ..quadraticBezierTo(cx - bw / 2, btm + 8, cx - bw / 2, btm)
        ..close();

      canvas.save();
      canvas.clipPath(bottle);
      canvas.drawPath(
        fp,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [fillColor.withOpacity(0.6), fillColor],
          ).createShader(Rect.fromLTWH(
              cx - bw / 2, fillY, bw, btm + 8 - fillY)),
      );
      canvas.restore();

      // % text
      final tp = TextPainter(
        text: TextSpan(
            text: '${(fillLevel * 100).round()}%',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas,
          Offset(cx - tp.width / 2,
              fillY + (btm - fillY) / 2 - tp.height / 2));
    }

    canvas.drawPath(
        bottle,
        Paint()
          ..color = fillColor.withOpacity(0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(WaterBottlePainter old) =>
      old.fillLevel != fillLevel || old.fillColor != fillColor;
}
