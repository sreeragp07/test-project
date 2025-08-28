import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testproject/models/currency_conversion_model/currency_conversion_model.dart';
import 'package:testproject/repository/apiservices.dart';

part 'currency_converter_event.dart';
part 'currency_converter_state.dart';

class CurrencyConverterBloc
    extends Bloc<CurrencyConverterEvent, CurrencyConverterState> {
  final ApiServices apiServices;

  CurrencyConverterBloc(this.apiServices) : super(CurrencyConverterInitial()) {
    on<CurrencyConverterEvent>(_getConversionRate);
  }

  Future<void> _getConversionRate(CurrencyConverterEvent event, emit) async {
    emit(CurrencyConverterLoading());
    try {
      CurrencyConversionModel? response = await apiServices.convert(
        event.fromCurrency,
        event.toCurrency,
        event.amount,
      );
      if (response != null) {
        print('----Successs_with_data-----');
        print('converted amount : ${response.convertedAmount}');
        emit(CurrencyConverterSuccess(result: response));
      } else {
        print('----Failed-----');
        emit(CurrencyConverterFailure());
      }
    } catch (e) {
      print('*********Failed********');
      emit(CurrencyConverterFailure());
      throw Exception('Error caught : $e');
    }
  }
}
