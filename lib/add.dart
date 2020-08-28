
import 'dart:async';
//import 'dart:html';
import 'dart:math';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dojov01/add_page_bloc.dart';
import 'package:dojov01/bloc_provider.dart';
import 'package:dojov01/main.dart';
import 'package:dojov01/records_bloc.dart';
import 'package:dojov01/records_model.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'add_page_state.dart';
import 'data_model.dart';
import 'data_bloc.dart';
import 'data_model.dart';
import 'data_model.dart';
import 'modified.dart' as my;

class AddData extends StatefulWidget{

  final controller = PageController(initialPage: BlocProvider.get().ap.addPageState.pageIndex);

  @override
  _AddDataState createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {

  BlocProvider BLOCS = BlocProvider.get();

  // ignore: non_constant_identifier_names
  void AdvancePage(int currentIndex)
  {
    widget.controller.animateToPage(
        min(currentIndex + 1, 4),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut);
  }

  OnAddPressed(BuildContext context, int pageIndex) {

    switch(pageIndex)
    {
      case 0:
          return showDialog(context: context, builder: (context)
          {
            return CustomAlertDialog(dataObj: Game.EmptyGame());
          });
        break;
      case 1:
        return showDialog(context: context, builder: (context)
        {
          return CustomAlertDialog(dataObj: Format.EmptyFormat());
        });
        break;
      case 2:

        return showDialog(context: context, builder: (context)
        {
          return CustomAlertDialog(dataObj: Player.EmptyPlayer());
        });
        break;
      case 3:

        return showDialog(context: context, builder: (context)
        {
          return CustomAlertDialog(dataObj: Fighter.EmptyFighter());
        });
        break;
      case 4:
        break;
      default:
    }
  }

  void RecordData(BuildContext context)
  {

    Record r = BLOCS.d.RecordDataOnce();
    Scaffold.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      duration: Duration(seconds: 3, milliseconds: 0),
      content: Text(r.GetSnackbarMessage()),
      action: SnackBarAction(
        label:'UNDO',
        onPressed: (){

          BlocProvider.get().r.rEventSink.add(RecordRemoveEvent(r));

          final newSnackBar = SnackBar(
            duration: Duration(seconds: 1, milliseconds: 500),
            content: Text('Data removed'));

          Scaffold.of(context).showSnackBar(newSnackBar);
    },),);

    Scaffold.of(context).showSnackBar(snackBar);
  }

  void SaveSelections(DataModel dataModel)
  {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: StreamBuilder(
        stream: BLOCS.ap.apsStream,
        initialData: BLOCS.ap.addPageState,
        builder: (context, AsyncSnapshot<AddPageState> snapshot){
      return Row(
                children:<Widget>[
              Text(snapshot.data.pageName),
              Padding(padding:EdgeInsets.all(5)),
              Icon(snapshot.data.pageIcon)
    ]
      );
        }
          ),
          actions: <Widget>[
            StreamBuilder(stream: BLOCS.ap.apsStream,
                initialData: BLOCS.ap.addPageState,
                builder: (context,AsyncSnapshot<AddPageState> snapshot) {
                  return IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        OnAddPressed(context, snapshot.data.pageIndex);
                      });
                })
          ],
        ),
        body: SafeArea(
          child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children : <Widget>[
                    Flexible(
                         //  flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:<Widget>
                          [
                            StreamBuilder<DataModel>(
                                stream: BLOCS.d.dm,
                                initialData: BLOCS.d.dataModel,
                                builder: (context,AsyncSnapshot<DataModel> snapshot) {
                                return Row(
                                  children: <Widget>[
                                    Expanded(
                                        child: Padding(padding : EdgeInsets.all(10),
                                        child: AutoSizeText(
                                          snapshot.data.GetSelectionProgressText(),
                                          style : TextStyle(fontStyle: FontStyle.italic),
                                          maxLines:3,
                                          textAlign: TextAlign.end,))),
                                    Row(children: <Widget>[
                                      IconButton(icon: Icon(Icons.refresh), onPressed: () {
                                        BLOCS.d.dataEventSink.add(ResetSelectionsEvent());
                                        widget.controller.animateTo(0,
                                            duration: Duration(milliseconds: 300),
                                            curve: Curves.easeOut);

                                      },),
                                      IconButton(icon: Icon(Icons.save), onPressed: () {
                                        SaveSelections(snapshot.data);
                                      },)
                                    ],),
                                  ],
                                );
                              }
                            ),
                                 StreamBuilder<AddPageState>(
                                     stream: BLOCS.ap.apsStream,
                                     initialData: BLOCS.ap.addPageState,
                                     builder: (context,AsyncSnapshot<AddPageState> snapshot) {
                                     return  Container(
                                       child: SizedBox(
                                         height: 75,
                                         // mainAxisSize: MainAxisSize.min,
                                         child: my.Stepper(
                                             controlsBuilder: (BuildContext context,
                                                 {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                                               return Container(height: 0);},
                                             type: my.StepperType.horizontal,
                                             steps: [
                                               my.Step(content: Container(height:0), title: Text(''), isActive: 0 <= snapshot.data.progress, state: my.StepState.custom),
                                              my.Step(content: Container(height:0), title: Text(''), isActive: 1 <= snapshot.data.progress, state: my.StepState.custom),
                                              my.Step(content: Container(height:0), title: Text(''), isActive: 2 <= snapshot.data.progress, state: my.StepState.custom),
                                              my.Step(content: Container(height:0), title: Text(''), isActive: 3 <= snapshot.data.progress, state: my.StepState.custom)]
                                          ),
                                ),
                                     );
                                   }
                                 )

                      ,
//                    Flexible(
//                      fit: FlexFit.loose,
//                              child: Column(
//                                mainAxisSize: MainAxisSize.max,
//                                  children: <Widget>[
                    Flexible(
                      child: Center(
//                        height: double.infinity,
//                        width: double.infinity,
                        child: PageView(
                          controller: widget.controller,
                          children: <Widget>[
                            AddPage1(), AddPage2(), AddPage3(), AddPage4(), AddPage5()
                          ],
                          scrollDirection: Axis.horizontal,
                          pageSnapping: true,

                          onPageChanged: (index) =>{
                            BLOCS.ap.apsEventSink.add(PageChangeEvent(index))
                          },
                        ),
                      ),
                    ),
//                              ]),
//                            ),
                  ],
            ),
          ),

        ]))),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: StreamBuilder<RecordCollection>(
            initialData: BlocProvider.get().r.recordCollection,
            stream: BlocProvider.get().r.rStream,
          builder: (context, snapshot2) {
            return //snapshot2.hasData && snapshot2.data.IsBusy() ? CircularProgressIndicator() :
            Container(
                    child: StreamBuilder(
                      stream: BLOCS.ap.apsStream,
                      initialData: BLOCS.ap.addPageState,
                      builder: (context,AsyncSnapshot<AddPageState> snapshot){
                        return FloatingActionButton(
                          heroTag: 'fab3',
                          backgroundColor: snapshot.data.pageIndex == 4 ? Colors.yellow
                              : snapshot.data.MayProgress() ? Colors.purple : Colors.grey,
                          onPressed: () {
                            snapshot.data.pageIndex == 4 ? RecordData(context) :
                            snapshot.data.MayProgress() ? AdvancePage(snapshot.data.pageIndex) : null;
                          },
                          child: snapshot.data.pageIndex == 4 ? Icon(Icons.add_box, color: Colors.black)
                              : Icon(Icons.forward, color: Colors.white),
                        );
                      },
                    )
                  );
          }
        )
    );
  }

}

class CustomAlertDialog extends StatefulWidget {

  final DataObj dataObj;
  final BlocProvider BLOCS = BlocProvider.get();

  Map<Field, int> listfieldNum;
  List<Field> entries;

  CustomAlertDialog({Key key, this.dataObj}) : super(key:key)
  {
    listfieldNum = {};
    entries = dataObj.GetRequiredFields();

    for(Field f in entries)
    {
      if(f.typeName == Field.TYPE_LIST)
      {
        listfieldNum.addAll({ f : 0 });
        print('Added list field with 0');
      }
    }
  }

  @override
  _CustomAlertDialogState createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  //List<TextEditingController> textControllers = [];


  void ChangeListNum(Field f, int to)
  {
    setState(() {
      widget.listfieldNum[f] = to;
      print('listfieldNum changed to ${widget.listfieldNum[f]}');
    });
  }

  void ReturnValue(Map<String, dynamic> map) {

    print(map);

    if(widget.dataObj.runtimeType == Game)
        {
          widget.BLOCS.d.dataEventSink.add(
              GamesEvent(GamesEvent.ADD_GAME,
                  new Game.Map(map)));
          // TODO Some sort of static form-getting build object
        }
      else
      if(widget.dataObj.runtimeType == Format)
      {
        widget.BLOCS.d.dataEventSink.add(
            FormatsEvent(FormatsEvent.ADD_FORMAT,
                new Format.Map(map)));
        // TODO Some sort of static form-getting build object
      }
      else
      if(widget.dataObj.runtimeType == Player)
      {
        widget.BLOCS.d.dataEventSink.add(
            PlayersEvent(PlayersEvent.ADD_PLAYER,
                new Player.Map(map)));
        // TODO Some sort of static form-getting build object
      }
      else
      if(widget.dataObj.runtimeType == Fighter)
      {
        widget.BLOCS.d.dataEventSink.add(
            FightersEvent(FightersEvent.ADD_FIGHTER,
                new Fighter.Map(map)));
        // TODO Some sort of static form-getting build object
      }

  }

  bool CheckResetState() {
//    // Query controllers and extract their values and add new game!
//    if (_resetKey.currentState.validate()) {
//      _resetKey.currentState.save();
//
//
//
//
//      return true;
//    } else {
//      setState(() {
//        _resetValidate = true;
//      });
//      return false;
//    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
        child: AlertDialog(
            title: Text('Add ' + widget.dataObj.runtimeType.toString()),
            content: FormBuilder(
                    key: _fbKey,
                   // autovalidate: _resetValidate,
                          child: SingleChildScrollView(
                            physics: ScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children:<Widget>[
                                FormBuilderTextField(
                                    attribute: 'Name',
                                    decoration: InputDecoration(labelText: 'Name'),
                                    validators: [
                                      FormBuilderValidators.required(errorText:'Required field')
                                    ]
                                ),
                                   ListView.builder(
                                       physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                      itemCount: widget.entries.length,
                                      itemBuilder: (context, i) {
                                        return Container(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                widget.entries[i].typeName == Field.TYPE_STRING ?
                                                    FormBuilderTextField(
                                                      attribute: widget.entries[i].name,
                                                      decoration: InputDecoration(labelText: widget.entries[i].name
                                                          + (widget.entries[i].optional ? ' (opt.)' : ''),
                                                          helperText: widget.entries[i].descript, helperMaxLines: 3),
                                                        validators: [
                                                          !widget.entries[i].optional ? FormBuilderValidators.required(errorText:'Required field')
                                                              : (dynamic) => null
                                                        ]
                                                    )
                                                : widget.entries[i].typeName == Field.TYPE_INT ?
                                                    FormBuilderTouchSpin(
                                                        step: 1,
                                                        initialValue: 1,
                                                        attribute: widget.entries[i].name,
                                                        decoration: InputDecoration(labelText: widget.entries[i].name
                                                            + (widget.entries[i].optional ? ' (opt.)' : ''),
                                                            helperText: widget.entries[i].descript, helperMaxLines: 3),
                                                        validators: [
                                                          FormBuilderValidators.min(1, errorText:'Must be at least 1')
                                                        ]
                                                    )
                                                : widget.entries[i].typeName == Field.TYPE_LIST ?

                                                    Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children:[
                                                        FormBuilderTouchSpin(
                                                            onChanged: (value) { ChangeListNum(widget.entries[i], value); },
                                                            min: 0,
                                                            step: 1,
                                                            initialValue: 0,
                                                            attribute: widget.entries[i].name,
                                                            decoration: InputDecoration(labelText: widget.entries[i].name
                                                                + (widget.entries[i].optional ? ' (opt.)' : ''),
                                                                helperText: widget.listfieldNum[widget.entries[i]] == 0
                                                                    ? widget.entries[i].descript : null,
                                                                helperMaxLines: 3),
                                                            validators: [
                                                              !widget.entries[i].optional
                                                                  ? FormBuilderValidators.min(1, errorText:'At least one list item required')
                                                                  : (dynamic) => null
                                                            ]
                                                        ),
                                                          ListView.builder(
                                                              physics: NeverScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            itemCount: widget.listfieldNum[widget.entries[i]],
                                                              itemBuilder: (context, j) {
                                                              return FormBuilderTextField(
                                                                attribute: '${widget.entries[i].name}_${j}',
                                                                decoration: InputDecoration(labelText: '${j + 1}',
                                                                helperText: widget.listfieldNum[widget.entries[i]] == j + 1
                                                                    ? widget.entries[i].descript : null,
                                                                    helperMaxLines: 3),
                                                                validators: [
                                                                  FormBuilderValidators.required(errorText:'List item should be filled or removed')
                                                                ],
                                                              );
                                                              }
                                                          ),
                                                      ]
                                                    )
                                                    : null
                                              ]
                                          ),
                                        );
                                      }),


                              ],
                            ),
                          )
                  )

                  ,

          actions: <Widget>[
            new FlatButton(
              child: new Text(
                'CANCEL',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop("");
              },
            ),
            new FlatButton(
              child: new Text(
                'ADD',
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

String validateField(String value) {
  if(value == "") return "Required field";
  else return null;
}

// AddPage1

class AddPage1 extends StatefulWidget{

  @override
  _AddPage1State createState() => _AddPage1State();
}

class _AddPage1State extends State<AddPage1> {

  BlocProvider BLOCS = BlocProvider.get();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: StreamBuilder(
      stream: BLOCS.d.dm,
        initialData: BLOCS.d.dataModel,
      builder: (context, AsyncSnapshot<DataModel> snapshot) {
        return
          snapshot.data.Page1Prompt != "" ?
          Center(child: Padding(padding: EdgeInsets.all(50.0), child: Text(snapshot.data.Page1Prompt,textAlign: TextAlign.center,)))
              : ListView.builder(
            itemCount: snapshot.data.games.length,
            itemBuilder: (context, i) {
              return Card(
                    child:
                      ListTile(
                        leading: Radio(groupValue: snapshot.data.GetGameSelectedIndex(), value: i, onChanged: (int value) {  }, ),
                        onTap: () {
                          BLOCS.d.dataEventSink.add(GameSelectedEvent(i));
                        },
                        title: Text(snapshot.data.games[i].name),
                        subtitle: Text(snapshot.data.games[i].GetFieldsBlockTexts(false)))
                    ,
                  );
            });
      },
    ));
  }
}

class AddPage2 extends StatefulWidget{
  @override
  _AddPage2State createState() => _AddPage2State();
}

class _AddPage2State extends State<AddPage2> {
  BlocProvider BLOCS = BlocProvider.get();

  @override
  Widget build(BuildContext context) {
    return
    //  Center(child:Text("2"))
    Container(
        child: StreamBuilder(
          stream: BLOCS.d.dm,
          initialData: BLOCS.d.dataModel,
          builder: (context, AsyncSnapshot<DataModel> snapshot) {
            return
              (snapshot.data.Page2Prompt != "" ?
              Center(child: Padding(padding: EdgeInsets.all(50.0), child: Text(snapshot.data.Page2Prompt,textAlign: TextAlign.center,)))
                  : ListView.builder(
                  itemCount: snapshot.data.GameSelected.formats.length,
                  itemBuilder: (context, i) {
                    return Card(
                      child:
                      ListTile(
                          leading: Radio(groupValue: snapshot.data.GetFormatSelectedIndex(), value: i, onChanged: (int value) {  }, ),
                          onTap: () {
                            BLOCS.d.dataEventSink.add(FormatSelectedEvent(i));
                          },
                          title: Text(snapshot.data.GameSelected.formats[i].name),
                          subtitle: Text(snapshot.data.GameSelected.formats[i].GetFieldsBlockTexts(true)))
                      ,
                    );
                  })
            );
          },
        )
    );
  }
}
class AddPage3 extends StatefulWidget{
  @override
  _AddPage3State createState() => _AddPage3State();
}

class _AddPage3State extends State<AddPage3> {
  BlocProvider BLOCS = BlocProvider.get();

  @override
  Widget build(BuildContext context) {
    return
      //  Center(child:Text("2"))
      Container(
          child: StreamBuilder(
            stream: BLOCS.d.dm,
            initialData: BLOCS.d.dataModel,
            builder: (context, AsyncSnapshot<DataModel> snapshot) {
              return
                (snapshot.data.Page3Prompt != "" ?
                Center(child: Padding(padding: EdgeInsets.all(50.0), child: Text(snapshot.data.Page3Prompt,textAlign: TextAlign.center,)))
                    : ListView.builder(
                    itemCount: snapshot.data.players.length,
                    itemBuilder: (context, i) {
                      return Card(
                        child:
                        ListTile(
                            leading: Checkbox(value: snapshot.data.PlayersSelected.contains(snapshot.data.players[i]),
                              onChanged: (bool value) { BLOCS.d.dataEventSink.add(PlayerSelectedEvent(i)); },) ,
                            onTap: () {
                              BLOCS.d.dataEventSink.add(PlayerSelectedEvent(i));
                            },
                            title: Text(snapshot.data.players[i].name +
                                (!snapshot.data.PlayersSelected.contains(snapshot.data.players[i]) ? "" : // Check that player is selected
                                  ' (' + (1 + snapshot.data.PlayersSelected.indexOf(snapshot.data.players[i])).toString() // Return index within "PlayerSelected"
                                    + '/' + (snapshot.data.FormatSelected == null ? '?' : snapshot.data.FormatSelected.GetFieldValue('#Players').toString()) // Return number of players required for format, if exists
                                    + ')'
                                )
                      ),
                            // subtitle: Text(snapshot.data.players[i].fieldsText),
                      )
                      );
                    }));
            },
          )
      )
    ;
  }
}
class AddPage4 extends StatefulWidget{
  @override
  _AddPage4State createState() => _AddPage4State();
}

class _AddPage4State extends State<AddPage4> {
  BlocProvider BLOCS = BlocProvider.get();

  @override
  Widget build(BuildContext context) {
    return
      //  Center(child:Text("2"))
      Container(
          child: StreamBuilder(
            stream: BLOCS.d.dm,
            initialData: BLOCS.d.dataModel,
            builder: (context, AsyncSnapshot<DataModel> snapshot) {
              return
                (snapshot.data.Page4Prompt != "" ?
                Center(child: Padding(padding: EdgeInsets.all(50.0), child: Text(snapshot.data.Page4Prompt,textAlign: TextAlign.center,)))
                    : ListView.builder(
                    itemCount: snapshot.data.PlayersSelected.length,
                    itemBuilder: (context, i) {
                      return Card(
                            child:
                            ListTile(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                    AddPage4_FighterSelection(snapshot.data.PlayersSelected[i], snapshot.data.GameSelected.fighters, snapshot.data.IsSingleFighter())));
                              },
                              title: Text(snapshot.data.PlayersSelected[i].name, style: TextStyle(fontWeight: FontWeight.bold),),
                              subtitle: Text(snapshot.data.GetFightersPromptForPlayer(snapshot.data.PlayersSelected[i])),
                              trailing: Icon(Icons.arrow_forward_ios),
                            )

                      );
                    }));
            },
          )
      )
    ;
  }
}

class AddPage4_FighterSelection extends StatefulWidget{

  final Player player;
  final List<Fighter> fighters;
  final bool isSingle;

  AddPage4_FighterSelection(this.player, this.fighters, this.isSingle);

  @override
  _AddPage4_FighterSelectionState createState() => _AddPage4_FighterSelectionState();
}

class _AddPage4_FighterSelectionState extends State<AddPage4_FighterSelection> {

  BlocProvider BLOCS = BlocProvider.get();

  OfferVariants(BuildContext context, int index)
  {
    return showDialog(context: context, builder: (context)
    {
      return VariantDialog(widget.fighters[index], index, widget.player, widget.isSingle);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: StreamBuilder<DataModel>(
              stream: BLOCS.d.dm,
              initialData: BLOCS.d.dataModel,
            builder: (context, snapshot) {
              return FittedBox(fit:BoxFit.fitWidth,child:AutoSizeText(
                  "Select fighter"+(snapshot.data.IsSingleFighter() ? '' : 's') +" for "+widget.player.name,
              )
              );
            })
        ),
        body: SafeArea(
          child: StreamBuilder<DataModel>(
            stream: BLOCS.d.dm,
            initialData: BLOCS.d.dataModel,
            builder: (context, snapshot) {
              return Container(
                child: widget.fighters.isEmpty ? Text('No fighters')
                : ListView.builder(
                    itemCount: widget.fighters.length,
                    itemBuilder: (context, i) {
                      return ListTile(
                                    leading: snapshot.data.IsSingleFighter() ? null : Checkbox(value: snapshot.data.IsFighterSelectedByPlayer(i, widget.player),
                                      onChanged: (bool value) {  },),
                                    onTap: () {
                                      if(widget.fighters[i].GetFieldValue('Variations') == null || widget.fighters[i].GetFieldValue('Variations').isEmpty // If no variations exist
                                          || snapshot.data.FightersSelected[widget.player].fighters.contains(widget.fighters[i])) // Removing fighter
                                        {
                                          BLOCS.d.dataEventSink.add(FighterSelectedEvent(i, widget.player, null));
                                          snapshot.data.IsSingleFighter() ? Navigator.of(context).pop() : null;
                                        }
                                      else OfferVariants(context, i);
                                    },
                                    title: Text(widget.fighters[i].name + snapshot.data.GetFighterSelectionPrompt(widget.fighters[i], widget.player)),
                                subtitle: snapshot.data.PlayerVariantSelectionText(widget.player, widget.fighters[i]) != null
                                    ? Text(snapshot.data.PlayerVariantSelectionText(widget.player, widget.fighters[i])) : null
                              );
                    })
              );
            }
          ),
        ),
      floatingActionButton: StreamBuilder<DataModel>(
        initialData: BlocProvider.get().d.dataModel,
        stream: BlocProvider.get().d.dm,
        builder: (context, snapshot) {
          return FloatingActionButton(
            child: Icon(Icons.check),
            backgroundColor: snapshot.data.HasPlayerChosenSufficientFighters(widget.player)
                ? Colors.yellow : Colors.grey,
            onPressed: () {
              snapshot.data.HasPlayerChosenSufficientFighters(widget.player)
                  ? Navigator.of(context).pop() : null;
            },

          );
        }
      ),
    );
  }

}

class VariantDialog extends StatelessWidget {

  final Fighter fighter;

  final int fighterIndex;
  final Player player;
  final bool isSingle;

  VariantDialog(this.fighter, this.fighterIndex, this.player, this.isSingle);

  @override
  Widget build(BuildContext context) {

    return Container(
        child: AlertDialog(
          title: Text('Select ' + fighter.name + ' variant'),
          content: SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:<Widget>[
                    ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: fighter.GetFieldValue('Variations').length,
                        itemBuilder: (context, i) {
                          return Column(
                            children: <Widget>[
                              ListTile(
                                  title: Text(fighter.GetFieldValue('Variations')[i]),
                                onTap: () {
                                  BlocProvider.get().d.dataEventSink.add(FighterSelectedEvent(fighterIndex, player, i));

                                  Navigator.of(context).pop();
                                  if(isSingle) Navigator.of(context).pop();
                                },
                              ), Padding(padding: EdgeInsets.all(5.0))],
                          );
                        }),
                  ],
                ),
              )
          ,
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                'NO VARIANT',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                BlocProvider.get().d.dataEventSink.add(FighterSelectedEvent(fighterIndex, player, null));
                Navigator.of(context).pop();
                if(isSingle) Navigator.of(context).pop();
              },
            ),
          ],
        )
    );
  }
}



class AddPage5 extends StatefulWidget{
  final ScrollController controller = ScrollController();
  @override
  _AddPage5State createState() => _AddPage5State();
}

class _AddPage5State extends State<AddPage5> {
  BlocProvider BLOCS = BlocProvider.get();

  @override
  Widget build(BuildContext context) {
    return
      //  Center(child:Text("2"))
      Container(
          child: StreamBuilder(
            stream: BLOCS.d.dm,
            initialData: BLOCS.d.dataModel,
            builder: (context, AsyncSnapshot<DataModel> snapshot) {
              return
                snapshot.data.Page5Prompt != "" ?
                Center(child: Padding(padding: EdgeInsets.all(50.0), child: Text(snapshot.data.Page5Prompt,textAlign: TextAlign.center,)))
                    : ReorderableListView(
                  scrollController: widget.controller,
                            onReorder: (int oldIndex, int newIndex) {
                              BLOCS.d.dataEventSink.add(RecordsEvent(<int>[oldIndex, newIndex], RecordsEvent.PODIUM_REORDER));
                            },
                            children: List.generate(snapshot.data.PlayerPodium.length, (i) {
                              return Card(
                              key: Key('$i'),
                              child: ListTile(
                                onTap: () {

                                },
                                leading: GestureDetector(
                                    child: Text(snapshot.data.PodiumIndices[i].toString(), style: TextStyle(fontSize: 50),),
                                    onTap: (){
                                      BLOCS.d.dataEventSink.add(RecordsEvent(i, RecordsEvent.PODIUM_INDEX_TOGGLE));
                                    }),
                                title: Text(snapshot.data.PlayerPodium[i].name, style: TextStyle(fontWeight: FontWeight.bold),),
                                subtitle: Text(snapshot.data.GetFightersPromptForPlayer(snapshot.data.PlayerPodium[i])),
                                trailing: Container(
                                 // width: 50,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                    Visibility(child: Container(width: 40,
                                      child: IconButton(icon: Align(alignment: Alignment.center,child: Icon(Icons.keyboard_arrow_up)),
                                          onPressed: () {
                                            BLOCS.d.dataEventSink.add(RecordsEvent(i, RecordsEvent.PODIUM_UP));
                                          }),
                                    ), visible: i > 0),
                                    Visibility(child: Container(
                                      width: 40,
                                      child: IconButton(icon: Align(alignment: Alignment.center,child: Icon(Icons.keyboard_arrow_down)),
                                          onPressed: () {
                                            BLOCS.d.dataEventSink.add(RecordsEvent(i,RecordsEvent.PODIUM_DOWN));
                                          }),
                                    ), visible:  i < snapshot.data.PlayerPodium.length - 1) ],),

                                ),
                              ),
                            );})
                          );
            },
          )
      )
    ;
  }
}