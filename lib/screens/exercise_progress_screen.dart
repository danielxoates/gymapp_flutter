import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';
import '../data/storage.dart';
import '../data/exercises.dart';
import 'package:intl/intl.dart';

class ExerciseProgressScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseProgressScreen({super.key, required this.exercise});

  @override
  State<ExerciseProgressScreen> createState() => _ExerciseProgressScreenState();
}

class _ExerciseProgressScreenState extends State<ExerciseProgressScreen> {
  ExerciseProgressData? data;
  bool loading = true;
  String selectedMetric = 'weight'; // 'weight', 'volume', 'reps', 'max'

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final progressData = await getExerciseProgress(widget.exercise.id);
    if (mounted) {
      setState(() {
        data = progressData;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.exercise.name,
          style: const TextStyle(
            color: AppTheme.text,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : data == null || data!.totalSets == 0
              ? _buildEmptyState()
              : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart,
              size: 80, color: AppTheme.textMuted.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'No data yet',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete a workout with this exercise\nto see your progress',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(),
          const SizedBox(height: 16),
          _buildChartCard(),
          const SizedBox(height: 16),
          _buildHistorySection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Personal Best',
                  '${data!.maxWeight.toStringAsFixed(1)} kg',
                  Icons.emoji_events,
                  AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Volume',
                  '${(data!.totalVolume / 1000).toStringAsFixed(1)}k kg',
                  Icons.fitness_center,
                  const Color(0xFF4ECDC4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Sets',
                  data!.totalSets.toString(),
                  Icons.format_list_numbered,
                  const Color(0xFFFFE66D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Workouts',
                  data!.totalWorkouts.toString(),
                  Icons.calendar_today,
                  const Color(0xFFFF8A5C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Avg Weight',
                  '${data!.avgWeight.toStringAsFixed(1)} kg',
                  Icons.straighten,
                  const Color(0xFFA8E6CF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Avg Reps',
                  data!.avgReps.toStringAsFixed(1),
                  Icons.repeat,
                  const Color(0xFF6C63FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.text,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress Over Time',
              style: TextStyle(
                color: AppTheme.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildMetricSelector(),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildMetricChip('Max Weight', 'weight'),
          const SizedBox(width: 8),
          _buildMetricChip('Volume', 'volume'),
          const SizedBox(width: 8),
          _buildMetricChip('Total Reps', 'reps'),
          const SizedBox(width: 8),
          _buildMetricChip('1RM Est.', 'max'),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value) {
    final selected = selectedMetric == value;
    return GestureDetector(
      onTap: () => setState(() => selectedMetric = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (data == null || data!.sets.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      );
    }

    // Group sets by workout date to get daily aggregates
    final Map<String, List<ExerciseSetData>> grouped = {};
    for (final set in data!.sets) {
      final dateKey = DateFormat('yyyy-MM-dd').format(set.date);
      grouped.putIfAbsent(dateKey, () => []).add(set);
    }

    // Sort by date
    final sortedDates = grouped.keys.toList()..sort();
    
    // Calculate metric for each date
    final List<FlSpot> spots = [];
    for (int i = 0; i < sortedDates.length; i++) {
      final sets = grouped[sortedDates[i]]!;
      double value = 0;
      
      switch (selectedMetric) {
        case 'weight':
          // Max weight for that day
          value = sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
          break;
        case 'volume':
          // Total volume for that day
          value = sets.fold(0.0, (sum, s) => sum + (s.weight * s.reps));
          break;
        case 'reps':
          // Total reps for that day
          value = sets.fold(0.0, (sum, s) => sum + s.reps);
          break;
        case 'max':
          // Estimated 1RM using Epley formula: weight * (1 + reps/30)
          value = sets
              .map((s) => s.weight * (1 + s.reps / 30))
              .reduce((a, b) => a > b ? a : b);
          break;
      }
      
      spots.add(FlSpot(i.toDouble(), value));
    }

    // Calculate min/max for Y axis
    final values = spots.map((s) => s.y).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final yRange = maxY - minY;
    final yMin = yRange > 0 ? (minY - yRange * 0.1).clamp(0, double.infinity) : (minY * 0.9).clamp(0, double.infinity);
    final yMax = yRange > 0 ? maxY + yRange * 0.1 : maxY * 1.1 + 1;
    final yTotalRange = yMax - yMin;
    final interval = yTotalRange > 0 ? yTotalRange / 5 : 1.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.border.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (spots.length / 5).ceilToDouble().clamp(1, double.infinity),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sortedDates.length) {
                  return const Text('');
                }
                final date = DateTime.parse(sortedDates[index]);
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('M/d').format(date),
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: interval,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppTheme.border.withOpacity(0.3)),
        ),
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: yMin.toDouble(),
        maxY: yMax.toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.primary,
                  strokeWidth: 2,
                  strokeColor: AppTheme.bgCard,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primary.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => AppTheme.bgCard,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index < 0 || index >= sortedDates.length) return null;
                final date = DateTime.parse(sortedDates[index]);
                String label = '';
                switch (selectedMetric) {
                  case 'weight':
                    label = '${spot.y.toStringAsFixed(1)} kg';
                    break;
                  case 'volume':
                    label = '${spot.y.toStringAsFixed(0)} kg';
                    break;
                  case 'reps':
                    label = '${spot.y.toStringAsFixed(0)} reps';
                    break;
                  case 'max':
                    label = '${spot.y.toStringAsFixed(1)} kg';
                    break;
                }
                return LineTooltipItem(
                  '${DateFormat('MMM d').format(date)}\n$label',
                  const TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    // Group sets by date
    final Map<String, List<ExerciseSetData>> grouped = {};
    for (final set in data!.sets.reversed) {
      final dateKey = DateFormat('yyyy-MM-dd').format(set.date);
      grouped.putIfAbsent(dateKey, () => []).add(set);
    }

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'History',
            style: TextStyle(
              color: AppTheme.text,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...sortedDates.map((dateKey) {
            final sets = grouped[dateKey]!;
            final date = DateTime.parse(dateKey);
            return _buildHistoryItem(date, sets);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(DateTime date, List<ExerciseSetData> sets) {
    final maxWeight = sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
    final totalVolume = sets.fold(0.0, (sum, s) => sum + (s.weight * s.reps));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMM d, yyyy').format(date),
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sets.first.workoutName,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fitness_center,
                          size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${sets.length} sets',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHistoryStat(
                    'Max', '${maxWeight.toStringAsFixed(1)} kg'),
              ),
              Expanded(
                child: _buildHistoryStat(
                    'Volume', '${totalVolume.toStringAsFixed(0)} kg'),
              ),
            ],
          ),
          const Divider(height: 24, color: AppTheme.border),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sets.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final set = entry.value;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$index: ${set.weight}kg × ${set.reps}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
