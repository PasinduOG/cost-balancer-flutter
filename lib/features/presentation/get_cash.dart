import 'package:flutter/material.dart';
import 'package:cost_balancer_app/services/api_service.dart';

class GetCashScreen extends StatefulWidget {
  const GetCashScreen({super.key});

  @override
  State<GetCashScreen> createState() => _GetCashScreenState();
}

class _GetCashScreenState extends State<GetCashScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isLoading = false;
  List<dynamic> _categories = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    List<dynamic> categories = await ApiService.getCategories('EXPENSE');

    print('--- EXPENSE CATEGORIES --- : $categories');

    setState(() {
      _categories = categories;
      if (_categories.isNotEmpty) {
        _selectedCategoryId = _categories[0]['id'] ?? _categories[0]['category_id'] ?? _categories[0]['categoryId'];
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitData() async {
    if (_descriptionController.text.isEmpty || _amountController.text.isEmpty || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all details.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    double amount = double.parse(_amountController.text);

    bool success = await ApiService.addTransaction(_selectedCategoryId!, amount, _descriptionController.text);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully!')),
      );
      _descriptionController.clear();
      _amountController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong, please try again.')),
      );
    }
  }

  void _showAddCategoryDialog() {
    final TextEditingController categoryNameController = TextEditingController();
    bool isAddingCategory = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Add New Expense Category'),
                content: TextField(
                  controller: categoryNameController,
                  decoration: const InputDecoration(hintText: 'E.g., Food, Travel, Bills'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: isAddingCategory ? null : () async {
                      if (categoryNameController.text.isNotEmpty) {
                        setDialogState(() => isAddingCategory = true);

                        bool success = await ApiService.addCategory(categoryNameController.text, 'EXPENSE');

                        setDialogState(() => isAddingCategory = false);

                        if (success) {
                          Navigator.of(ctx).pop();
                          _loadCategories();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to add category.')),
                          );
                        }
                      }
                    },
                    child: isAddingCategory
                        ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save', style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GET CASH', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _categories.isEmpty
                        ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text('Loading categories...'),
                    )
                        : DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedCategoryId,
                        isExpanded: true,
                        hint: const Text('Select Category'),
                        items: _categories.map((cat) {
                          return DropdownMenuItem<int>(
                            value: cat['id'] ?? cat['category_id'] ?? cat['categoryId'],
                            child: Text(cat['name'] ?? 'Unknown'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: _showAddCategoryDialog,
                    tooltip: 'Add New Category',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'DESCRIPTION OF EXPENSE',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'AMOUNT',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isLoading ? null : _submitData,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('GET CASH FROM WALLET', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}