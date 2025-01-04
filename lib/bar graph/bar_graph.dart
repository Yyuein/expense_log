import 'package:expense_log/bar%20graph/individual_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth; // 0 JAN, 1 FEB, 2 MAR ...
  const MyBarGraph(
      {super.key, required this.monthlySummary, required this.startMonth});

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  // this list will hold the data for each bar
  List<IndividualBar> barData = [];

  @override
  void initState() {
    super.initState();

    // we need to scroll to the lastest month automatically
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => scrollToEnd());
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
    double max = 5000;

    widget.monthlySummary.sort();

    max = widget.monthlySummary.last * 1.05;

    if (max < 5000) {
      return 5000;
    }

    return max;
  }

  // scroll controller to make sure it scrolls to the end / latest month
  final ScrollController _scrollController = ScrollController();
  void scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent, 
      duration: const Duration(seconds: 1), 
      curve: Curves.fastOutSlowIn,
      );
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
          width: barWidth * barData.length + spaceBetweenBars * (barData.length - 1),
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: calculateMax(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
                show: true,
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: getBottomTitles,
                    reservedSize: 24,
                  ),
                ),
              ),
              barGroups: barData.map(
                (data) => BarChartGroupData(
                  x: data.x,
                  barRods: [
                    BarChartRodData(
                      toY: data.y,
                      width: barWidth,
                      borderRadius: BorderRadius.circular(4),
                      color: Color.fromARGB(255, 75, 70, 65),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: calculateMax(),
                        color: Colors.white
                      ),
                      ),
                  ],
                  ),
              ).toList(),
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
  Widget getBottomTitles(double value, TitleMeta meta) {
    const textstyle = TextStyle(
    color: Color.fromARGB(255, 150, 159, 168),
    fontWeight: FontWeight.bold,
    fontSize: 14
    );

    String text;
    switch(value.toInt() % 12) {
      case 0: text = "Jan"; break;
      case 1: text = "Feb"; break;
      case 2: text = "Mar"; break;
      case 3: text = "Apr"; break;
      case 4: text = "May"; break;
      case 5: text = "Jun"; break;
      case 6: text = "Jul"; break;
      case 7: text = "Aug"; break;
      case 8: text = "Sep"; break;
      case 9: text = "Oct"; break;
      case 10: text = "Nov"; break;
      case 11: text = "Dec"; break;
      default:
      text ="";
      break;
    }

    return SideTitleWidget(child: Text(text, style: textstyle,), axisSide: meta.axisSide);
  }
