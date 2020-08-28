import 'dart:async';

import 'add_page_state.dart';
import 'bloc_provider.dart';

class AddPageStateEvent extends BlocEvent{}
class ResetEvent extends BlocEvent{}
class PageChangeEvent extends AddPageStateEvent{ PageChangeEvent(int index) {this.index = index;}
int index;
}
class ProgressChangeEvent extends AddPageStateEvent{ ProgressChangeEvent(int progress) {this.progress = progress;}
int progress;
}

class AddPageBloc extends Bloc
{
  AddPageBloc()
  {
    addPageState = AddPageState();

    apsEventController.stream.asBroadcastStream().listen(mapEventToState);
  }

  // ADD PAGE STATE MODEL STUFF
  AddPageState addPageState;

  final apsStateController = StreamController<AddPageState>.broadcast();
  StreamSink<AddPageState> get _inAddPageState => apsStateController.sink;
  Stream<AddPageState> get apsStream => apsStateController.stream;

  final apsEventController = StreamController<AddPageStateEvent>();
  StreamSink<AddPageStateEvent> get apsEventSink => apsEventController.sink;

  void mapEventToState(BlocEvent event)
  {
    if(!(event is AddPageStateEvent)) return;

    if(event is PageChangeEvent)
    {
      PageChangeEvent _event = event;
      int _index = _event.index;

      addPageState.ChangePageName(_index);
    }

    if(event is ProgressChangeEvent)
    {
      ProgressChangeEvent _event = event;
      int _progress = _event.progress;

      addPageState.ChangeProgress(_progress);
    }



    _inAddPageState.add(addPageState);
  }

  @override
  void dispose() {
    apsStateController.close();
    apsEventController.close();
  }
}