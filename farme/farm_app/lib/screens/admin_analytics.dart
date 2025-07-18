import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';

class AdminAnalyticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Analysis', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer2<ProductProvider, OrderProvider>(
        builder: (context, productProvider, orderProvider, child) {
          final totalProducts = productProvider.products.length;
          final categories = productProvider.categories.where((c) => c != 'All').toList();
          final totalCategories = categories.length;
          final totalOrders = orderProvider.orders.length;
          // For demo, let's sum all order totals for monthly income
          final monthlyIncome = orderProvider.orders.fold<double>(0, (sum, order) => sum + order.total);
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profit Summary Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.deepOrange.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withAlpha((0.12 * 255).toInt()),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Profit amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 8),
                        Text('₵25,237.00', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.trending_up, color: Colors.white, size: 18),
                            SizedBox(width: 4),
                            Text('+12%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Text('From last week', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          height: 60,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, 1),
                                    FlSpot(1, 2.5),
                                    FlSpot(2, 1.8),
                                    FlSpot(3, 3.5),
                                    FlSpot(4, 2.2),
                                    FlSpot(5, 4.0),
                                  ],
                                  isCurved: true,
                                  color: Colors.white, // <-- Corrected
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(show: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatCard(label: 'Total Products', value: '$totalProducts'),
                    _StatCard(label: 'Categories', value: '$totalCategories'),
                    _StatCard(label: 'Total Orders', value: '$totalOrders'),
                    _StatCard(label: 'Monthly Income', value: '₵${monthlyIncome.toStringAsFixed(2)}'),
                  ],
                ),
                SizedBox(height: 24),
                // Sales Statistics Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sales Statistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('Monthly', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 8,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                                      return Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text(months[value.toInt() % months.length], style: TextStyle(fontSize: 12)),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              gridData: FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 6, color: Colors.orange)]),
                                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 7, color: Colors.orange)]),
                                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 5, color: Colors.orange)]),
                                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 6.5, color: Colors.orange)]),
                                BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 4, color: Colors.orange)]),
                                BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 7.5, color: Colors.orange)]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // Product Category Breakdown
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Product Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            for (final category in categories)
                              _CategoryStat(
                                label: category,
                                value: productProvider.products.where((p) => p.category == category).length.toString(),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}

class _CategoryStat extends StatelessWidget {
  final String label;
  final String value;
  const _CategoryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }
} 