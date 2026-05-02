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

  //Derived / computed
  List<_PeriodBlock> _periodBlocks = [];   // Each detected period
  List<_CycleEntry> _cycleEntries = [];    // Cycle lengths between periods
  List<_HeatCell> _heatCells = [];         // Last 6 months heat map cells

  //Stats
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

    //Group into period blocks (consecutive days)
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

    //Compute cycle lengths
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
    //Add the last period as final entry (no next yet)
    if (_periodBlocks.isNotEmpty) {
      _cycleEntries.add(_CycleEntry(
        index: _periodBlocks.length,
        cycleLength: _cycleLength,
        periodLength: _periodBlocks.last.length,
        startDate: _periodBlocks.last.start,
      ));
    }

    //Stats
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

    //Predict next
    if (_periodBlocks.isNotEmpty) {
      _nextPredicted = _periodBlocks.last.start
          .add(Duration(days: _avgCycleLength.round()));
    }

    //Heat map: last 6 months
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

  //Build

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

//Tab 1: Overview

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          _buildNextPeriodBanner(),
          const SizedBox(height: 16),
          _buildStatsGrid(),
          const SizedBox(height: 16),
          _buildPeriodHistoryList(),
        ],
      ),
    );
  }

  Widget _buildNextPeriodBanner() {
    final now = DateTime.now();
    final daysUntil = _nextPredicted?.difference(now).inDays;
    String label;
    Color bannerColor;

    if (_nextPredicted == null) {
      label = 'Log more data to predict';
      bannerColor = AppColors.coral;
    } else if (daysUntil! < 0) {
      label = 'Period is ${-daysUntil} day${-daysUntil == 1 ? '' : 's'} late';
      bannerColor = Colors.orange.shade600;
    } else if (daysUntil == 0) {
      label = 'Period expected today';
      bannerColor = AppColors.darkPink;
    } else {
      label = 'Next period in $daysUntil day${daysUntil == 1 ? '' : 's'}';
      bannerColor = AppColors.darkPink;
    }

    return _glassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bannerColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_active_rounded,
                color: bannerColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Prediction',
                    style:
                    TextStyle(fontSize: 12, color: AppColors.textMedium)),
                const SizedBox(height: 4),
                Text(label,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: bannerColor)),
                if (_nextPredicted != null)
                  Text(
                    _formatDate(_nextPredicted!),
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textMedium),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          emoji: '🔄',
          label: 'Avg Cycle',
          value: '${_avgCycleLength.toStringAsFixed(1)} days',
          color: AppColors.darkPink,
        ),
        _buildStatCard(
          emoji: '🩸',
          label: 'Avg Period',
          value: '${_avgPeriodLength.toStringAsFixed(1)} days',
          color: AppColors.coral,
        ),
        _buildStatCard(
          emoji: '📉',
          label: 'Shortest',
          value: '$_shortestCycle days',
          color: const Color(0xFF7986CB),
        ),
        _buildStatCard(
          emoji: '📈',
          label: 'Longest',
          value: '$_longestCycle days',
          color: const Color(0xFF4DD0E1),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String emoji,
    required String label,
    required String value,
    required Color color,
  }) {
    return _glassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
        ],
      ),
    );
  }

  Widget _buildPeriodHistoryList() {
    final recent = _periodBlocks.reversed.take(6).toList();
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Periods',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 16),
          if (recent.isEmpty)
            Text('No periods logged yet',
                style: TextStyle(color: AppColors.textMedium))
          else
            ...recent.asMap().entries.map((e) {
              final block = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.darkPink,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _formatDate(block.start),
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.darkPink.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${block.length} day${block.length == 1 ? '' : 's'}',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.darkPink,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }


  //Tab 2: cycle chart tab

  Widget _buildCycleChartTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          _buildCycleLengthChart(),
          const SizedBox(height: 16),
          _buildPeriodLengthChart(),
        ],
      ),
    );
  }

  Widget _buildCycleLengthChart() {
    //Use only real cycle entries (exclude last placeholder)
    final entries = _cycleEntries.length > 1
        ? _cycleEntries.take(_cycleEntries.length - 1).toList()
        : _cycleEntries;

    if (entries.isEmpty) {
      return _glassCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Need at least 2 periods to show cycle chart',
                style: TextStyle(color: AppColors.textMedium),
                textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final maxY = (entries.map((e) => e.cycleLength).reduce((a, b) => a > b ? a : b) + 5).toDouble();

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cycle Length History',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text('Days between periods',
              style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 7,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 7,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.textMedium),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= entries.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _shortMonth(entries[i].startDate),
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textMedium),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: entries.asMap().entries.map((e) {
                  final isAboveAvg =
                      e.value.cycleLength > _avgCycleLength;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.cycleLength.toDouble(),
                        width: 18,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isAboveAvg
                              ? [
                            AppColors.coral.withOpacity(0.7),
                            AppColors.coral,
                          ]
                              : [
                            AppColors.darkPink.withOpacity(0.7),
                            AppColors.darkPink,
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
                // Average line overlay
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: _avgCycleLength,
                      color: Colors.orange.shade400,
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        labelResolver: (_) =>
                        'Avg ${_avgCycleLength.toStringAsFixed(0)}d',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange.shade600,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _dot(AppColors.darkPink),
              const SizedBox(width: 6),
              Text('Below avg', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
              const SizedBox(width: 16),
              _dot(AppColors.coral),
              const SizedBox(width: 6),
              Text('Above avg', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
              const SizedBox(width: 16),
              Container(width: 18, height: 2, color: Colors.orange.shade400),
              const SizedBox(width: 6),
              Text('Average', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodLengthChart() {
    if (_periodBlocks.isEmpty) return const SizedBox();

    final blocks = _periodBlocks.length > 8
        ? _periodBlocks.sublist(_periodBlocks.length - 8)
        : _periodBlocks;

    final spots = blocks.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.length.toDouble()))
        .toList();

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Period Length Trend',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text('Days of bleeding per cycle',
              style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 12,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 3,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 3,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}d',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.textMedium),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= blocks.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _shortMonth(blocks[i].start),
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textMedium),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.coral,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) =>
                          FlDotCirclePainter(
                            radius: 5,
                            color: Colors.white,
                            strokeWidth: 2.5,
                            strokeColor: AppColors.coral,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.coral.withOpacity(0.3),
                          AppColors.coral.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Tab 3: Heat Map
  Widget _buildHeatMapTab() {
    // Group heat cells by month
    final Map<String, List<_HeatCell>> byMonth = {};
    for (final cell in _heatCells) {
      final key = '${cell.date.year}-${cell.date.month}';
      byMonth.putIfAbsent(key, () []).add(cell);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          _buildHeatLegend(),
          const SizedBox(height: 16),
          ...byMonth.entries.map((entry) {
            final parts = entry.key.split('-');
            final year = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildMonthHeatMap(
                  year: year, month: month, cells: entry.value),
            );
          }),
        ],
      ),
    );
  }


  //shared UI helpers

  Widget _glassCard({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.55),
                Colors.white.withOpacity(0.35),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _dot(Color color) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _heatDot(Color color, {Color? border}) => Container(
    width: 16,
    height: 16,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
      border: border != null ? Border.all(color: border, width: 1.5) : null,
    ),
  );

  //data helpers

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

//data models

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