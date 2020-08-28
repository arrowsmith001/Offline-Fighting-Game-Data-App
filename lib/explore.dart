import 'package:auto_size_text/auto_size_text.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:dojov01/bloc_provider.dart';
import 'package:dojov01/records_model.dart';
import 'package:dojov01/records_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'dart:math' as math; // import this
import 'data_model.dart';
import 'modified.dart' as my;

class ExploreData extends StatefulWidget{

  @override
  _ExploreDataState createState() => _ExploreDataState();
}

class _ExploreDataState extends State<ExploreData> with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();

    BlocProvider.get().r.rEventSink.add(ExploreStartedEvent());
    controller = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Data'),
        bottom: TabBar(
          controller: controller,
          tabs: <Widget>[
          Tab(text:'GAME VIEW'), Tab(text:'PLAYER VIEW')
        ],),
        actions: <Widget>[
          IconButton(
          icon: Icon(Icons.search),
      onPressed: () { BlocProvider.get().r.rEventSink.add(QueryAllEvent()); },
      )
        ],
      ),
        body: SafeArea(
          child: Center(
            child: StreamBuilder(
              stream: BlocProvider.get().r.rStream,
              initialData: BlocProvider.get().r.recordCollection,
              builder: (BuildContext context, AsyncSnapshot<RecordCollection> snapshot) {
                return snapshot.data.records == null || snapshot.data.records.isEmpty ?
                    Center(child: Text('No records found'))
                : StreamBuilder<RecordCollection>(
                    stream: BlocProvider.get().r.rStream,
                    builder: (context, snapshot) {
                    return !snapshot.hasData ? CircularProgressIndicator()
                    : snapshot.data.gameCards.length == 0 ? Text('No records found')
                    : TabBarView(
                      controller: controller,
                      children: <Widget>[
                               // !snapshot.hasData ? Container(height: 100, width: 100, child: CircularProgressIndicator()) :

                                ListView.builder(
                                    itemCount: snapshot.data.gameCards.length,
                                    itemBuilder: (context, i)
                                    {
                                      return Card(
                                        child: ListTile(
                                          onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => GameViewFocus(snapshot.data.gameCards[i].game))); },
                                          title: Text(snapshot.data.gameCards[i].GetGameTitleString()),
                                          subtitle: Text(snapshot.data.gameCards[i].GetTestString()),
                                        ),
                                      );
                                    }),
                                //!snapshot.hasData ? Container(height: 100, width: 100, child: CircularProgressIndicator()) :
                                ListView.builder(
                                    itemCount: snapshot.data.records.length,
                                    itemBuilder: (context, i)
                                    {
                                      return Card(
                                        child: ListTile(
                                          title: Text(snapshot.data.records[i].toString()),
                                        ),
                                      );
                                    })

                      ]);
                  }
                );

              },
            ),
          ),
        )
    );
  }
}


class GameViewFocus extends StatefulWidget{

  final Game g;

  GameViewFocus(this.g);

  @override
  _GameViewFocusState createState() => _GameViewFocusState();
}

class _GameViewFocusState extends State<GameViewFocus> {

  ShowSelectionDialog(List<DataObj> list, Selections selections) {

    var selectedList;
    if(selections == null) selectedList = null;
    else if(list is List<Format>) selectedList = selections.formatSelections;
    else if(list is List<Player>) selectedList = selections.playerSelections;
    else selectedList = null;

    return showDialog(context: context, builder: (context)
    {
      return SelectionPopup(widget.g, list,selectedList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Column(children: <Widget>[Text(widget.g.name,)],)),
      body: SafeArea(
          child: Container(
              child: StreamBuilder<RecordCollection>(
                  stream: BlocProvider.get().r.rStream,
                  initialData: BlocProvider.get().r.recordCollection,
                  builder: (context, snapshot) {
                    return Stack(
                      children:
                      [
                        Column(
                            mainAxisSize: MainAxisSize.max,
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children : <Widget>[
                              Flexible(
                                //flex: 1,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children:<Widget>
                                  [
                                    Row(
                                      children: <Widget>
                                      [
                                        Expanded(
                                          child: Container(
                                            height: 40,
                                            child: my.RaisedButton.icon(
                                                onPressed: () {
                                                  ShowSelectionDialog(snapshot.data.GetFormatList(widget.g), snapshot.data.gameToSelections[widget.g]); }, label: Flexible(child: Text(snapshot.data.GetFormatsSelectedString(widget.g))), icon: Container(child: Icon(Icons.arrow_drop_down)),iconOnLeft: false
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 40,
                                            child: my.RaisedButton.icon(
                                                onPressed: () {
                                                  ShowSelectionDialog(snapshot.data.GetPlayersList(),snapshot.data.gameToSelections[widget.g]);  }, label: Flexible(child: Text(snapshot.data.GetPlayersSelectedString(widget.g))), icon: Icon(Icons.arrow_drop_down),iconOnLeft: false
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 40,
                                            child: PopupMenuButton(
                                              onSelected: (i) { BlocProvider.get().r.rEventSink.add(GameViewOrderChangeEvent(widget.g, GameViewModelOrder.GetOrderList()[i]));  },
                                              child: Row(children: <Widget>[
                                                Expanded(child: Text(snapshot.data.GetGameViewOrderText(widget.g), textAlign: TextAlign.right,)),
                                                Expanded(child: IconButton(icon: Transform(alignment: Alignment.center, transform: Matrix4.rotationX(snapshot.data.GetGameViewOrderAsc(widget.g) ? math.pi : 0), child: Icon(Icons.sort)), onPressed: () { BlocProvider.get().r.rEventSink.add(ToggleAscEvent(widget.g)); },))],),
                                              itemBuilder: (BuildContext context) {
                                                return List.generate(GameViewModelOrder.GetOrderList().length, (i) => PopupMenuItem(value: i, child: Text(GameViewModelOrder.GetOrderList()[i]),)); GameViewModelOrder.GetOrderList();
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Expanded(
                                      child: (GameViewModelState.IsFighterState(snapshot.data.gameViewState))
                                          ? ListView.builder( // FIGHTER LISTS
                                          shrinkWrap: true,
                                          itemCount: snapshot.data.gameCardsLookup[widget.g].fms.length,
                                          itemBuilder: (context, i) {
                                            switch(snapshot.data.gameViewState)
                                            {
                                              case GameViewModelState.STATE_WINLOSS_SINGLE:
                                                return Card(
                                                  elevation: 0.5,
                                                  child: Column(children: <Widget>[
                                                    Row(
                                                        mainAxisSize: MainAxisSize.max,
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 5, horizontal : 10),
                                                              child: Align(
                                                                  alignment: Alignment.centerLeft,
                                                                  //flex: 1,
                                                                  child: SizedBox(
                                                                      height: 18,
                                                                      child: FittedBox(child: AutoSizeText(
                                                                          snapshot.data.gameCardsLookup[widget.g].fms[i].data.name,
                                                                          textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w600))))),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 5, horizontal : 10),
                                                              child: Align(
                                                                  alignment: Alignment.centerRight,
                                                                  //flex: 1,
                                                                  child: SizedBox(
                                                                      height: 12,
                                                                      child: FittedBox(child: AutoSizeText(
                                                                        snapshot.data.gameCardsLookup[widget.g].fms[i].GetPlaysString(),
                                                                        textAlign: TextAlign.left,)))),
                                                            ),
                                                          )
                                                        ]
                                                    )
                                                    ,
                                                    Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: <Widget>[
                                                        Expanded(child: Center(child: Text(snapshot.data.gameCardsLookup[widget.g].fms[i].GetFractionWinsString(), style: TextStyle(color: Colors.green, fontSize: 28),))),
                                                        Expanded(
                                                          child: SizedBox(
                                                            height: 50,
//                                                width: 100,
                                                            child: !snapshot.data.gameCardsLookup[widget.g].fms[i].MakeSeriesData() && snapshot.data.IsBusy()
                                                                ? Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator()))
                                                                : !snapshot.data.gameCardsLookup[widget.g].fms[i].MakeSeriesData() ? Center(child:Text('no data',style: TextStyle(fontStyle: FontStyle.italic),))
                                                                : Center(
                                                              child: charts.PieChart(
                                                                  [
                                                                    new charts.Series<FighterWinsLossesData,String>(
                                                                        id: 'W/L',
                                                                        domainFn: (FighterWinsLossesData fwld, _) => fwld.tag,
                                                                        measureFn: (FighterWinsLossesData fwld, _) => fwld.val,
                                                                        colorFn: (FighterWinsLossesData fwld, _) => fwld.color,
                                                                        labelAccessorFn: (FighterWinsLossesData fwld, _) => fwld.val.toString(),
                                                                        data: snapshot.data.gameCardsLookup[widget.g].fms[i].winsLossesData),
                                                                  ],
                                                                  animate: false,
                                                                  layoutConfig: charts.LayoutConfig(
                                                                      rightMarginSpec: charts.MarginSpec.fixedPixel(5),
                                                                      topMarginSpec: charts.MarginSpec.fixedPixel(5),
                                                                      bottomMarginSpec: charts.MarginSpec.fixedPixel(5),
                                                                      leftMarginSpec: charts.MarginSpec.fixedPixel(5)),
                                                                  defaultRenderer: new charts.ArcRendererConfig(
                                                                      arcRendererDecorators: [
                                                                        new charts.ArcLabelDecorator(
                                                                            leaderLineStyleSpec: charts.ArcLabelLeaderLineStyleSpec(length: 8),
                                                                            outsideLabelStyleSpec: charts.TextStyleSpec(fontSize: 16),
                                                                            showLeaderLines: false,
                                                                            labelPadding: 0,
                                                                            labelPosition: charts.ArcLabelPosition.outside)
                                                                      ])
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(child: Center(child: Text(snapshot.data.gameCardsLookup[widget.g].fms[i].GetFractionLossesString(), style: TextStyle(color: Colors.red, fontSize: 24)))),
                                                        Expanded(child: Center(child: Text(snapshot.data.gameCardsLookup[widget.g].fms[i].GetDrawString(), style: TextStyle(color: Colors.grey, fontSize: 16))))
                                                      ],),
                                                    Padding(padding: EdgeInsets.all(5))
                                                  ],) ,
                                                );
                                                break;
                                              case GameViewModelState.STATE_MATCHUPS_SINGLE:
                                                return Card(
                                                  elevation: 0.5,
                                                  child: Column(children: <Widget>[
                                                    Row(
                                                        mainAxisSize: MainAxisSize.max,
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 5, horizontal : 10),
                                                              child: Align(
                                                                  alignment: Alignment.centerLeft,
                                                                  //flex: 1,
                                                                  child: SizedBox(
                                                                      height: 18,
                                                                      child: FittedBox(child: AutoSizeText(
                                                                          snapshot.data.gameCardsLookup[widget.g].fms[i].data.name,
                                                                          textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w600))))),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 5, horizontal : 10),
                                                              child: Align(
                                                                  alignment: Alignment.centerRight,
                                                                  //flex: 1,
                                                                  child: SizedBox(
                                                                      height: 12,
                                                                      child: FittedBox(child: AutoSizeText(
                                                                        snapshot.data.gameCardsLookup[widget.g].fms[i].GetPlaysString(),
                                                                        textAlign: TextAlign.left,)))),
                                                            ),
                                                          )
                                                        ]
                                                    ),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: <Widget>[
                                                        Expanded(child: Column(children: <Widget>[
                                                          AutoSizeText('Best Matchup:',textAlign: TextAlign.left, style: TextStyle(color: Colors.blueAccent)),
                                                          AutoSizeText(snapshot.data.gameCardsLookup[widget.g].fms[i].GetBestMatchup(),textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),),
                                                          AutoSizeText(snapshot.data.gameCardsLookup[widget.g].fms[i].GetBestMatchupString(), textAlign: TextAlign.right)], )),
                                                        Expanded(child: Column(children: <Widget>[
                                                          AutoSizeText('Worst Matchup:',textAlign: TextAlign.left, style: TextStyle(color: Colors.red)),
                                                          AutoSizeText(snapshot.data.gameCardsLookup[widget.g].fms[i].GetWorstMatchup(),textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                                                          AutoSizeText(snapshot.data.gameCardsLookup[widget.g].fms[i].GetWorstMatchupString(), textAlign: TextAlign.right)], ))
                                                      ],),
                                                    Padding(padding: EdgeInsets.all(5))
                                                  ],) ,
                                                );
                                                break;
                                              case GameViewModelState.STATE_VARIANTS_SINGLE:
                                                return Card(
                                                  elevation: 0.5,
                                                  child: Column(children: <Widget>[
                                                    Row(
                                                        mainAxisSize: MainAxisSize.max,
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 5, horizontal : 10),
                                                              child: Align(
                                                                  alignment: Alignment.centerLeft,
                                                                  //flex: 1,
                                                                  child: SizedBox(
                                                                      height: 18,
                                                                      child: FittedBox(child: AutoSizeText(
                                                                          snapshot.data.gameCardsLookup[widget.g].fms[i].data.name,
                                                                          textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w600))))),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 5, horizontal : 10),
                                                              child: Align(
                                                                  alignment: Alignment.centerRight,
                                                                  //flex: 1,
                                                                  child: SizedBox(
                                                                      height: 12,
                                                                      child: FittedBox(child: AutoSizeText(
                                                                        snapshot.data.gameCardsLookup[widget.g].fms[i].GetPlaysString(),
                                                                        textAlign: TextAlign.left,)))),
                                                            ),
                                                          )
                                                        ]
                                                    ),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: <Widget>[
                                                        Expanded(child: Column(children: <Widget>[
                                                          AutoSizeText('Best variant:',textAlign: TextAlign.left, style: TextStyle(color: Colors.blueAccent)),
                                                          AutoSizeText(snapshot.data.gameCardsLookup[widget.g].fms[i].GetBestVariant(),textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),),
                                                          AutoSizeText(snapshot.data.gameCardsLookup[widget.g].fms[i].GetBestVariantString(), textAlign: TextAlign.right)], )),
                                                        Expanded(child: Column(children: <Widget>[
                                                          AutoSizeText('Worst variant:',textAlign: TextAlign.left, style: TextStyle(color: Colors.red)),
                                                          AutoSizeText(snapshot.data.gameCardsLookup[widget.g].fms[i].GetWorstVariant(),textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                                                          AutoSizeText(snapshot.data.gameCardsLookup[widget.g].fms[i].GetWorstVariantString(), textAlign: TextAlign.right)], ))
                                                      ],),
                                                    Padding(padding: EdgeInsets.all(5))
                                                  ],) ,
                                                );
                                                break;
                                            }//WINS/LOSSES (FIGHTERS)
                                            return Container();
                                          })
                                          :ListView.builder( // TEAM LISTS
                                          shrinkWrap: true,
                                          itemCount: snapshot.data.gameCardsLookup[widget.g].tms.length,
                                          itemBuilder: (context, i) {
                                            switch(snapshot.data.gameViewState)
                                            {
                                              case GameViewModelState.STATE_WINLOSS_TEAM:
                                                return Card(
                                                  elevation: 0.5,
                                                  child: Column(children: <Widget>[
                                                    Row(
                                                        mainAxisSize: MainAxisSize.max,
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 5, horizontal : 10),
                                                              child: Align(
                                                                  alignment: Alignment.centerLeft,
                                                                  //flex: 1,
                                                                  child: SizedBox(
                                                                      height: 18,
                                                                      child: FittedBox(child: AutoSizeText(
                                                                          snapshot.data.gameCardsLookup[widget.g].tms[i].teamString,
                                                                          textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w600))))),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 5, horizontal : 10),
                                                              child: Align(
                                                                  alignment: Alignment.centerRight,
                                                                  //flex: 1,
                                                                  child: SizedBox(
                                                                      height: 12,
                                                                      child: FittedBox(child: AutoSizeText(
                                                                        snapshot.data.gameCardsLookup[widget.g].tms[i].GetPlaysString(),
                                                                        textAlign: TextAlign.left,)))),
                                                            ),
                                                          )
                                                        ]
                                                    )
                                                    ,
                                                    Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: <Widget>[
                                                        Expanded(child: Center(child: Text(snapshot.data.gameCardsLookup[widget.g].tms[i].GetFractionWinsString(), style: TextStyle(color: Colors.green, fontSize: 28),))),
                                                        Expanded(
                                                          child: SizedBox(
                                                            height: 50,
//                                                width: 100,
                                                            child: !snapshot.data.gameCardsLookup[widget.g].tms[i].MakeSeriesData() && snapshot.data.IsBusy()
                                                                ? Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator()))
                                                                : !snapshot.data.gameCardsLookup[widget.g].tms[i].MakeSeriesData() ? Center(child:Text('no data',style: TextStyle(fontStyle: FontStyle.italic),))
                                                                : Center(
                                                              child: charts.PieChart(
                                                                  [
                                                                    new charts.Series<FighterWinsLossesData,String>(
                                                                        id: 'W/L',
                                                                        domainFn: (FighterWinsLossesData fwld, _) => fwld.tag,
                                                                        measureFn: (FighterWinsLossesData fwld, _) => fwld.val,
                                                                        colorFn: (FighterWinsLossesData fwld, _) => fwld.color,
                                                                        labelAccessorFn: (FighterWinsLossesData fwld, _) => fwld.val.toString(),
                                                                        data: snapshot.data.gameCardsLookup[widget.g].tms[i].winsLossesData),
                                                                  ],
                                                                  animate: false,
                                                                  layoutConfig: charts.LayoutConfig(
                                                                      rightMarginSpec: charts.MarginSpec.fixedPixel(5),
                                                                      topMarginSpec: charts.MarginSpec.fixedPixel(5),
                                                                      bottomMarginSpec: charts.MarginSpec.fixedPixel(5),
                                                                      leftMarginSpec: charts.MarginSpec.fixedPixel(5)),
                                                                  defaultRenderer: new charts.ArcRendererConfig(
                                                                      arcRendererDecorators: [
                                                                        new charts.ArcLabelDecorator(
                                                                            leaderLineStyleSpec: charts.ArcLabelLeaderLineStyleSpec(length: 8),
                                                                            outsideLabelStyleSpec: charts.TextStyleSpec(fontSize: 16),
                                                                            showLeaderLines: false,
                                                                            labelPadding: 0,
                                                                            labelPosition: charts.ArcLabelPosition.outside)
                                                                      ])
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(child: Center(child: Text(snapshot.data.gameCardsLookup[widget.g].tms[i].GetFractionLossesString(), style: TextStyle(color: Colors.red, fontSize: 24)))),
                                                        Expanded(child: Center(child: Text(snapshot.data.gameCardsLookup[widget.g].tms[i].GetDrawString(), style: TextStyle(color: Colors.grey, fontSize: 16))))
                                                      ],),
                                                    Padding(padding: EdgeInsets.all(5))
                                                  ],) ,
                                                );
                                                break;
                                              case GameViewModelState.STATE_MATCHUPS_TEAM:
                                                return Card(
                                                  elevation: 0.5,
                                                  child: Column(children: <Widget>[
                                                    Row(
                                                        mainAxisSize: MainAxisSize.max,
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 5, horizontal : 10),
                                                              child: Align(
                                                                  alignment: Alignment.centerLeft,
                                                                  //flex: 1,
                                                                  child: SizedBox(
                                                                      height: 18,
                                                                      child: FittedBox(child: AutoSizeText(
                                                                          snapshot.data.gameCardsLookup[widget.g].tms[i].teamString,
                                                                          textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w600))))),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 5, horizontal : 10),
                                                              child: Align(
                                                                  alignment: Alignment.centerRight,
                                                                  //flex: 1,
                                                                  child: SizedBox(
                                                                      height: 12,
                                                                      child: FittedBox(child: AutoSizeText(
                                                                        snapshot.data.gameCardsLookup[widget.g].tms[i].GetPlaysString(),
                                                                        textAlign: TextAlign.left,)))),
                                                            ),
                                                          )
                                                        ]
                                                    ),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: <Widget>[
                                                        Expanded(child: Column(children: <Widget>[
                                                          AutoSizeText('Best Matchup:',textAlign: TextAlign.left, style: TextStyle(color: Colors.blueAccent)),
                                                          AutoSizeText(snapshot.data.gameCardsLookup[widget.g].tms[i].GetBestMatchup(),textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),),
                                                          AutoSizeText(snapshot.data.gameCardsLookup[widget.g].tms[i].GetBestMatchupString(), textAlign: TextAlign.right)], )),
                                                        Expanded(child: Column(children: <Widget>[
                                                          AutoSizeText('Worst Matchup:',textAlign: TextAlign.left, style: TextStyle(color: Colors.red)),
                                                          AutoSizeText(snapshot.data.gameCardsLookup[widget.g].tms[i].GetWorstMatchup(),textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                                                          AutoSizeText(snapshot.data.gameCardsLookup[widget.g].tms[i].GetWorstMatchupString(), textAlign: TextAlign.right)], ))
                                                      ],),
                                                    Padding(padding: EdgeInsets.all(5))
                                                  ],) ,
                                                );
                                                break;
                                              case GameViewModelState.STATE_VARIANTS_TEAM:
                                                return Card(
                                                  elevation: 0.5,
                                                  child: Column(children: <Widget>[
                                                    Row(
                                                        mainAxisSize: MainAxisSize.max,
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 5, horizontal : 10),
                                                              child: Align(
                                                                  alignment: Alignment.centerLeft,
                                                                  //flex: 1,
                                                                  child: SizedBox(
                                                                      height: 18,
                                                                      child: FittedBox(child: AutoSizeText(
                                                                          snapshot.data.gameCardsLookup[widget.g].tms[i].teamString,
                                                                          textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w600))))),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 5, horizontal : 10),
                                                              child: Align(
                                                                  alignment: Alignment.centerRight,
                                                                  //flex: 1,
                                                                  child: SizedBox(
                                                                      height: 12,
                                                                      child: FittedBox(child: AutoSizeText(
                                                                        snapshot.data.gameCardsLookup[widget.g].tms[i].GetPlaysString(),
                                                                        textAlign: TextAlign.left,)))),
                                                            ),
                                                          )
                                                        ]
                                                    ),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: <Widget>[
                                                        Expanded(child: Column(children: <Widget>[
                                                          AutoSizeText('Best variant:',textAlign: TextAlign.left, style: TextStyle(color: Colors.blueAccent)),
                                                          AutoSizeText(snapshot.data.gameCardsLookup[widget.g].tms[i].GetBestVariant(),textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),),
                                                          AutoSizeText(snapshot.data.gameCardsLookup[widget.g].tms[i].GetBestVariantString(), textAlign: TextAlign.right)], )),
                                                        Expanded(child: Column(children: <Widget>[
                                                          AutoSizeText('Worst variant:',textAlign: TextAlign.left, style: TextStyle(color: Colors.red)),
                                                          AutoSizeText(snapshot.data.gameCardsLookup[widget.g].tms[i].GetWorstVariant(),textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                                                          AutoSizeText(snapshot.data.gameCardsLookup[widget.g].tms[i].GetWorstVariantString(), textAlign: TextAlign.right)], ))
                                                      ],),
                                                    Padding(padding: EdgeInsets.all(5))
                                                  ],) ,
                                                );
                                                break;
                                            }//WINS/LOSSES (FIGHTERS)
                                            return Container();
                                          }),
                                    ),
                                    Row(children: <Widget>
                                    [
                                      SizedBox(width:80, child: my.RaisedButton.icon(onPressed: () { BlocProvider.get().r.rEventSink.add(ChangeGameViewState(false));  }, iconOnLeft: true, label: Text(''), icon: Icon(Icons.arrow_left),)),
                                      Expanded(child:
                                      PopupMenuButton(
                                        //initialValue: GameViewModelState.GetStateList().indexOf(snapshot.data.gameViewState),
                                        onSelected: (i) { BlocProvider.get().r.rEventSink.add(ChangeGameViewState.to(GameViewModelState.GetStateList()[i]));  },
                                        child: Center(child: Text(snapshot.data.gameViewState, textAlign: TextAlign.center))
                                        ,
                                        itemBuilder: (BuildContext context) {
                                          return List.generate(GameViewModelState.GetStateList().length, (i) =>
                                              PopupMenuItem(value: i, child: Text(GameViewModelState.GetStateList()[i], textAlign: TextAlign.center))); GameViewModelOrder.GetOrderList();
                                        },
                                      )
                                      ),
                                      SizedBox(width:80, child: my.RaisedButton.icon(onPressed: () { BlocProvider.get().r.rEventSink.add(ChangeGameViewState(true)); }, iconOnLeft: false, label: Text(''), icon: Icon(Icons.arrow_right),)),
                                    ],)
                                  ],
                                ),
                              ),


                            ]),
                        (snapshot.data.IsBusy() ? Center(child: CircularProgressIndicator()) : SizedBox.shrink())
                      ],
                    );
                }
              ))),
    );
  }


}

class SelectionPopup extends StatefulWidget{

  final List<DataObj> list;
  final List<String> selectedList;
  final Game g;

  SelectionPopup(this.g, this.list, this.selectedList);

  @override
  _SelectionPopupState createState() => _SelectionPopupState();
}

class _SelectionPopupState extends State<SelectionPopup> {

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {

  }

  void ReturnValue(Map<String, dynamic> value) {
    print(value);

    if(widget.list is List<Format>)
    {
      print('FORMAT');
      BlocProvider.get().r.rEventSink.add(SelectionMadeEvent(widget.g, value, Selections.FORMAT));
    }
    else if(widget.list is List<Player>)
    {
      print('PLAYER');
      BlocProvider.get().r.rEventSink.add(SelectionMadeEvent(widget.g, value, Selections.PLAYER));
    }
    else
      {
        throw Exception('SELECTION OBJECT NOT CONFIGURED FOR');
      }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: AlertDialog(
          title: Text('Select multiple'),
          content: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:<Widget>[
                FormBuilder(
                    key: _fbKey,
                    // autovalidate: _resetValidate,
                    child: SingleChildScrollView(
                      physics: ScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:<Widget>[
                          ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: widget.list.length,
                              itemBuilder: (context, i) {
                                return FormBuilderCheckbox(
                                  contentPadding: EdgeInsets.all(0),
                                    attribute: widget.list[i].name,
                                  label: Text(widget.list[i].name),
                                  initialValue: widget.selectedList == null || widget.selectedList.isEmpty ? true : widget.selectedList.contains(widget.list[i].name),
                                );
                              }),
                        ],
                      ),
                    )
                ),
              ],
            ),
          )
          ,
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                'APPLY',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                if (_fbKey.currentState.saveAndValidate()) {
                  ReturnValue(_fbKey.currentState.value);
                  Navigator.of(context).pop("");
                }
              },
            ),
          ],
        )
    );
  }


}





String GetFormattedDatetime(DateTime timeLogged) {

  return timeLogged.hour.toString().padLeft(2, '0') + ':' + timeLogged.minute.toString().padLeft(2, '0') + ':' + timeLogged.second.toString().padLeft(2, '0')
      + ' ' + timeLogged.day.toString().padLeft(2, '0')+ '/' + timeLogged.month.toString().padLeft(2, '0') + '/' + timeLogged.year.toString();
}