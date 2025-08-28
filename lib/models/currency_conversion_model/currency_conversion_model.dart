class CurrencyConversionModel {
  final String base;
  final double amount;
  final double? convertedAmount;
  final double rate;
  final String targetCurrency;

  CurrencyConversionModel({
    required this.base,
    required this.amount,
    required this.convertedAmount,
    required this.rate,
    required this.targetCurrency,
  });

  factory CurrencyConversionModel.fromJson(Map<String, dynamic> json) {
    final resultMap = json['result'] as Map<String, dynamic>;
    final targetCurrency = resultMap.keys.firstWhere((k) => k != 'rate');
    final convertedAmount = (resultMap[targetCurrency] as num).toDouble();
    final rate = (resultMap['rate'] as num).toDouble();

    return CurrencyConversionModel(
      base: json['base'],
      amount: double.parse(json['amount']),
      convertedAmount: convertedAmount,
      rate: rate,
      targetCurrency: targetCurrency,
    );
  }
}
