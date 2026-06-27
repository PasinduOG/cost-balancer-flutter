import 'package:flutter/material.dart';
import 'package:cost_balancer_app/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<String> _balanceFuture;
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _balanceFuture = ApiService.getBalance();
    _historyFuture = ApiService.getTransactionHistory();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: Colors.green[800],
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Total Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'TOTAL BALANCE',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<String>(
                        future: _balanceFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(
                              color: Colors.white,
                            );
                          }
                          String balance = snapshot.data ?? "0.00";
                          return Text(
                            '$balance LKR',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                FutureBuilder<List<dynamic>>(
                  future: _historyFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    List<dynamic> history = snapshot.data ?? [];

                    var latestExpense = history.firstWhere(
                      (tx) => tx['category_type'] == 'EXPENSE',
                      orElse: () => null,
                    );

                    String latestExpenseAmount = latestExpense != null
                        ? '${latestExpense['amount']} LKR'
                        : '0.00 LKR';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Latest Expense & History Info Cards
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.green[700],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Latest Expense',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      latestExpenseAmount,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.green[700],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Total Records',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${history.length} Transactions',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Income and Expenses',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        history.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text('No transaction records found'),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: history.length,
                                itemBuilder: (context, index) {
                                  var tx = history[index];
                                  bool isExpense =
                                      tx['category_type'] == 'EXPENSE';

                                  String rawDate = tx['transaction_date'] ?? '';
                                  String formattedDate = '';

                                  String rawTime = tx['transaction_time'] ?? '';
                                  String formattedTime = 'No Time';

                                  if (rawDate.isNotEmpty) {
                                    try {
                                      DateTime dt = DateTime.parse(
                                        rawDate,
                                      ).toLocal();
                                      formattedDate =
                                          "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
                                    } catch (e) {
                                      formattedDate = rawDate.contains('T')
                                          ? rawDate.split('T')[0]
                                          : rawDate;
                                    }
                                  }

                                  if (rawTime.isNotEmpty &&
                                      rawTime.contains(':')) {
                                    try {
                                      List<String> timeParts = rawTime.split(
                                        ':',
                                      );
                                      int hour = int.parse(timeParts[0]);
                                      int minute = int.parse(timeParts[1]);
                                      String amPm = hour >= 12 ? 'PM' : 'AM';
                                      hour = hour % 12;
                                      if (hour == 0) hour = 12;

                                      formattedTime =
                                          "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm";
                                    } catch (e) {
                                      formattedTime = rawTime;
                                    }
                                  }

                                  return _buildTransactionCard(
                                    tx['note'] ?? 'No Note',
                                    tx['user_name'] ?? 'Unknown',
                                    '${tx['amount']} LKR',
                                    isExpense,
                                    formattedDate,
                                    formattedTime,
                                  );
                                },
                              ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    String title,
    String user,
    String amount,
    bool isExpense,
    String date,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isExpense ? Colors.red[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                isExpense ? 'Expenser: $user' : 'Deposit by: $user',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                'Date: $date  •  Time: $time',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black45,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isExpense ? Colors.red[900] : Colors.green[900],
                ),
              ),
              Icon(
                isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                size: 14,
                color: isExpense ? Colors.red[900] : Colors.green[900],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
