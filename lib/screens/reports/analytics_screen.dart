import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/crop.dart';
import '../../models/livestock.dart';
import '../../models/finance_record.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analíticas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Finanzas'),
            Tab(text: 'Cultivos'),
            Tab(text: 'Ganado'),
            Tab(text: 'Tareas'),
          ],
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _FinancesTab(records: provider.finances),
              _CropsTab(crops: provider.crops),
              _LivestockTab(animals: provider.livestock),
              _TasksTab(tasks: provider.tasks),
            ],
          );
        },
      ),
    );
  }
}

class _FinancesTab extends StatelessWidget {
  final List<FinanceRecord> records;
  const _FinancesTab({required this.records});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat =
        NumberFormat.currency(symbol: 'USD ', decimalDigits: 2);

    final monthlyData = _groupByMonth(records);
    final categories = _groupByCategory(records);

    final totalIncome =
        records.fold<double>(0, (s, r) => r.type.index == 0 ? s + r.amount : s);
    final totalExpense =
        records.fold<double>(0, (s, r) => r.type.index == 1 ? s + r.amount : s);

    if (records.isEmpty) {
      return Center(child: Text('Sin datos financieros'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen mensual',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _maxValue(monthlyData) * 1.2,
                barGroups: monthlyData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value['income'],
                        color: Colors.green,
                        width: 12,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: entry.value['expense'],
                        color: Colors.red,
                        width: 12,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) => Text(
                        '\$${value.toInt()}',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < monthlyData.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              _monthAbbr(monthlyData[idx]['month']),
                              style: TextStyle(fontSize: 9),
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _maxValue(monthlyData) * 1.2 / 4,
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          Text('Distribución por categoría',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: categories.entries.map((e) {
                  final total = totalIncome + totalExpense;
                  return PieChartSectionData(
                    value: e.value,
                    title:
                        '${((e.value / total) * 100).toStringAsFixed(0)}%',
                    color: _categoryColor(e.key),
                    radius: 60,
                    titleStyle: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: categories.entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _categoryColor(e.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                      '${e.key}: ${currencyFormat.format(e.value)}',
                      style: TextStyle(fontSize: 12)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _groupByMonth(List<FinanceRecord> records) {
    final map = <String, Map<String, dynamic>>{};
    for (final r in records) {
      final key = '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => {
            'month': r.date.month,
            'income': 0.0,
            'expense': 0.0,
          });
      if (r.type.index == 0) {
        map[key]!['income'] = (map[key]!['income'] as double) + r.amount;
      } else {
        map[key]!['expense'] = (map[key]!['expense'] as double) + r.amount;
      }
    }
    return map.entries.map((e) => e.value).toList()
      ..sort((a, b) => (a['month'] as int).compareTo(b['month'] as int));
  }

  Map<String, double> _groupByCategory(List<FinanceRecord> records) {
    final map = <String, double>{};
    for (final r in records) {
      map[r.category] = (map[r.category] ?? 0) + r.amount;
    }
    return map;
  }

  double _maxValue(List<Map<String, dynamic>> data) {
    double max = 0;
    for (final d in data) {
      final income = d['income'] as double;
      final expense = d['expense'] as double;
      if (income > max) max = income;
      if (expense > max) max = expense;
    }
    return max > 0 ? max : 100;
  }

  String _monthAbbr(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month - 1];
  }

  Color _categoryColor(String category) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
    ];
    return colors[category.hashCode % colors.length];
  }
}

class _CropsTab extends StatelessWidget {
  final List<Crop> crops;
  const _CropsTab({required this.crops});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (crops.isEmpty) {
      return Center(child: Text('Sin cultivos registrados'));
    }

    final statusCount = <String, int>{};
    for (final c in crops) {
      statusCount[c.status] = (statusCount[c.status] ?? 0) + 1;
    }

    final totalArea = crops.fold<double>(0, (s, c) => s + c.area);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distribución por estado',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  if (statusCount.containsKey('planted'))
                    PieChartSectionData(
                      value: statusCount['planted']!.toDouble(),
                      title: 'Sembrados\n${statusCount['planted']}',
                      color: Colors.blue,
                      radius: 60,
                      titleStyle: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  if (statusCount.containsKey('growing'))
                    PieChartSectionData(
                      value: statusCount['growing']!.toDouble(),
                      title: 'Creciendo\n${statusCount['growing']}',
                      color: Colors.green,
                      radius: 60,
                      titleStyle: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  if (statusCount.containsKey('harvested'))
                    PieChartSectionData(
                      value: statusCount['harvested']!.toDouble(),
                      title: 'Cosechados\n${statusCount['harvested']}',
                      color: Colors.orange,
                      radius: 60,
                      titleStyle: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          SizedBox(height: 24),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statColumn('Total', '${crops.length}', Colors.green),
                  _statColumn(
                      'Área total', '${totalArea.toStringAsFixed(1)} ha', Colors.blue),
                  _statColumn(
                      'Cosechados',
                      '${statusCount['harvested'] ?? 0}',
                      Colors.orange),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _LivestockTab extends StatelessWidget {
  final List<Livestock> animals;
  const _LivestockTab({required this.animals});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (animals.isEmpty) {
      return Center(child: Text('Sin animales registrados'));
    }

    final typeCount = <AnimalType, int>{};
    for (final a in animals) {
      typeCount[a.type] = (typeCount[a.type] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distribución por tipo',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: typeCount.values.reduce((a, b) => a > b ? a : b) * 1.3,
                barGroups: typeCount.entries.map((e) {
                  return BarChartGroupData(
                    x: e.key.index,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.toDouble(),
                        color: _animalColor(e.key),
                        width: 20,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final type =
                            AnimalType.values[value.toInt()];
                        String label;
                        switch (type) {
                          case AnimalType.cattle:
                            label = 'Bovino';
                            break;
                          case AnimalType.pig:
                            label = 'Porcino';
                            break;
                          case AnimalType.chicken:
                            label = 'Ave';
                            break;
                          case AnimalType.goat:
                            label = 'Caprino';
                            break;
                          case AnimalType.sheep:
                            label = 'Ovino';
                            break;
                          case AnimalType.horse:
                            label = 'Equino';
                            break;
                          case AnimalType.other:
                            label = 'Otro';
                            break;
                        }
                        return Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(label,
                              style: TextStyle(fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          ...typeCount.entries.map((e) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _animalColor(e.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('${_animalName(e.key)}: ${e.value}'),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Color _animalColor(AnimalType type) {
    switch (type) {
      case AnimalType.cattle:
        return Colors.brown;
      case AnimalType.pig:
        return Colors.pink;
      case AnimalType.chicken:
        return Colors.orange;
      case AnimalType.goat:
        return Colors.grey;
      case AnimalType.sheep:
        return Colors.blueGrey;
      case AnimalType.horse:
        return Colors.indigo;
      case AnimalType.other:
        return Colors.purple;
    }
  }

  String _animalName(AnimalType type) {
    switch (type) {
      case AnimalType.cattle:
        return 'Bovino';
      case AnimalType.pig:
        return 'Porcino';
      case AnimalType.chicken:
        return 'Aves';
      case AnimalType.goat:
        return 'Caprino';
      case AnimalType.sheep:
        return 'Ovino';
      case AnimalType.horse:
        return 'Equino';
      case AnimalType.other:
        return 'Otro';
    }
  }
}

class _TasksTab extends StatelessWidget {
  final List<dynamic> tasks;
  const _TasksTab({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (tasks.isEmpty) {
      return Center(child: Text('Sin tareas registradas'));
    }

    final completed =
        tasks.where((t) => t.status.index == 2).length;
    final pending =
        tasks.where((t) => t.status.index == 0).length;
    final inProgress =
        tasks.where((t) => t.status.index == 1).length;
    final cancelled =
        tasks.where((t) => t.status.index == 3).length;

    final total = tasks.length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rendimiento de tareas',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: completed.toDouble(),
                    title: 'Completadas\n$completed',
                    color: Colors.green,
                    radius: 60,
                    titleStyle: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: pending.toDouble(),
                    title: 'Pendientes\n$pending',
                    color: Colors.orange,
                    radius: 60,
                    titleStyle: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: inProgress.toDouble(),
                    title: 'En curso\n$inProgress',
                    color: Colors.blue,
                    radius: 60,
                    titleStyle: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  if (cancelled > 0)
                    PieChartSectionData(
                      value: cancelled.toDouble(),
                      title: 'Canceladas\n$cancelled',
                      color: Colors.red,
                      radius: 60,
                      titleStyle: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          SizedBox(height: 24),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Tasa de finalización',
                      style: theme.textTheme.titleSmall),
                  SizedBox(height: 8),
                  Text(
                    '${total > 0 ? ((completed / total) * 100).toStringAsFixed(0) : 0}%',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: total > 0 ? completed / total : 0,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.green,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  SizedBox(height: 8),
                  Text('$completed de $total tareas completadas'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
