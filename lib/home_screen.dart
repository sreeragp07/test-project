import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:testproject/bloc/currency_converter_bloc.dart';
import 'package:testproject/login_screen.dart';
import 'package:testproject/repository/apiservices.dart';
import 'package:testproject/widgets/animated_card_widget.dart';
import 'package:testproject/widgets/custom_snack_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController amountController = TextEditingController();
  final NumberFormat formatter = NumberFormat.decimalPattern(); // adds commas

  String? fromCurrency;
  String? toCurrency;
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
    final nav = Navigator.of(context);
    return BlocProvider(
      create: (context) => CurrencyConverterBloc(apiServices),
      child: BlocBuilder<CurrencyConverterBloc, CurrencyConverterState>(
        builder: (context, state) {
          double topPadding = MediaQuery.of(context).padding.top;
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: topPadding),
                    const Text(
                      "Currency Converter",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Row with From, Swap, To
                    Card(
                      margin: EdgeInsets.all(0),
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _currencyBox(
                                    "From",
                                    fromCurrency,
                                    true,
                                  ),
                                ),
                                IconButton(
                                  onPressed: swapCurrencies,
                                  icon: const Icon(Icons.swap_horiz, size: 28),
                                  tooltip: "Swap",
                                ),
                                Expanded(
                                  child: _currencyBox("To", toCurrency, false),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Amount field with live formatting
                            TextField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              onChanged: _onAmountChanged,
                              decoration: InputDecoration(
                                hintText: "Amount",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                fillColor: Colors.white,
                                filled: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Convert Button
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          convert(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                          shadowColor: Colors.black.withValues(alpha: 0.2),
                        ),
                        child:
                            (state is CurrencyConverterLoading)
                                ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  "Convert",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    (state is CurrencyConverterSuccess)
                        ? Center(
                          child: AnimatedSwitcher(
                            duration: Duration(microseconds: 500),
                            child: AnimatedResultCard(
                              amount: state.result?.convertedAmount ?? 0.0,
                              currency: state.result?.targetCurrency ?? '',
                            ),
                          ),
                        )
                        : SizedBox.shrink(),
                    const Spacer(),
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          await FirebaseAuth.instance
                              .signOut(); // Sign out user

                          if (!mounted) return; // ensures widget is still in tree
                          // Navigate back to Login screen

                          nav.pushReplacement(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const LoginPage(),
                              transitionsBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                                child,
                              ) {
                                // Fade + Slide from right
                                final fadeAnim = Tween<double>(
                                  begin: 0,
                                  end: 1,
                                ).animate(animation);
                                final slideAnim = Tween<Offset>(
                                  begin: const Offset(1, 0), // from right
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOut,
                                  ),
                                );

                                return FadeTransition(
                                  opacity: fadeAnim,
                                  child: SlideTransition(
                                    position: slideAnim,
                                    child: child,
                                  ),
                                );
                              },
                              transitionDuration: const Duration(
                                milliseconds: 500,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void convert(BuildContext context) {
    if (fromCurrency == null) {
      showCustomSnackBar(context, "Please select From currency", false);
      return;
    }
    if (toCurrency == null) {
      showCustomSnackBar(context, "Please select To currency", false);
      return;
    }
    if (amountController.text.trim().isEmpty) {
      showCustomSnackBar(context, "Please enter the amount", false);
      return;
    }
    context.read<CurrencyConverterBloc>().add(
      CurrencyConverterEvent(
        fromCurrency: fromCurrency ?? '',
        toCurrency: toCurrency ?? '',
        amount: double.parse(amountController.text.replaceAll(",", "")),
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
            maxHeight: MediaQuery.of(context).size.height * 0.7, // Max 70%
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[350],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search currency...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.white,
                        filled: true,
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
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          value ?? label, // If null, show "From" or "To"
          style: TextStyle(color: value == null ? Colors.grey : Colors.black),
        ),
      ),
    );
  }
}
