import 'dart:async';
import 'dart:convert';

import 'package:dojov01/add_page_bloc.dart';
import 'package:dojov01/data_bloc.dart';
import 'package:dojov01/data_model.dart';
import 'package:dojov01/records_bloc.dart';

import 'add_page_state.dart';

abstract class BlocEvent{}

abstract class Bloc{

  BlocProvider BLOCS;

  void mapEventToState(BlocEvent event);
  void dispose();
}

class BlocProvider
{
  static BlocProvider _blocProvider;

  DataModel loadedDataModel;

  DataBloc d; // Data Bloc - governs entire data model
  AddPageBloc ap; // Add Page State Bloc - governs state of Add Page
  RecordsBloc r; // Records Bloc - governs record analysis model

  BlocProvider._internal()
  {
    d = DataBloc();
    ap = AddPageBloc();
    r = RecordsBloc();
  }

  static BlocProvider get()
  {
    if(_blocProvider == null) {
      _blocProvider = BlocProvider._internal();
    }
    return _blocProvider;
  }


}
