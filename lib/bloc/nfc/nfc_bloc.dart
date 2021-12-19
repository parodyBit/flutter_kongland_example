import 'dart:async';

import 'package:bloc/bloc.dart';

abstract class NfcEvent {}
class NfcReadEvent extends NfcEvent {}

class NfcException {
  final int code;
  final String message;
  NfcException({
    required this.code,
    required this.message,
  });

}
abstract class NfcState {}
class ReadyState extends NfcState {}
class ReadingState extends NfcState {}
class BusyState extends NfcState {}
class ErrorState extends NfcState {}
class BlocNfc extends Bloc<NfcEvent, NfcState>{
  BlocNfc(NfcState initialState) : super(initialState);
  get initialState => ReadyState();


  @override
  Stream<NfcState> mapEventToState(NfcEvent event) async* {
    try {
      if(event is ReadyState){

      }
      else if(event is NfcReadEvent){
        yield ReadingState();

      }
    } on NfcException catch (e) {
      yield ErrorState();
    }
  }
}