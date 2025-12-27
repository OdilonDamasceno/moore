import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moore/core/ui/themes/app_colors.dart';
import 'package:moore/l10n/app_localizations.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({super.key});

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime _displayed = DateTime.now();
  DateTime _selected = DateTime.now();

  late final List<String> _weekDays;
  late final List<String> _monthNames;

  @override
  void initState() {
    final weekdays = DateFormat().dateSymbols.WEEKDAYS.map((e) => e.substring(0, 3)).toList();
    _weekDays = weekdays; // Start from Monday
    _monthNames = DateFormat().dateSymbols.MONTHS;
    super.initState();
  }

  void _prevMonth() {
    setState(() {
      _displayed = DateTime(_displayed.year, _displayed.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayed = DateTime(_displayed.year, _displayed.month + 1, 1);
    });
  }

  void _selectedDate(DateTime date) {
    setState(() {
      _selected = date;
    });
  }

  int _daysInMonth(int year, int month) {
    final nextMonth = (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = _displayed.year;
    final month = _displayed.month;
    final firstWeekday = DateTime(year, month, 1).weekday + 1;
    final daysInMonth = _daysInMonth(year, month);

    final List<Widget> dayCells = [];

    final leadingEmpty = (firstWeekday - 1) % 7; // Monday start

    for (var i = 0; i < leadingEmpty; i++) {
      dayCells.add(const SizedBox.shrink());
    }

    for (var d = 1; d <= daysInMonth; d++) {
      final isToday = now.year == year && now.month == month && now.day == d;
      final isSelected = _selected.year == year && _selected.month == month && _selected.day == d;
      dayCells.add(
        GestureDetector(
          onTap: () {
            _selectedDate(DateTime(year, month, d));
          },
          behavior: HitTestBehavior.opaque,
          child: Badge(
            alignment: Alignment.topRight - const Alignment(0.3, -0.3),
            smallSize: 3,
            backgroundColor: AppColors.primary.shade600,
            isLabelVisible: false,
            child: Container(
              margin: const .all(1),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.shade600
                    : const Color.fromARGB(255, 15, 15, 15),
                border: isToday
                    ? Border.all(
                        color: AppColors.primary.shade600,
                        width: 1,
                      )
                    : null,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                d.toString(),

                style: const TextStyle(
                  color: AppColors.white,
                  height: 0.6,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
      );
    }

    while (dayCells.length % 7 != 0) {
      dayCells.add(const SizedBox.shrink());
    }

    return Material(
      child: Row(
        crossAxisAlignment: .center,
        children: [
          Flexible(
            flex: 2,
            child: _buildCalendar(month, year, dayCells),
          ),
          VerticalDivider(
            color: AppColors.grey.shade900,
            width: 16,
            thickness: 1,
          ),
          Expanded(
            flex: 3,
            child: _buildEventCalendar(_selected),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCalendar(DateTime selected) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            DateFormat.EEEE().format(selected),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
            ),
          ),
          Text(
            '${selected.day} ${_monthNames[selected.month - 1]} ${selected.year}',
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Text(
                l10n.noEventsForThisDay,
                style: TextStyle(
                  color: AppColors.grey.shade400,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(int month, int year, List<Widget> dayCells) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: .center,
          children: [
            Text(
              '${_monthNames[month - 1]}, $year',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: AppColors.white,
                size: 16,
              ),
              onPressed: _prevMonth,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            IconButton(
              icon: const Icon(
                Icons.chevron_right,
                color: AppColors.white,
                size: 16,
              ),
              onPressed: _nextMonth,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        Expanded(
          child: Align(
            alignment: .bottomCenter,
            child: GridView.count(
              padding: .zero,
              crossAxisCount: 7,
              childAspectRatio: 1.8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ..._weekDays.map(
                  (day) => Center(
                    child: Text(
                      day.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ),
                ...dayCells,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
