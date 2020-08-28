import 'dart:convert';
import 'dart:io';

import 'package:dojov01/bloc_provider.dart';
import 'package:dojov01/data_bloc.dart';
import 'package:dojov01/main.dart';
import 'package:dojov01/records_bloc.dart';
import 'package:dojov01/records_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

import 'data_model.dart';

class StorageManager
{
  static StorageManager _storageManager;
  Storage storage;

  static StorageManager get()
  {
    if(_storageManager == null) { _storageManager = StorageManager._internal();}
    return _storageManager;
  }

  StorageManager._internal()
  {
    BlocProvider.get(); // Initialise BlocProvider instance

    this.storage = Storage();

    storage.readData(Storage.FILENAME_DATAMODEL).then((value) =>
        PushDataModelFromJson(value)
    );
    storage.readData(Storage.FILENAME_PRESETS).then((value) =>
        PushPresetsFromJson(value)
    );
    storage.readData(Storage.FILENAME_RECORDS).then((value) =>
        PushRecordsFromJson(value)
    );
  }

  void saveDataModel() {
    String json = jsonEncode(BlocProvider.get().d.dataModel.toJson());
    print("saving (dm): " + json);
    storage.writeData(json, Storage.FILENAME_DATAMODEL);
  }

  void saveRecords()
  {
    String json = jsonEncode(BlocProvider.get().r.recordCollection.records);
    printWrapped("saving (r): " + json);
    storage.writeData(json, Storage.FILENAME_RECORDS);
  }

  void savePresets()
  {
//    String json = jsonEncode(BlocProvider.get().r.recordCollection.records);
//    print("saving (r): " + json);
//    storage.writeData(json, Storage.FILENAME_RECORDS);
  }

  void saveAll()
  {
    try{
      saveDataModel();
    }catch(e){ print('Save DM ERROR: ' + e.toString()); }
    try{
      saveRecords();
    }catch(e){ print('Save R ERROR: ' + e.toString()); }
    try{
      savePresets();
    }catch(e){ print('Save P ERROR: ' + e.toString()); }
  }

  void PushPresetsFromJson(String value) {}

  void PushRecordsFromJson(String value)
  {
    print("Attempting to load R value: " + value);

    List<Record> records = [];

      try{records = (json.decode(value) as List).map((i) => Record.fromJson(i)).toList();}catch(e){print('ERROR LOADING RECORDS: '+e.toString());}

    BlocProvider.get().r.rEventSink.add(RecordsLoadedEvent(records)); // OLD WAY

  }

  void PushDataModelFromJson(String value) {

    print("Attempting to load DM value: " + value);

    DataModel dataModel;

    try { dataModel = DataModel.fromJson(jsonDecode(value));  }
    catch(e) { print("ERROR in PushDataModelFromJson: "+e.toString());
    dataModel = DataModel();
    }

    BlocProvider.get().d.dataEventSink.add(DataModelLoadedEvent(dataModel));

  }

  void eraseAll() {
    storage.writeData('', Storage.FILENAME_RECORDS);
    storage.writeData('', Storage.FILENAME_PRESETS);
    storage.writeData('', Storage.FILENAME_DATAMODEL);
  }


}

class Storage
{
  static String FILENAME_DATAMODEL = 'dm';
  static String FILENAME_RECORDS = 'rec';
  static String FILENAME_PRESETS = 'pre';

  Future<String> get localPath async
  {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> localFile(String fileName) async
  {
    final path = await localPath;
    return File('$path/$fileName.txt');
  }

  Future<String> readData(String fileName) async
  {
    try {

      final file = await localFile(fileName);
      String body = await file.readAsString();

      return body;
    }catch(e){ print("ERROR in readData ($fileName): "+e.toString());}
  }

  Future<File> writeData(String data, String fileName) async
  {
    try {

      final file = await localFile(fileName);
      return file.writeAsString("$data");

    }catch(e){ print("ERROR in writeData ($fileName): "+e.toString());}
  }

}