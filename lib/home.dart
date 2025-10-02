import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_expense_app/add.dart';
import 'package:flutter_expense_app/home.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> expenseList = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('expenses');

    if (savedData != null) {
      setState(() {
        expenseList = List<Map<String, dynamic>>.from(
          (jsonDecode(savedData) as List).map(
            (item) => {
              "title": item['title'],
              "amount": item['amount'],
              "category": item['category'],
              "date": DateTime.parse(item['date']),
            },
          ),
        );
      });
    }
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> saveList = expenseList
        .map(
          (e) => {
            "title": e['title'],
            "amount": e['amount'],
            "category": e['category'],
            "date": (e['date'] as DateTime).toIso8601String(),
          },
        )
        .toList();

    await prefs.setString('expenses', jsonEncode(saveList));
  }

  void addExpense(Map<String, dynamic> expense) {
    setState(() {
      expenseList.add(expense);
    });
    _saveExpenses();
  }

  void deleteExpense(int index) {
    setState(() {
      expenseList.removeAt(index);
    });
    _saveExpenses();
  }

  // Get chart data for categories
  List<ChartData> _getChartData() {
    final Map<String, double> categoryTotals = {};

    for (var expense in expenseList) {
      final category = expense['category'] ?? 'Other';
      final amount = double.tryParse(expense['amount'].toString()) ?? 0.0;
      
      categoryTotals.update(
        category,
        (value) => value + amount,
        ifAbsent: () => amount,
      );
    }

    return categoryTotals.entries.map((entry) {
      return ChartData(
        entry.key,
        entry.value,
        _getCategoryColor(entry.key),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'FOOD':
        return Colors.orange;
      case 'Leisure':
        return Colors.purple;
      case 'Travel':
        return Colors.blue;
      case 'Flutter Dev':
        return Colors.green;
      case 'cinema':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  double get _totalExpenses {
    return expenseList.fold(0.0, (sum, expense) {
      return sum + (double.tryParse(expense['amount'].toString()) ?? 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense App',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 32, 9, 72),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_outlined),
            color: Colors.white,
            onPressed: () async {
              final newExpense = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Add()),
              );

              if (newExpense != null) {
                addExpense(newExpense);
              }
            },
          ),
        ],
      ),
      body: expenseList.isEmpty
          ? const Center(
              child: Text(
                'No expenses yet. Click + to add.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : Column(
              children: [
                // Chart Section
                _buildChartSection(),
                
                // Recent Expenses Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Expenses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total: \$${_totalExpenses.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Expenses List
                Expanded(
                  child: _buildExpenseList(),
                ),
              ],
            ),
    );
  }

  Widget _buildChartSection() {
    final List<ChartData> chartData = _getChartData();
    
    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Expenses by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: chartData.isEmpty
                    ? const Center(
                        child: Text('No data to display'),
                      )
                    : SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          labelRotation: -45,
                          majorGridLines: const MajorGridLines(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
                          majorGridLines: const MajorGridLines(width: 1),
                        ),
                        series: <CartesianSeries<ChartData, String>>[
                          ColumnSeries<ChartData, String>(
                            dataSource: chartData,
                            xValueMapper: (ChartData data, _) => data.category,
                            yValueMapper: (ChartData data, _) => data.amount,
                            color: Colors.blue,
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.auto,
                              textStyle: TextStyle(fontSize: 12),
                            ),
                            enableTooltip: true,
                            width: 0.6,
                            spacing: 0.2,
                          ),
                        ],
                        tooltipBehavior: TooltipBehavior(enable: true),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: expenseList.length,
      itemBuilder: (context, index) {
        final expense = expenseList[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getCategoryColor(expense['category']).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(expense['category']),
                color: _getCategoryColor(expense['category']),
                size: 20,
              ),
            ),
            title: Text(
              expense['title'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              DateFormat('MMM d, yyyy').format(expense['date']),
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "\$${expense['amount']}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                Text(
                  expense['category'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            onLongPress: () {
              _showDeleteDialog(index);
            },
          ),
        );
      },
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: Text('Are you sure you want to delete "${expenseList[index]['title']}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteExpense(index);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'FOOD':
        return Icons.fastfood;
      case 'Leisure':
        return Icons.movie;
      case 'Travel':
        return Icons.flight;
      case 'Flutter Dev':
        return Icons.code;
      case 'cinema':
        return Icons.theaters;
      default:
        return Icons.wallet;
    }
  }
}

class ChartData {
  final String category;
  final double amount;
  final Color color;

  ChartData(this.category, this.amount, this.color);
}