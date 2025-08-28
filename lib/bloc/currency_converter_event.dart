part of 'currency_converter_bloc.dart';

class CurrencyConverterEvent {
  final String fromCurrency;
  final String toCurrency;
  final double amount;

  const CurrencyConverterEvent({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
  });
}
