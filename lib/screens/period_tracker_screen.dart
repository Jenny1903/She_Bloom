import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/period.service.dart';


class PeriodTrackerScreen extends StatefulWidget {
  const PeriodTrackerScreen({super.key});

  @override
  State<PeriodTrackerScreen> createState() => _PeriodTrackerScreenState();
}

class _PeriodTrackerScreenState extends State<PeriodTrackerScreen> {
  DateTime _selectedMonth = DateTime.now();
  DateTime _today = DateTime.now();

  //firebase service
  final PeriodService _periodService = PeriodService();

  // Store period dates (loaded from Firebase)
  Set<DateTime> periodDates = {};

  int averageCycleLength = 28;
  int averagePeriodLength = 5;
  DateTime? lastPeriodStart;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  //load all data from Firebase
  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    //load all period dates
    Set<DateTime> loadedDates = await _periodService.loadPeriodDates();

    //load cycle settings
    Map<String, int>? settings = await _periodService.loadCycleSettings();

    setState(() {
      periodDates = loadedDates;
      if(settings != null){
        averageCycleLength = settings['cyecleLength'] ?? 28;
        averagePeriodLength = settings['periodLength'] ?? 5;
      }
      isLoading = false;
    });
    _calculateLastPeriod();
  }

  void _calculateLastPeriod() {
    if (periodDates.isNotEmpty) {
      List<DateTime> sortedDates = periodDates.toList()..sort();
      lastPeriodStart = sortedDates.last;
    }
  }

  DateTime? _predictNextPeriod() {
    if (lastPeriodStart == null) return null;
    return lastPeriodStart!.add(Duration(days: averageCycleLength));
  }

  void _togglePeriodDate(DateTime date) async {
    // Normalize date (remove time)
    DateTime normalizedDate = DateTime(date.year, date.month, date.day);

    bool wasAdded = !periodDates.contains(normalizedDate);

    // Optimistic update (update UI immediately)
    setState(() {
      if (wasAdded) {
        periodDates.add(normalizedDate);
      } else {
        periodDates.remove(normalizedDate);
      }
      _calculateLastPeriod();
    });

    //save to Firebase
    bool success;
    if (wasAdded) {
      success = await _periodService.savePeriodDate(normalizedDate);
    } else {
      success = await _periodService.removePeriodDate(normalizedDate);
    }

    if (success) {
      String message = wasAdded ? 'Period day added ✅' : 'Period day removed ✅';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
          backgroundColor: wasAdded ? Colors.green : Colors.grey,
        ),
      );
    } else {
      // Revert if save failed
      setState(() {
        if (wasAdded) {
          periodDates.remove(normalizedDate);
        } else {
          periodDates.add(normalizedDate);
        }
        _calculateLastPeriod();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isPeriodDay(DateTime date) {
    return periodDates.contains(DateTime(date.year, date.month, date.day));
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkGrey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Period Tracker',
          style: TextStyle(
            color: AppColors.darkGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.darkPink),
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Cycle info card
              _buildCycleInfoCard(),

              const SizedBox(height: 20),

              // Calendar
              _buildCalendar(),

              const SizedBox(height: 20),

              // Legend
              _buildLegend(),

              const SizedBox(height: 20),

              // Quick actions
              _buildQuickActions(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  //cycle info card
  Widget _buildCycleInfoCard() {
    DateTime? nextPeriod = _predictNextPeriod();
    int? daysUntilNext = nextPeriod?.difference(_today).inDays;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkPink, AppColors.coral],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPink.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                icon: Icons.calendar_today,
                label: 'Cycle Length',
                value: '$averageCycleLength days',
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildInfoItem(
                icon: Icons.water_drop,
                label: 'Period Days',
                value: '${periodDates.length} days',
              ),
            ],
          ),

          if (nextPeriod != null && daysUntilNext != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    daysUntilNext > 0
                        ? 'Next period in $daysUntilNext days'
                        : daysUntilNext == 0
                        ? 'Period expected today'
                        : 'Period is ${-daysUntilNext} days late',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  //calendar widget
  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: AppColors.darkGrey),
                onPressed: _previousMonth,
              ),
              Text(
                _getMonthYearString(_selectedMonth),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: AppColors.darkGrey),
                onPressed: _nextMonth,
              ),
            ],
          ),

          const SizedBox(height: 16),

          //weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                .map((day) => SizedBox(
              width: 40,
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium,
                ),
              ),
            ))
                .toList(),
          ),

          const SizedBox(height: 8),

          // Calendar grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    List<Widget> rows = [];
    List<DateTime?> daysInMonth = _getDaysInMonth(_selectedMonth);

    for (int i = 0; i < daysInMonth.length; i += 7) {
      List<DateTime?> week = daysInMonth.sublist(
        i,
        i + 7 > daysInMonth.length ? daysInMonth.length : i + 7,
      );

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: week.map((date) => _buildDayCell(date)).toList(),
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildDayCell(DateTime? date) {
    if (date == null) {
      return const SizedBox(width: 40, height: 40);
    }

    bool isToday = date.year == _today.year &&
        date.month == _today.month &&
        date.day == _today.day;

    bool isPeriod = _isPeriodDay(date);

    return GestureDetector(
      onTap: () => _togglePeriodDate(date),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isPeriod
              ? AppColors.darkPink
              : isToday
              ? AppColors.lightPink
              : Colors.transparent,
          shape: BoxShape.circle,
          border: isToday && !isPeriod
              ? Border.all(color: AppColors.darkPink, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isPeriod
                  ? Colors.white
                  : isToday
                  ? AppColors.darkPink
                  : AppColors.darkGrey,
            ),
          ),
        ),
      ),
    );
  }

  //legend
  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(AppColors.darkPink, 'Period Day'),
          const SizedBox(width: 20),
          _buildLegendItem(AppColors.lightPink, 'Today', isOutline: true),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isOutline = false}) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isOutline ? Colors.transparent : color,
            shape: BoxShape.circle,
            border: isOutline ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMedium,
          ),
        ),
      ],
    );
  }

  //quick actions
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                _togglePeriodDate(_today);
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Log Today',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Show history
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History view - Coming soon!')),
                );
              },
              icon: Icon(Icons.history, color: AppColors.darkPink),
              label: Text(
                'View History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkPink,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.darkPink, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //helper: Get days in month
  List<DateTime?> _getDaysInMonth(DateTime month) {
    List<DateTime?> days = [];

    // Get first day of month
    DateTime firstDay = DateTime(month.year, month.month, 1);
    int firstWeekday = firstDay.weekday % 7; // 0 = Sunday

    // Add empty cells for days before month starts
    for (int i = 0; i < firstWeekday; i++) {
      days.add(null);
    }

    // Add all days in month
    int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    for (int day = 1; day <= daysInMonth; day++) {
      days.add(DateTime(month.year, month.month, day));
    }

    return days;
  }

  //helper: Get month/year string
  String _getMonthYearString(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
