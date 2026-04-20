import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = Theme.of(context).colorScheme;
    final schedule = p.schedule;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Ideal Daily Schedule')),
      body: Column(
        children: [
          // Summary header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                s.primary.withOpacity(0.2),
                s.secondary.withOpacity(0.2),
              ]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _sumItem(context, '${schedule.length}', 'Reminders', s.primary),
                _sumItem(
                    context,
                    schedule.isEmpty
                        ? '0'
                        : '${schedule.first.amountMl}ml',
                    'Per Drink',
                    s.secondary),
                _sumItem(
                    context,
                    '${p.profile.wakeUpHour}–${p.profile.sleepHour}h',
                    'Active Hours',
                    const Color(0xFF4CAF50)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: schedule.length,
              itemBuilder: (ctx, i) {
                final slot = schedule[i];
                final slotTime = DateTime(
                    now.year, now.month, now.day, slot.hour, slot.minute);
                final isPast = slotTime.isBefore(now);
                final isCurrent = i < schedule.length - 1
                    ? slotTime.isBefore(now) &&
                        DateTime(now.year, now.month, now.day,
                                schedule[i + 1].hour, schedule[i + 1].minute)
                            .isAfter(now)
                    : false;

                return Row(children: [
                  // Timeline
                  Column(children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent
                            ? s.primary
                            : isPast
                                ? const Color(0xFF4CAF50)
                                : s.surfaceVariant,
                        border: isCurrent
                            ? Border.all(
                                color: s.primary.withOpacity(0.4), width: 3)
                            : null,
                      ),
                      child: Icon(
                        isPast || isCurrent
                            ? Icons.water_drop_rounded
                            : Icons.water_drop_outlined,
                        size: 18,
                        color: isPast || isCurrent ? Colors.white : Colors.grey,
                      ),
                    ),
                    if (i < schedule.length - 1)
                      Container(
                          width: 2,
                          height: 40,
                          color: isPast
                              ? const Color(0xFF4CAF50).withOpacity(0.4)
                              : s.surfaceVariant),
                  ]),
                  const SizedBox(width: 16),
                  // Card
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? s.primary.withOpacity(0.12)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: isCurrent
                            ? Border.all(color: s.primary, width: 1.5)
                            : null,
                      ),
                      child: Row(children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(slot.timeLabel,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isCurrent ? s.primary : null)),
                              if (isCurrent)
                                Text('Current',
                                    style: TextStyle(
                                        color: s.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                            ]),
                        const Spacer(),
                        Text('${slot.amountMl} ml',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isPast || isCurrent ? s.primary : Colors.grey)),
                        const SizedBox(width: 8),
                        if (isPast)
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF4CAF50), size: 20),
                      ]),
                    ),
                  ),
                ]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sumItem(BuildContext ctx, String val, String lbl, Color c) {
    return Column(children: [
      Text(val,
          style: TextStyle(
              color: c, fontWeight: FontWeight.bold, fontSize: 20)),
      Text(lbl, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ]);
  }
}
