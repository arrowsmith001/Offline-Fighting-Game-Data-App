
import 'package:dojov01/bloc_provider.dart';
import 'package:dojov01/presentation/my_flutter_app_icons.dart';
import 'package:dojov01/records_bloc.dart';
import 'package:dojov01/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'add.dart';
import 'data_bloc.dart';
import 'explore.dart';
import 'package:bloc/bloc.dart';
import 'data_model.dart';

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

void main() {

  print('APP START');
  runApp(MyApp());
}



class MyApp extends StatefulWidget
{
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    StorageManager.get();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if(state == AppLifecycleState.inactive
        || state == AppLifecycleState.paused
        || state == AppLifecycleState.detached)
      {
        StorageManager.get().saveAll();
      }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    StorageManager.get().saveAll();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

      return MaterialApp(
        title: 'dojo',
        theme: ThemeData(
          primarySwatch: Colors.yellow,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/home',
        routes:<String,WidgetBuilder>{
          '/loading' : (context) => Loading(),
          '/home' : (context) => Home(),
          '/add' : (context) => AddData(),
          '/explore' : (context) => ExploreData()
        }
      );
  }
}

class Loading extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container());
  }
}


class Home extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Development Options', style: TextStyle(color: Colors.white)),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Wipe all data'),
              onTap: () {
                BlocProvider.get().d.dataEventSink.add(DataWipeEvent());
                BlocProvider.get().r.rEventSink.add(RecordsWipeEvent());
                StorageManager.get().eraseAll();
              },
            ),
            ListTile(
              title: Text('Add dummy data'),
              onTap: () {
                BlocProvider.get().d.dataEventSink.add(AddDummyDataEvent());
              },
            ),ListTile(
              title: Text('Generate 1 fake record'),
              onTap: () {
                BlocProvider.get().d.dataEventSink.add(GenerateFakeRecords(1));
              },
            ),
            ListTile(
              title: Text('Generate ${DataBloc.RECORD_GENERATION_NUMBER} fake records'),
              onTap: () {
                BlocProvider.get().d.dataEventSink.add(GenerateFakeRecords(DataBloc.RECORD_GENERATION_NUMBER));
              },
            ),

          ],
        ),
      ),
      appBar: AppBar(
          title: Text('dojo',
              style: TextStyle(fontFamily: 'Title') ),

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome',
              style: Theme.of(context).textTheme.headline4
            ),
            Padding(child: Text( 'Record and explore all your personal fighting game data here', textAlign: TextAlign.center),
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: 'fab1',
                backgroundColor: Colors.blueAccent,
                onPressed: () {
                    Navigator.pushNamed(context, '/add');

                },
                child: Icon(
                  MyFlutterApp.add,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(top:15)
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: 'fab2',
                backgroundColor: Colors.purple,
                onPressed: () {
                    Navigator.pushNamed(context, '/explore');
                },
                child: Icon(MyFlutterApp.microscope,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ) , // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class AppLifecycleReactor extends StatefulWidget
{
  @override
  _AppLifecycleReactorState createState() => _AppLifecycleReactorState();
}

class _AppLifecycleReactorState extends State<AppLifecycleReactor> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() { _notification = state; });
  }

  @override
  Widget build(BuildContext context) {
    return new Text('Last notification: $_notification');
  }
}
