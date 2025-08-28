part of 'currency_converter_bloc.dart';



@immutable
sealed class CurrencyConverterState {}

final class CurrencyConverterInitial extends CurrencyConverterState {}

final class CurrencyConverterLoading extends CurrencyConverterState {}

final class CurrencyConverterSuccess extends CurrencyConverterState {
  final CurrencyConversionModel? result;

  CurrencyConverterSuccess({required this.result});
}

final class CurrencyConverterFailure extends CurrencyConverterState {}