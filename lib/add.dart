import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class Add extends StatefulWidget {
  const Add({super.key});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final _titleController = TextEditingController(text: 'burger');
  final _amountController = TextEditingController(text: '10.0');
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'FOOD';

  final List<String> _categories = ['FOOD', 'Leisure', 'Travel', 'OTHER'];

   

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                suffixText: '${_titleController.text.length}/50',
              ),
              maxLength: 50,
              onChanged: (text) => setState(() {}),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$',
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: InputDecoration(
                      labelText: DateFormat('M/d/yyyy').format(_selectedDate),
                      suffixIcon: const Icon(Icons.calendar_month_rounded),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'title': _titleController.text,
                      'amount': _amountController.text,
                      'date': _selectedDate,
                      'category': _selectedCategory,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[100],
                    foregroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Submit Expense'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2026),
    );
  // Future<void> submitExpense()async{
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setStringList(key, value)
  // }

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}



