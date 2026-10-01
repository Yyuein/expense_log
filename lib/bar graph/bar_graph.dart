import 'dart:math' as math;

import 'package:expense_log/bar%20graph/individual_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;
  final int selectedIndex;
  final ValueChanged<int> onMonthSelected;
  const MyBarGraph(
      {super.key,
      required this.monthlySummary,
      required this.startMonth,
      required this.selectedIndex,
      required this.onMonthSelected});

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  // this list will hold the data for each bar
  List<IndividualBar> barData = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => scrollToSelectedMonth());
  }

  @override
  void didUpdateWidget(covariant MyBarGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.startMonth != widget.startMonth ||
        oldWidget.monthlySummary.length != widget.monthlySummary.length) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => scrollToSelectedMonth());
    }
  }

  // initialize bar data
  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) => IndividualBar(x: index, y: widget.monthlySummary[index]),
    );
  }

  //calculate max for upper limit of graph
  double calculateMax() {
    final largest = widget.monthlySummary.fold<double>(
      0,
      (largest, amount) => math.max(largest, amount),
    );
    return math.max(5000, largest * 1.05);
  }

  final ScrollController _scrollController = ScrollController();
  void scrollToSelectedMonth() {
    if (!mounted || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    final target =
        (widget.selectedIndex * 35.0 + 17.5 - position.viewportDimension / 2)
            .clamp(0.0, position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // initialize upon build
    initializeBarData();

    // bar dimension sizes
    double barWidth = 20;
    double spaceBetweenBars = 15;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SizedBox(
          width: math.max(
              300,
              barWidth * barData.length +
                  spaceBetweenBars * (barData.length - 1)),
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: calculateMax(),
              barTouchData: BarTouchData(
                handleBuiltInTouches: false,
                allowTouchBarBackDraw: true,
                touchCallback: (event, response) {
                  if (event is FlTapUpEvent && response?.spot != null) {
                    widget.onMonthSelected(response!.spot!.touchedBarGroup.x);
                  }
                },
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => getBottomTitles(
                      value,
                      meta,
                      widget.startMonth,
                    ),
                    reservedSize: 24,
                  ),
                ),
              ),
              barGroups: barData
                  .map(
                    (data) => BarChartGroupData(
                      x: data.x,
                      barRods: [
                        BarChartRodData(
                          toY: data.y,
                          width: barWidth,
                          borderRadius: BorderRadius.circular(4),
                          color: data.x == widget.selectedIndex
                              ? const Color.fromARGB(255, 75, 70, 65)
                              : const Color.fromARGB(255, 150, 159, 168),
                          backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: calculateMax(),
                              color: Colors.white),
                        ),
                      ],
                    ),
                  )
                  .toList(),
              alignment: BarChartAlignment.center,
              groupsSpace: spaceBetweenBars,
            ),
          ),
        ),
      ),
    );
  }
}

// Bottom - Titles
Widget getBottomTitles(double value, TitleMeta meta, int startMonth) {
  const textstyle = TextStyle(
      color: Color.fromARGB(255, 150, 159, 168),
      fontWeight: FontWeight.bold,
      fontSize: 14);

  String text;
  switch ((startMonth - 1 + value.toInt()) % 12) {
    case 0:
      text = "Jan";
      break;
    case 1:
      text = "Feb";
      break;
    case 2:
      text = "Mar";
      break;
    case 3:
      text = "Apr";
      break;
    case 4:
      text = "May";
      break;
    case 5:
      text = "Jun";
      break;
    case 6:
      text = "Jul";
      break;
    case 7:
      text = "Aug";
      break;
    case 8:
      text = "Sep";
      break;
    case 9:
      text = "Oct";
      break;
    case 10:
      text = "Nov";
      break;
    case 11:
      text = "Dec";
      break;
    default:
      text = "";
      break;
  }

  return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        style: textstyle,
      ));
}
