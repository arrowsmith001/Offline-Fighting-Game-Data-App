import 'dart:async';

import 'package:dojov01/data_model.dart';
import 'package:dojov01/records_model.dart';

import 'add_page_bloc.dart';
import 'add_page_state.dart';
import 'bloc_provider.dart';


abstract class RecordsModelEvent extends BlocEvent {}
class ToggleAscEvent extends RecordsModelEvent{ToggleAscEvent(this.g); Game g;}
class GameViewOrderChangeEvent extends RecordsModelEvent{
  Game g;
  String orderType;
  GameViewOrderChangeEvent(this.g, this.orderType);
}
class ChangeGameViewState extends RecordsModelEvent{
  bool advance;
  String gameViewState;
  ChangeGameViewState(this.advance);
  ChangeGameViewState.to(this.gameViewState);
}
class SelectionMadeEvent extends RecordsModelEvent{
  Game g;
  Map<String, dynamic> map;
  String type;
  SelectionMadeEvent(this.g,this.map,this.type);
}
class RecordsModelNudge extends RecordsModelEvent {}
class RecordsLoadedEvent extends RecordsModelEvent{
  RecordsLoadedEvent(this.records);
  List<Record> records;
}
class ExploreStartedEvent extends RecordsModelEvent{}
class QueryAllEvent extends RecordsModelEvent{}
class RecordAddEvent extends RecordsModelEvent {
  Record r;
  RecordAddEvent(this.r);
}
class RecordRemoveEvent extends RecordsModelEvent {
  Record r;
  RecordRemoveEvent(this.r);
}
class RecordsWipeEvent extends RecordsModelEvent{}

class RecordsBloc extends Bloc
{
  RecordsBloc()
  {
    recordCollection = new RecordCollection(rEventSink);
    rEventController.stream.asBroadcastStream().listen(mapEventToState);

    //recordCollection.database.changefeed.asBroadcastStream().listen((event) {mapDatabaseEventToState(event);});
  }

  // DATAMODEL STUFF
  RecordCollection recordCollection;

  final rStateController = StreamController<RecordCollection>.broadcast();
  StreamSink<RecordCollection> get _inRecordCollection => rStateController.sink;
  Stream<RecordCollection> get rStream => rStateController.stream;

  final rEventController = StreamController<RecordsModelEvent>();
  StreamSink<RecordsModelEvent> get rEventSink => rEventController.sink;


  void mapEventToState(BlocEvent event) async {
    if (!(event is RecordsModelEvent)) return;

    if(event is RecordsLoadedEvent)
      {
        await this.recordCollection.AddRecords(event.records);
      }

    if(event is ExploreStartedEvent)
      {
        // no longer important
      }

    if(event is QueryAllEvent) // Custom event
      {
        this.recordCollection.QueryAll();
      }

    if(event is RecordsWipeEvent)
    {
      recordCollection.ClearRecords();
    }

    if(event is RecordRemoveEvent)
    {
      recordCollection.RemoveRecord(event.r);
    }

    if(event is RecordAddEvent)
      {
        await recordCollection.AddRecord(event.r);
      }

    if(event is SelectionMadeEvent)
      {
        this.recordCollection.SelectAndRefresh(event.g, event.map, event.type);
      }

    if(event is ChangeGameViewState)
      {
        this.recordCollection.ChangeGameViewState(event.gameViewState, event.advance);
      }

    if(event is GameViewOrderChangeEvent)
      {
        this.recordCollection.ChangeGameViewOrder(event.g, event.orderType);
      }

    if(event is ToggleAscEvent) {this.recordCollection.ToggleAsc(event.g);}

    _inRecordCollection.add(recordCollection);
  }


  void dispose()
  {
    rStateController.close();
    rEventController.close();
  }

}
