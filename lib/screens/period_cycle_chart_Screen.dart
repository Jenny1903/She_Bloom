import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../constants/colors.dart';
import '../services/period_service.dart';

class PeriodCycleChartScreen extends StatefulWidget {
  const PeriodCycleChartScreen({super.key});

  @override
  State<PeriodCycleChartScreen> createState() =>
      _PeriodCycleChartScreenState();
}

class _PeriodCycleChartScreenState extends State<PeriodCycleChartScreen>
    with SingleTickerProviderStateMixin {
  final PeriodService _periodService = PeriodService();
  late TabController _tabController;

  bool _isLoading = true;

  //Raw data
  Set<DateTime> _allPeriodDates = {};
  int _cycleLength = 28;
  int _periodLength = 5;

  //Derived/computed
  List<_PeriodBlock> _periodBlocks = [];   // Each detected period
  List<_CycleEntry> _cycleEntries = [];    // Cycle lengths between periods
  List<_HeatCell> _heatCells = [];         // Last 6 months heat map cells

  // Stats
  double _avgCycleLength = 0;
  double _avgPeriodLength = 0;
  int _shortestCycle = 0;
  int _longestCycle = 0;
  DateTime? _nextPredicted;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //Data loading & processing

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _allPeriodDates = await _periodService.loadPeriodDates();
    final settings = await _periodService.loadCycleSettings();
    if (settings != null) {
      _cycleLength = settings['cycleLength'] ?? 28;
      _periodLength = settings['periodLength'] ?? 5;
    }

    _processData();
    setState(() => _isLoading = false);
  }

  void _processData() {
    if (_allPeriodDates.isEmpty) return;

    final sorted = _allPeriodDates.toList()..sort();

    //group into period blocks(consecutive days)
    _periodBlocks = [];
    List<DateTime> current = [sorted.first];
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
        current.add(sorted[i]);
      } else {
        _periodBlocks.add(_PeriodBlock(days: List.from(current)));
        current = [sorted[i]];
      }
    }
    _periodBlocks.add(_PeriodBlock(days: List.from(current)));

    //compute cycle length
    _cycleEntries = [];
    for (int i = 1; i < _periodBlocks.length; i++) {
      final days = _periodBlocks[i].start
          .difference(_periodBlocks[i - 1].start)
          .inDays;
      _cycleEntries.add(_CycleEntry(
        index: i,
        cycleLength: days,
        periodLength: _periodBlocks[i - 1].length,
        startDate: _periodBlocks[i - 1].start,
      ));
    }
    // Add the last period as final entry (no next yet)
    if (_periodBlocks.isNotEmpty) {
      _cycleEntries.add(_CycleEntry(
        index: _periodBlocks.length,
        cycleLength: _cycleLength, // use average as placeholder
        periodLength: _periodBlocks.last.length,
        startDate: _periodBlocks.last.start,
      ));
    }

    //stats

    if (_cycleEntries.length > 1) {
      final realCycles = _cycleEntries.take(_cycleEntries.length - 1).toList();
      _avgCycleLength =
          realCycles.map((e) => e.cycleLength).reduce((a, b) => a + b) /
              realCycles.length;
      _shortestCycle =
          realCycles.map((e) => e.cycleLength).reduce((a, b) => a < b ? a : b);
      _longestCycle =
          realCycles.map((e) => e.cycleLength).reduce((a, b) => a > b ? a : b);
    } else {
      _avgCycleLength = _cycleLength.toDouble();
      _shortestCycle = _cycleLength;
      _longestCycle = _cycleLength;
    }

    _avgPeriodLength =
        _periodBlocks.map((b) => b.length).reduce((a, b) => a + b) /
            _periodBlocks.length;

    // Predict next
    if (_periodBlocks.isNotEmpty) {
      _nextPredicted = _periodBlocks.last.start
          .add(Duration(days: _avgCycleLength.round()));
    }

    //heat map
    _buildHeatMap();
  }

  void _buildHeatMap() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 5, 1);
    _heatCells = [];

    for (DateTime d = start;
    !d.isAfter(DateTime(now.year, now.month + 1, 0));
    d = d.add(const Duration(days: 1))) {
      final normalized = DateTime(d.year, d.month, d.day);
      _heatCells.add(_HeatCell(
        date: normalized,
        hasPeriod: _allPeriodDates.contains(normalized),
      ));
    }
  }

  // build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFCE4EC),
              Color(0xFFF8BBD9),
              Color(0xFFE1BEE7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildTabBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _allPeriodDates.isEmpty
                    ? _buildEmptyState()
                    : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildCycleChartTab(),
                    _buildHeatMapTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 22),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.4),
              padding: const EdgeInsets.all(10),
            ),
          ),
          const Text(
            'Cycle Insights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _loadData,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.4),
              padding: const EdgeInsets.all(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.darkPink,
                borderRadius: BorderRadius.circular(14),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textMedium,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Cycles'),
                Tab(text: 'Heat Map'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🌸', style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'No period data yet',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Log your period in the tracker\nto see charts here',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMedium, fontSize: 15),
          ),
        ],
      ),
    );
  }



  //Date helpers
  String _formatDate(DateTime d) {
    const m = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _shortMonth(DateTime d) {
    const m = ['J','F','M','A','M','J','J','A','S','O','N','D'];
    return m[d.month - 1];
  }

  String _monthYearLabel(int year, int month) {
    const m = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return '${m[month - 1]} $year';
  }
}

//Data models

class _PeriodBlock {
  final List<DateTime> days;
  _PeriodBlock({required this.days});
  DateTime get start => days.first;
  int get length => days.length;
}

class _CycleEntry {
  final int index;
  final int cycleLength;
  final int periodLength;
  final DateTime startDate;
  _CycleEntry({
    required this.index,
    required this.cycleLength,
    required this.periodLength,
    required this.startDate,
  });
}

class _HeatCell {
  final DateTime date;
  final bool hasPeriod;
  _HeatCell({required this.date, required this.hasPeriod});
}