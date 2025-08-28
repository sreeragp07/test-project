import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:testproject/bloc/currency_converter_bloc.dart';
import 'package:testproject/repository/apiservices.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController amountController = TextEditingController();
  final NumberFormat formatter = NumberFormat.decimalPattern(); // adds commas

  String? fromCurrency = "USD";
  String? toCurrency = "INR";
  double? convertedAmount;

  // Mock rates
  final Map<String, double> rates = {
    "USD": 83.2, // US Dollar
    "EUR": 90.5, // Euro
    "GBP": 106.8, // British Pound
    "JPY": 0.56, // Japanese Yen
    "AUD": 55.1, // Australian Dollar
    "CAD": 61.2, // Canadian Dollar
    "CHF": 94.3, // Swiss Franc
    "CNY": 11.5, // Chinese Yuan
    "AED": 22.7, // UAE Dirham
    "SAR": 22.2, // Saudi Riyal
    "SGD": 61.5, // Singapore Dollar
    "NZD": 50.8, // New Zealand Dollar
    "ZAR": 4.6, // South African Rand
    "THB": 2.3, // Thai Baht
    "INR": 1.0, // Indian Rupee (base)
  };

  void swapCurrencies() {
    if (fromCurrency != null && toCurrency != null) {
      setState(() {
        final temp = fromCurrency;
        fromCurrency = toCurrency;
        toCurrency = temp;
      });
    }
  }

  // Format live input
  void _onAmountChanged(String value) {
    String clean = value.replaceAll(",", "");
    if (clean.isEmpty) return;

    double? number = double.tryParse(clean);
    if (number != null) {
      String formatted = formatter.format(number);

      // avoid infinite loop
      amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ApiServices apiServices = ApiServices();
    return BlocProvider(
      create: (context) => CurrencyConverterBloc(apiServices),
      child: BlocBuilder<CurrencyConverterBloc, CurrencyConverterState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Currency Converter"),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row with From, Swap, To
                  Row(
                    children: [
                      Expanded(child: _currencyBox("From", fromCurrency, true)),
                      IconButton(
                        onPressed: swapCurrencies,
                        icon: const Icon(Icons.swap_horiz, size: 28),
                        tooltip: "Swap",
                      ),
                      Expanded(child: _currencyBox("To", toCurrency, false)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Amount field with live formatting
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    onChanged: _onAmountChanged,
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Convert Button
                  Center(
                    child: ElevatedButton(
                      onPressed:
                          (fromCurrency == null || toCurrency == null)
                              ? null
                              : () {
                                context.read<CurrencyConverterBloc>().add(
                                  CurrencyConverterEvent(
                                    fromCurrency: fromCurrency ?? '',
                                    toCurrency: toCurrency ?? '',
                                    amount: double.parse(
                                      amountController.text.replaceAll(",", ""),
                                    ),
                                  ),
                                );
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Convert"),
                    ),
                  ),
                  const SizedBox(height: 20),

                  (state is CurrencyConverterSuccess)
                      ? Card(
                        margin: EdgeInsets.all(12),
                        child: Text(
                          "Converted Amount: ${state.result?.convertedAmount?.toStringAsFixed(2) ?? '0.00'} ${state.result?.targetCurrency ?? ''}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void showCurrencyPicker(bool isFrom) {
    TextEditingController searchController = TextEditingController();
    List<String> filteredCurrencies = rates.keys.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7, // 👈 Max 70%
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Search currency...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          filteredCurrencies =
                              rates.keys
                                  .where(
                                    (c) => c.toLowerCase().contains(
                                      value.toLowerCase(),
                                    ),
                                  )
                                  .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredCurrencies.length,
                        itemBuilder: (context, index) {
                          String currency = filteredCurrencies[index];
                          return ListTile(
                            title: Text(currency),
                            onTap: () {
                              setState(() {
                                if (isFrom) {
                                  fromCurrency = currency;
                                } else {
                                  toCurrency = currency;
                                }
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // UI helper for currency box
  Widget _currencyBox(String label, String? value, bool isFrom) {
    return GestureDetector(
      onTap: () {
        showCurrencyPicker(isFrom);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(value ?? "$label Currency"),
      ),
    );
  }
}
