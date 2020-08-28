//import 'package:dojov0/bloc_provider.dart';
//
//class SQLBloc extends Bloc
//{
//RecordsBloc()
//{
//recordCollection = new RecordCollection();
//rEventController.stream.asBroadcastStream().listen(mapEventToState);
//}
//
//// DATAMODEL STUFF
//RecordCollection recordCollection;
//
//final rStateController = StreamController<RecordCollection>.broadcast();
//StreamSink<RecordCollection> get _inRecordCollection => rStateController.sink;
//Stream<RecordCollection> get rStream => rStateController.stream;
//
//final rEventController = StreamController<RecordsModelEvent>();
//StreamSink<RecordsModelEvent> get rEventSink => rEventController.sink;
//
//void mapEventToState(BlocEvent event) {
//if (!(event is RecordsModelEvent)) return;
//
//if(event is RecordsLoadedEvent)
//{
//this.recordCollection = event.recordCollection;
//}
//
//if(event is RecordsWipeEvent)
//{
//recordCollection.records.clear();
//}
//
//if(event is RecordAddEvent)
//{
//recordCollection.AddRecord(event.r);
//}
//
//_inRecordCollection.add(recordCollection);
//}
//
//
//void dispose()
//{
//rStateController.close();
//rEventController.close();
//}
//
//}