import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/app_provider.dart';
import '../../models/finance_record.dart';
import '../../widgets/empty_state.dart';
import 'finance_form_screen.dart';

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat =
        NumberFormat.currency(symbol: 'USD ', decimalDigits: 2);

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final records = provider.finances;

        final totalIncome = records
            .where((r) => r.type == TransactionType.income)
            .fold<double>(0, (sum, r) => sum + r.amount);
        final totalExpense = records
            .where((r) => r.type == TransactionType.expense)
            .fold<double>(0, (sum, r) => sum + r.amount);
        final balance = totalIncome - totalExpense;

        return Scaffold(
          appBar: AppBar(
            title: Text('Finanzas'),
            actions: [
              TextButton.icon(
                onPressed: () => _showForm(context),
                icon: Icon(Icons.add, color: Colors.white),
                label: Text('Nuevo',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          body: records.isEmpty
              ? EmptyState(
                  icon: Icons.account_balance,
                  title: 'Sin registros financieros',
                  subtitle: 'Agrega ingresos y gastos',
                  actionLabel: 'Agregar registro',
                  onAction: () => _showForm(context),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.loadAll(),
                  child: ListView(
                    padding: EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'Balance total',
                                style: theme.textTheme.titleSmall,
                              ),
                              SizedBox(height: 8),
                              Text(
                                currencyFormat.format(balance),
                                style: theme.textTheme.headlineMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: balance >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _amountCard(
                                      'Ingresos',
                                      currencyFormat.format(totalIncome),
                                      Colors.green,
                                      Icons.arrow_upward,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _amountCard(
                                      'Gastos',
                                      currencyFormat.format(totalExpense),
                                      Colors.red,
                                      Icons.arrow_downward,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (totalIncome > 0 || totalExpense > 0) ...[
                        SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text('Resumen',
                                    style: theme.textTheme.titleSmall),
                                SizedBox(height: 16),
                                SizedBox(
                                  height: 200,
                                  child: PieChart(
                                    PieChartData(
                                      sections: [
                                        if (totalIncome > 0)
                                          PieChartSectionData(
                                            value: totalIncome,
                                            title:
                                                'Ingresos\n${((totalIncome / (totalIncome + totalExpense)) * 100).toStringAsFixed(0)}%',
                                            color: Colors.green,
                                            radius: 60,
                                            titleStyle: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                        if (totalExpense > 0)
                                          PieChartSectionData(
                                            value: totalExpense,
                                            title:
                                                'Gastos\n${((totalExpense / (totalIncome + totalExpense)) * 100).toStringAsFixed(0)}%',
                                            color: Colors.red,
                                            radius: 60,
                                            titleStyle: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 16),
                      Text('Historial de transacciones',
                          style: theme.textTheme.titleSmall),
                      SizedBox(height: 8),
                      ...records.map((r) => _recordCard(context, r)),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _amountCard(
      String label, String amount, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 4),
          Text(amount,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 13)),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _recordCard(BuildContext context, FinanceRecord r) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat =
        NumberFormat.currency(symbol: 'USD ', decimalDigits: 2);
    final isIncome = r.type == TransactionType.income;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isIncome ? Colors.green : Colors.red).withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIncome ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(r.description,
            style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
            '${r.category} | ${dateFormat.format(r.date)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(r.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            Text(r.paymentMethod,
                style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        onLongPress: () => _showForm(context, record: r),
      ),
    );
  }

  void _showForm(BuildContext context, {FinanceRecord? record}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FinanceFormScreen(record: record),
      ),
    );
  }
}
