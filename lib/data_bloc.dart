import 'dart:async';

import 'package:dojov01/data_model.dart';
import 'package:dojov01/data_model.dart';
import 'package:dojov01/records_bloc.dart';

import 'add_page_bloc.dart';
import 'add_page_state.dart';
import 'bloc_provider.dart';
import 'data_model.dart';

abstract class DataEvent extends BlocEvent {}
class DataModelLoadedEvent extends DataEvent{
  DataModelLoadedEvent(this.dataModel);
  DataModel dataModel;

}
class AddDummyDataEvent extends DataEvent{}
class DataWipeEvent extends DataEvent{}
class GenerateFakeRecords extends DataEvent{
  GenerateFakeRecords(this.n);
  int n;
}
class ResetSelectionsEvent extends DataEvent{}
abstract class SelectedEvent extends DataEvent{}
class GameSelectedEvent extends SelectedEvent {
  GameSelectedEvent(int index){this.index = index;}
  int index;
}
class FormatSelectedEvent extends SelectedEvent {
  FormatSelectedEvent(int index){this.index = index;}
  int index;
}
class PlayerSelectedEvent extends SelectedEvent {
  PlayerSelectedEvent(int index){this.index = index;}
  int index;
}
class FighterSelectedEvent extends SelectedEvent {
  FighterSelectedEvent(this.fighterIndex, this.player, this.variantIndex);
  int fighterIndex;
  int variantIndex;
  Player player;
}
class GamesEvent extends DataEvent{
  GamesEvent(int gamesEventType, Game game) {this.gamesEventType = gamesEventType; this.game = game;}
  static int ADD_GAME = 1;
  static int REMOVE_GAME = -1;
  int gamesEventType;
  Game game;
}
class FormatsEvent extends DataEvent{
  FormatsEvent(int formatsEventType, Format format) {this.formatsEventType = formatsEventType; this.format = format;}
  static int ADD_FORMAT = 1;
  static int REMOVE_FORMAT = -1;
  int formatsEventType;
  Format format;
}
class PlayersEvent extends DataEvent{
  PlayersEvent(int playersEventType, Player player) {this.playersEventType = playersEventType; this.player = player;}
  static int ADD_PLAYER = 1;
  static int REMOVE_PLAYER = -1;
  int playersEventType;
  Player player;
}
class FightersEvent extends DataEvent{
  FightersEvent(int fightersEventType, Fighter fighter) {this.fightersEventType = fightersEventType; this.fighter = fighter;}
  static int ADD_FIGHTER = 1;
  static int REMOVE_FIGHTER = -1;
  int fightersEventType;
  Fighter fighter;
}
class RecordsEvent extends DataEvent{
  static int PODIUM_REORDER = 0;
  static int PODIUM_UP = 1;
  static int PODIUM_DOWN = -1;
  static int PODIUM_INDEX_TOGGLE = 99;
  Object obj;
  int eventType;
  RecordsEvent(this.obj, this.eventType);
}


class DataBloc extends Bloc
{
  static int RECORD_GENERATION_NUMBER = 100;

  DataBloc()
  {
    dataModel = new DataModel();
    dmEventController.stream.asBroadcastStream().listen(mapEventToState);
  }

  // DATAMODEL STUFF
  DataModel dataModel;

  final dmStateController = StreamController<DataModel>.broadcast();
  StreamSink<DataModel> get _inDataModel => dmStateController.sink;
  Stream<DataModel> get dm => dmStateController.stream;

  final dmEventController = StreamController<DataEvent>();
  StreamSink<DataEvent> get dataEventSink => dmEventController.sink;

  void mapEventToState(BlocEvent event) {
    if (!(event is DataEvent)) return;

    if(event is DataModelLoadedEvent) { this.dataModel = event.dataModel; }
    if(event is DataWipeEvent) {this.dataModel = DataModel(); };
    if(event is AddDummyDataEvent) {
      dataModel.DummyData();
    };
    if(event is GenerateFakeRecords)
      {
        List<Record> fRecords = [];

        for(int i = 0; i < event.n; i++)
        {
          dataModel.RandomSelection();

          Record r = Record();
          r.GenerateRecord(dataModel);
          fRecords.add(r);

          dataModel.ResetSelections();
        }

        BlocProvider.get().r.rEventSink.add(RecordsLoadedEvent(fRecords));
      }

    if (event is SelectedEvent) {
      if (event is GameSelectedEvent) { dataModel.SelectGame(event.index); }
      if (event is FormatSelectedEvent) { dataModel.SelectFormat(event.index); }
      if (event is PlayerSelectedEvent) { dataModel.TogglePlayerSelected(event.index); }
      if (event is FighterSelectedEvent) { dataModel.ToggleFighterSelected(event.player, event.fighterIndex, event.variantIndex); }

      int progress = dataModel.GetSelectionProgress();
      BLOCS = BlocProvider.get();
      BLOCS.ap.apsEventSink.add(ProgressChangeEvent(progress));
}
    if(event is ResetSelectionsEvent)
      {
        dataModel.ResetSelections();
        BLOCS.ap.apsEventSink.add(ProgressChangeEvent(dataModel.GetSelectionProgress()));
      }

    if (event is GamesEvent) {
      if (event.gamesEventType == GamesEvent.ADD_GAME) dataModel.AddGame(event.game);
    }else
    if (event is FormatsEvent) {
      if (event.formatsEventType == FormatsEvent.ADD_FORMAT) dataModel.GameSelected.AddFormat(event.format);
    }else
    if (event is PlayersEvent) {
      if (event.playersEventType == PlayersEvent.ADD_PLAYER) dataModel.AddPlayer(event.player);
    }else
    if (event is FightersEvent) {
      if (event.fightersEventType == FightersEvent.ADD_FIGHTER) dataModel.AddFighter(event.fighter);
    }else
    if (event is RecordsEvent) {
      if (event.eventType == RecordsEvent.PODIUM_UP) dataModel.MovePodiumPosition(event.obj, DataModel.UP);
      if (event.eventType == RecordsEvent.PODIUM_DOWN) dataModel.MovePodiumPosition(event.obj, DataModel.DOWN);
      if (event.eventType == RecordsEvent.PODIUM_REORDER) dataModel.MovePodiumPosition(event.obj, DataModel.MOVE);
      if (event.eventType == RecordsEvent.PODIUM_INDEX_TOGGLE) dataModel.TogglePodiumIndex(event.obj);
    }

    dataModel.RefreshPrompts();
    _inDataModel.add(dataModel);
  }

  /*
  Records data
   */
  Record RecordDataOnce()
  {
    Record r = Record();
    r.GenerateRecord(dataModel);
    BlocProvider.get().r.rEventSink.add(RecordAddEvent(r));

    return r;
  }

  void dispose()
  {
    dmStateController.close();
    dmEventController.close();
  }

}
