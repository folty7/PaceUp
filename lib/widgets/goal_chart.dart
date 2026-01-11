import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';

class GoalChart extends StatelessWidget {
  final List<Activity> activities;
  final double targetValue;
  final String title;
  final String unit;

  const GoalChart({
    super.key,
    required this.activities,
    required this.targetValue,
    required this.title,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Text(
            'Načítaj aktivity pre zobrazenie grafu',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    // Zoradenie aktivít podľa dátumu
    final sortedActivities = List<Activity>.from(activities)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Príprava dát pre graf
    final actualSpots = <FlSpot>[];
    double cumulativeDistance = 0;

    for (int i = 0; i < sortedActivities.length; i++) {
      final activity = sortedActivities[i];
      cumulativeDistance += activity.distance;
      actualSpots.add(FlSpot(i.toDouble(), cumulativeDistance));
    }

    // Cieľová čiara (rovná)
    final targetSpots = <FlSpot>[
      FlSpot(0, targetValue),
      FlSpot((sortedActivities.length - 1).toDouble(), targetValue),
    ];

    // Nájdenie min a max hodnôt pre Y os
    double minY = 0;
    double maxY = [cumulativeDistance, targetValue].reduce((a, b) => a > b ? a : b) * 1.1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _LegendItem(color: Colors.blue, label: 'Aktuálne'),
              const SizedBox(width: 16),
              _LegendItem(color: Colors.orange, label: 'Cieľ'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                minX: 0,
                maxX: (sortedActivities.length - 1).toDouble(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: (sortedActivities.length > 10)
                          ? (sortedActivities.length / 10).ceil().toDouble()
                          : 1.0,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < sortedActivities.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'T${value.toInt() + 1}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                lineBarsData: [
                  // Aktuálne hodnoty (modrá čiara)
                  LineChartBarData(
                    spots: actualSpots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.blue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.withOpacity(0.5),
                          Colors.cyan.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                  // Cieľová hodnota (oranžová čiara)
                  LineChartBarData(
                    spots: targetSpots,
                    isCurved: false,
                    color: Colors.orange,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5], // Prerušovaná čiara
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final activity = sortedActivities[spot.x.toInt()];
                        String text;
                        if (spot.barIndex == 0) {
                          // Aktuálne hodnoty - format date for display
                          final formattedDate = DateFormat('dd.MM.yyyy').format(DateTime.parse(activity.date));
                          text = '$formattedDate\nCelkom: ${spot.y.toStringAsFixed(1)} $unit';
                        } else {
                          // Cieľ
                          text = 'Cieľ: ${spot.y.toStringAsFixed(1)} $unit';
                        }
                        return LineTooltipItem(
                          text,
                          TextStyle(
                            color: spot.barIndex == 0 ? Colors.blue : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pre legendu
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
