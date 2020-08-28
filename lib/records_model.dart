import 'dart:async';
import 'dart:core';
import 'dart:ui';

import 'package:dojov01/main.dart';
import 'package:dojov01/records_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'data_model.dart';


class RecordCollection
{
  // STATUS BOOLS TODO Make front page react
  bool AddingRecords = false;
  bool CreatingGameViewCards = false;

  // INPUTS
  List<Record> records = []; // Records are INPUTS for records model
  RecordsModel rm; // Records model is a reconstruction of the Data Model from records (holds SQL inputs)
  Database database;

  // For putting events in
  StreamSink<RecordsModelEvent> sink;
  void Nudge(){sink.add(RecordsModelNudge());}

  // OUTPUTS (UI)
  List<String> sqlList = [];

  RecordCollection(StreamSink<RecordsModelEvent> rEventSink)
  {
    this.sink = rEventSink;
    this.rm = RecordsModel(this);
    InitialiseSQL();
  }

  bool DatabaseInitialised = false;

  /*
  Sets up SQL database
   */
  Future<void> InitialiseSQL() async {

    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + 'data.db';

    // Delete the database
    await deleteDatabase(path);

    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {

      List<Map<String, String>> columns = [];
         columns.add({'id': SQLTools.primaryInt});
          columns.add({'record_num': SQLTools.int});
          columns.add({'team': SQLTools.int});
          columns.add({'game': SQLTools.text});
          columns.add({'format': SQLTools.text});
          columns.add({'player': SQLTools.text});
          columns.add({'player_fighter': SQLTools.text});
          columns.add({'player_fighter_variant': SQLTools.text});
          columns.add({'vs': SQLTools.text});
          columns.add({'vs_fighter': SQLTools.text});
          columns.add({'vs_fighter_variant': SQLTools.text});
          columns.add({'result': SQLTools.text});

          // When creating the db, create the table
          await db.execute(
              SQLTools.CreateTable('Data', columns));
          DatabaseInitialised = true;
        });
  }

  static String myNull = 'null';
  int idNum = 0;
  String GetID() {
    idNum++;
    return idNum.toString();//.padLeft(10, '0');
  }

  Future<void> AddRecords(List<Record> records) async {

    AddingRecords = true;
    if(!DatabaseInitialised) await InitialiseSQL();

    List<Map<String,dynamic>> maps = [];

    for(Record r in records)
    {
      this.records.add(r); // For record keeping only
      SQLInput sqli = this.rm.AddToModel(r); // Returns SQL input for database

      maps.addAll(AddSQLI(sqli));
    }

    await BatchInsert(maps);
    AddingRecords = false;

    await CreateGameViewCards();
  }
  Future<void> AddRecord(Record record) async {
    if(!DatabaseInitialised) await InitialiseSQL();

    this.records.add(record); // For record keeping only
    SQLInput sqli = this.rm.AddToModel(record); // Returns SQL input for database

    await BatchInsert(AddSQLI(sqli));
    await CreateGameViewCards();
  }

  List<Map<String,dynamic>> AddSQLI(SQLInput sqli) {

    List<Map<String,dynamic>> out = [];

    int index = this.rm.sqlInputs.indexOf(sqli);

    Map<String,String> baseVars = {};
    baseVars.addAll({'record_num': index.toString()});
    baseVars.addAll({'game': sqli.g.name});
    baseVars.addAll({'format': sqli.f.name});

    for(Player p in sqli.ps)
    {
      Map<String,String> pVars = Map<String,String>.from(baseVars);

      pVars.addAll({'player': p.name});

      Map<String,String> fVars = Map<String,String>.from(pVars);

      if(sqli.playerToFighters[p].length > 1) fVars.addAll({'team': '1'}); // If a team fighter
      else  fVars.addAll({'team': '0'});

      fVars.addAll({'player_fighter': DataModel.StringFromList(sqli.playerToFighters[p], '/', true)});
      fVars.addAll({'player_fighter_variant': DataModel.VariantList(sqli.playerToFighters[p], sqli.playerToFightersToVariants[p], '/')});

      for(Player opp in sqli.ps)
      {
        if(opp.name != p.name)
        {
          Map<String,String> oVars = Map<String,String>.from(fVars);

          oVars.addAll({'vs': opp.name});
          oVars.addAll({'vs_fighter': DataModel.StringFromList(sqli.playerToFighters[opp], '/', true)});
          oVars.addAll({'vs_fighter_variant': DataModel.VariantList(sqli.playerToFighters[opp], sqli.playerToFightersToVariants[opp], '/')});

          // Result
          String res = sqli.playerToPosition[p] < sqli.playerToPosition[opp]
              ? 'w'
              : sqli.playerToPosition[p] == sqli.playerToPosition[opp]
              ? 'd'
              : 'l';

          oVars.addAll({'result': res.toString()});

          oVars.addAll({'id': GetID()});
          //Map<String,List> args = SQLTools.CreateInsert('Data', oVars);
          out.add(oVars);
        }
      }
    }

    return out;
  }

  Future<void> UpsertIntoData(Map<String,dynamic> map) async{
    await database.transaction((txn) async
    {
      await txn.rawInsert(SQLTools.Insert('Data', map));
    });
    print('SQL ADD: '+map.toString());
  }
  Future<void> BatchInsert(List<Map<String,dynamic>> maps) async{
    await database.transaction((txn) async
    {
      Batch batch = txn.batch();;
      for(Map map in maps) batch.insert('Data', map);
      await batch.commit(noResult: true);
    });
    print('SQL ADDED: '+maps.length.toString());
  }

  Future<void> ClearRecords() async {
    this.records.clear();
    this.rm = RecordsModel(this);
    await database.transaction((txn) => txn.rawQuery('DELETE from Data'));
  }
  Future<void> QueryAll() async
  {
    // 'SELECT * FROM Data WHERE player_fighter LIKE '%/Ryu/%''
    //List<Map> list = await database.rawQuery(SQLTools.CreateQuery('Data', '*') + SQLTools.CreateLikeMiddle('player_fighter', '/Ryu/'));
    //sqlList = List.generate(list.length, (index) => list[index].toString());

    List list = await database.transaction((txn) => txn.rawQuery('SELECT * FROM Data ORDER BY record_num'));
   // List list = await database.rawQuery('SELECT * FROM Data WHERE game = \"Ultimate Marvel vs Capcom 3\" and player_fighter = \"Hawkeye\" GROUP BY player,vs,record_num');
    //list = await database.rawQuery('SELECT COUNT(*) FROM Data WHERE game=\"Ultimate Marvel vs Capcom 3\" and player_fighter=\'Hawkeye\' GROUP BY player_fighter,player,record_num');
    for(dynamic d in list) printWrapped(d.toString());
    //print(list.length);
  }

  String gameViewState = GameViewModelState.STATE_WINLOSS_SINGLE; // Default

  Future<void> CreateGameViewCards() async {

    CreatingGameViewCards = true;

    var futures = List<Future>();
    gameCards = [];
    gameCardsLookup = {};

    for(Game g in rm.games)
    {
      GameViewModel gvm = GameViewModel(g, this.database, gameToSelections[g], this);

      futures.add(gvm.CalcGamePlays());
      futures.addAll(gvm.GetAllFutures());

      gameCards.add(gvm);
      gameCardsLookup.addAll( {gvm.game : gvm} );
    }

    await Future.wait(futures);

    // Got data, now make series
    for(GameViewModel gvm in gameCards)
      {
        for(GameViewFighterModel fvm in gvm.fms) fvm.MakeSeriesData();
        for(GameViewTeamModel tvm in gvm.tms) tvm.MakeSeriesData();
      }

    Nudge();
    CreatingGameViewCards = false;
  }

  List<GameViewModel> gameCards = [];
  Map<Game,GameViewModel> gameCardsLookup;
  Map<Game, Selections> gameToSelections = {};


  List<Format> GetFormatList(Game g) {
    return this.rm.gameToFormatLookup[g].values.toList();
  }
  List<Player> GetPlayersList() { return this.rm.players; }

  String GetFormatsSelectedString(Game g) {
    return this.gameToSelections[g] == null || this.gameToSelections[g].formatSelections.length == this.rm.gameToFormatLookup[g].length
          || this.gameToSelections[g].formatSelections.isEmpty
        ? 'All formats'
        : this.gameToSelections[g].formatSelections.length == 1 ? this.gameToSelections[g].formatSelections[0]
        : this.gameToSelections[g].formatSelections.length.toString() + ' formats';
  }
  String GetPlayersSelectedString(Game g) {
    return this.gameToSelections[g] == null || this.gameToSelections[g].playerSelections.length == this.rm.players.length
        || this.gameToSelections[g].playerSelections.isEmpty
        ? 'All players'
        : this.gameToSelections[g].playerSelections.length == 1 ? this.gameToSelections[g].playerSelections[0]
        : this.gameToSelections[g].playerSelections.length.toString() + ' players';

  }

  void SelectAndRefresh(Game g, Map<String, dynamic> map, String type) {

    Selections selections;

    if(!gameToSelections.containsKey(g))
      {
        selections = Selections();
        gameToSelections.addAll({ g : selections });
      }
    else
      {
        selections = gameToSelections[g];
      }

    switch(type)
    {
      case Selections.FORMAT:
        selections.AddFormatSelections(map);
        break;
      case Selections.PLAYER:
        selections.AddPlayerSelections(map);
        break;
    }

    CreateGameViewCards();

  }

  void ChangeGameViewState(String gameViewState, bool advance) {
    if(gameViewState != null) this.gameViewState = gameViewState;
    else if(advance != null)  this.gameViewState = GameViewModelState.GetCycledState(advance, this.gameViewState);
  }

  void ChangeGameViewOrder(Game g, String orderType) {
    gameCardsLookup[g].OrderLists(orderType, gameCardsLookup[g].fightersOrder.asc);
    //print('ChangeGameViewOrder');
  }

  String GetGameViewOrderText(Game g) {
    if(gameCardsLookup[g].fightersOrder.orderType == GameViewModelOrder.ORDER_DEFAULT) return 'Order by';
    else return gameCardsLookup[g].fightersOrder.orderType;
  }

  GetGameViewOrderAsc(Game g) {
    return gameCardsLookup[g].fightersOrder.asc;
  }

  void ToggleAsc(Game g) {
    gameCardsLookup[g].ToggleAsc();
  }

  GetOrderType(Game g) => gameCardsLookup[g].fightersOrder.orderType;

  bool IsBusy() => !DatabaseInitialised || AddingRecords || CreatingGameViewCards;

  void RemoveRecord(Record r) {

    // TODO

  }

}

class SQLTools
{
  static String int = 'INTEGER';
  static String text = "TEXT";
  static String primaryInt = "INTEGER PRIMARY KEY";
  static String real = "REAL";

  static String CreateTable(String tableName, List<Map<String,String>> maps) {
    String out = 'CREATE TABLE $tableName (';
    var num = 0;
    for (Map map in maps)
  {
    num++;
    out+= map.keys.first + ' ' + map.values.first + (num == maps.length ? '' : ', ');
  }
    //print(out + ')');
    return out + ')';
  }

  static String Insert(String tableName, Map<String, dynamic> map) {
    String out = 'INSERT INTO $tableName(';
    String out2 = ' VALUES(';
    var num = 0;
    for (String s in map.keys)
    {
      num++;
      out+= s + (num == map.length ? '' : ', ');
      out2+= (map[s] is String ? '\"' + map[s] + '\"' : map[s]) + (num == map.length ? '' : ', ');
    }
    //print(out + ')' + out2 + ')');
    return out + ')' + out2 + ')';
  }
}

class Selections
{
  static const String FORMAT = 'f';
  static const String PLAYER = 'p';

  List<String> formatSelections = [];
  List<String> playerSelections = [];

  void AddFormatSelections(Map<String,dynamic> formatForm) {
    formatSelections = [];
    for(String s in formatForm.keys)
      {
        if(formatForm[s].toString() == 'true') formatSelections.add(s);
      }
  }
  void AddPlayerSelections(Map<String,dynamic> playerForm) {
    playerSelections = [];
    for(String s in playerForm.keys)
    {
      if(playerForm[s].toString() == 'true') playerSelections.add(s);
    }
  }

  String GetSQLString()
  {
    String out = '';

    if(formatSelections.isEmpty && playerSelections.isEmpty) return out;
    if(formatSelections.isNotEmpty) out += ' and (format=';
    for(String s in formatSelections)
    {
      out += '\'' + s + '\'' + (DataModel.isLast(s, formatSelections) ? ')' : ' or format=');
    }
    if(playerSelections.isNotEmpty) out += ' and (player=';
    for(String s in playerSelections)
    {
      out += '\'' + s + '\'' + (DataModel.isLast(s, playerSelections) ? ')' : ' or player=');
    }

    return out;
  }
}

class GameViewModelState{
  static const String STATE_WINLOSS_SINGLE = 'Wins/Losses (Fighters)';
  static const String STATE_MATCHUPS_SINGLE = 'Matchups (Fighters)';
  static const String STATE_VARIANTS_SINGLE = 'Variants (Fighters)';
  static const String STATE_WINLOSS_TEAM = 'Wins/Losses (Teams)';
  static const String STATE_MATCHUPS_TEAM = 'Matchups (Teams)';
  static const String STATE_VARIANTS_TEAM = 'Variants (Teams)';
  static List<String> GetStateList() => [STATE_WINLOSS_SINGLE, STATE_MATCHUPS_SINGLE, STATE_VARIANTS_SINGLE, STATE_WINLOSS_TEAM, STATE_MATCHUPS_TEAM, STATE_VARIANTS_TEAM];
  static String GetCycledState(bool advance, String currentState) {
    List<String> list = GetStateList();
    //print(list.indexOf(currentState));
    return list[((list.indexOf(currentState) + (advance ? 1 : -1)) % list.length)];
  }

  static bool IsFighterState(String gameViewState) {return(gameViewState == STATE_WINLOSS_SINGLE || gameViewState == STATE_MATCHUPS_SINGLE || gameViewState == STATE_VARIANTS_SINGLE);}
}

class GameViewModelOrder{
  static const String ORDER_DEFAULT = 'Default';
  static const String ORDER_ALPHABET = 'A-Z';
  static const String ORDER_PLAYS = 'Plays';
  static const String ORDER_WINS = 'Wins';
  static const String ORDER_WIN_PERCENT = 'Win%';
  static const String ORDER_LOSS = 'Loss';
  static const String ORDER_LOSS_PERCENT = 'Loss%';
  static const String ORDER_DRAW = 'Draw';

  GameViewModelOrder(this.orderType, this.asc);
  static List<String> GetOrderList() => [ORDER_ALPHABET, ORDER_PLAYS, ORDER_WINS, ORDER_WIN_PERCENT, ORDER_LOSS, ORDER_LOSS_PERCENT, ORDER_DRAW];

  static List<GameViewFighterModel> OrderFighters(List<GameViewFighterModel> list, GameViewModelOrder orderData) {
    List<GameViewFighterModel> newList = [];
    newList.addAll(list);
    bool asc = orderData.asc;
    switch(orderData.orderType)
    {
      case ORDER_ALPHABET:
        asc ? newList.sort((a, b) {return a.data.name.toLowerCase().compareTo(b.data.name.toLowerCase());})
          : newList.sort((b, a) {return a.data.name.toLowerCase().compareTo(b.data.name.toLowerCase());});
        break;
      case ORDER_PLAYS:
        asc ? newList.sort((a, b) {return a.plays.compareTo(b.plays);})
         : newList.sort((b, a) {return a.plays.compareTo(b.plays);});
        break;
      case ORDER_WINS:
        asc ? newList.sort((a, b) {return a.wins.compareTo(b.wins);})
         : newList.sort((b, a) {return a.wins.compareTo(b.wins);});
        break;
      case ORDER_WIN_PERCENT:
        asc ? newList.sort((a, b) {return a.GetFractionWins().compareTo(b.GetFractionWins());})
         : newList.sort((b, a) {return a.GetFractionWins().compareTo(b.GetFractionWins());});
        break;
      case ORDER_LOSS:
        asc ? newList.sort((a, b) {return a.losses.compareTo(b.wins);})
         : newList.sort((b, a) {return a.losses.compareTo(b.wins);});
        break;
      case ORDER_LOSS_PERCENT:
        asc ? newList.sort((a, b) {return a.GetFractionLoss().compareTo(b.GetFractionLoss());})
        : newList.sort((b, a) {return a.GetFractionLoss().compareTo(b.GetFractionLoss());});
        break;
      case ORDER_DRAW:
        asc ? newList.sort((a, b) {return a.draws.compareTo(b.draws);})
        : newList.sort((b, a) {return a.draws.compareTo(b.draws);});
        break;
    }
    return newList;
  }
  static List<GameViewTeamModel> OrderTeams(List<GameViewTeamModel> list, GameViewModelOrder orderData) {
    List<GameViewTeamModel> newList = [];
    newList.addAll(list);
    bool asc = orderData.asc;
    switch(orderData.orderType)
    {
      case ORDER_ALPHABET:
        asc ? newList.sort((a, b) {return a.teamString.toLowerCase().compareTo(b.teamString.toLowerCase());})
            : newList.sort((b, a) {return a.teamString.toLowerCase().compareTo(b.teamString.toLowerCase());});
        break;
      case ORDER_PLAYS:
        asc ? newList.sort((a, b) {return a.plays.compareTo(b.plays);})
            : newList.sort((b, a) {return a.plays.compareTo(b.plays);});
        break;
      case ORDER_WINS:
        asc ? newList.sort((a, b) {return a.wins.compareTo(b.wins);})
            : newList.sort((b, a) {return a.wins.compareTo(b.wins);});
        break;
      case ORDER_WIN_PERCENT:
        asc ? newList.sort((a, b) {return a.GetFractionWins().compareTo(b.GetFractionWins());})
            : newList.sort((b, a) {return a.GetFractionWins().compareTo(b.GetFractionWins());});
        break;
      case ORDER_LOSS:
        asc ? newList.sort((a, b) {return a.losses.compareTo(b.wins);})
            : newList.sort((b, a) {return a.losses.compareTo(b.wins);});
        break;
      case ORDER_LOSS_PERCENT:
        asc ? newList.sort((a, b) {return a.GetFractionLoss().compareTo(b.GetFractionLoss());})
            : newList.sort((b, a) {return a.GetFractionLoss().compareTo(b.GetFractionLoss());});
        break;
      case ORDER_DRAW:
        asc ? newList.sort((a, b) {return a.draws.compareTo(b.draws);})
            : newList.sort((b, a) {return a.draws.compareTo(b.draws);});
        break;
    }
    return newList;
  }

  String orderType;
  bool asc;

}

class GameViewModel
{
  Game game;
  Database database;
  RecordCollection rc;

  Selections selections;
  GameViewModelOrder fightersOrder = GameViewModelOrder(GameViewModelOrder.ORDER_DEFAULT, true); // Default ordering

  List<GameViewSubModel> sms = [];
  List<GameViewFighterModel> fms = [];
  List<GameViewTeamModel> tms = [];

  GameViewModel(this.game, this.database, this.selections, this.rc){
    SetChildModels();
  }

  void SetChildModels(){
    if(rc.rm.gameToFighterLookup.containsKey(game))
    {
      for(Fighter f in rc.rm.gameToFighterLookup[game].values)
      {
        GameViewFighterModel gvfm = GameViewFighterModel(game, f, database, selections, rc);
        fms.add(gvfm);

        sms.add(gvfm);
      }

      //print('GetTestString (${game.name}:' + GetTestString());
    }
    if(rc.rm.gameToTeamLookup.containsKey(game)) {
      for (List<Fighter> fs in rc.rm.gameToTeamLookup[game].values) {
        GameViewTeamModel gvtm = GameViewTeamModel(
            game, fs, database, selections, rc);
        tms.add(gvtm);

        sms.add(gvtm);
      }
    }
  }

  void OrderLists(String orderType, bool asc)
  {
    this.fightersOrder = GameViewModelOrder(orderType, asc);

    this.fms = GameViewModelOrder.OrderFighters(fms, fightersOrder);
    this.tms = GameViewModelOrder.OrderTeams(tms, fightersOrder);
  }

  Future<void> CalcGamePlays() async {
    List playsList = await database.rawQuery('SELECT COUNT(DISTINCT record_num) FROM Data WHERE game = \"${game.name}\"');
    plays = playsList[0]['COUNT(DISTINCT record_num)'];
    rc.Nudge();
  }

  // Data
  int plays;

  String GetTestString() {
    String out = '';
    for(GameViewFighterModel gvfm in fms)
      {
        out += gvfm.data.name;
        out += '\n     ' + 'Plays: ' + gvfm.plays.toString();
        out += '\n     ' + 'Wins: ' + gvfm.wins.toString();
        out += '\n     ' + 'Losses: ' + gvfm.losses.toString();
        out += '\n     ' + 'Draws: ' + gvfm.draws.toString();
        out += '\n     ' + 'Best matchup: ' + (gvfm.bestMatchup != null ? gvfm.bestMatchup.name : '');
        out += '\n     ' + 'Worst matchup: ' + (gvfm.worstMatchup != null ? gvfm.worstMatchup.name : '');
        out += '\n     ' + 'Best team: ' + DataModel.StringFromList(gvfm.bestTeam, '/', false) ;
        out += '\n     ' + 'Worst team: ' + DataModel.StringFromList(gvfm.worstTeam, '/', false) ;
        out += fms.indexOf(gvfm) < fms.length - 1 ? '\n' : ' ';
      }

    return out;
  }

  String GetGameTitleString() {
    return (this.game.name + ' (' + plays.toString() + ' play'+(plays == 1 ? '' : 's')+')');
  }

  void ToggleAsc() {
    this.fightersOrder.asc = !this.fightersOrder.asc;
    this.fms = GameViewModelOrder.OrderFighters(this.fms, this.fightersOrder);
    this.tms = GameViewModelOrder.OrderTeams(this.tms, this.fightersOrder);
  }

  List<Future> GetAllFutures() {

    List<Future> outFutures = [];

    outFutures.add(this.CalcGamePlays());

    for(GameViewSubModel gvsm in sms)
    {
      outFutures.addAll(gvsm.GetFutures());
    }

    return outFutures;
  }


}

abstract class GameViewSubModel<T>{

  bool isTeam;

  String qString;

  GameViewSubModel(this.game, this.data, this.database, this.selections, this.rc) {}

  List<Future<void>> GetFutures();

  Game game;
  T data;
  Database database;
  Selections selections;
  RecordCollection rc;

  int plays;
  int wins;
  int losses;
  int draws;
  T bestMatchup;
  T worstMatchup;
  double winPercAgainstBestMatchup;
  double lossPercAgainstWorstMatchup;
  List<Fighter> bestTeam;
  List<Fighter> worstTeam;
  String bestVariant;
  String worstVariant;
  double winPercWithBestVariant;
  double lossPercWithWorstVariant;

  String GetBestMatchup() => (bestMatchup == null) ? '-' : bestMatchup.toString();
  String GetWorstMatchup()  => (worstMatchup == null) ? '-' : worstMatchup.toString();

  String GetBestVariant() => bestVariant == null ? '-' : bestVariant;

  String GetBestVariantString(){
    String out = '-';
    if(winPercWithBestVariant == null) return out;
    NumberFormat nf = NumberFormat.percentPattern();
    return 'wins ' + nf.format(winPercWithBestVariant);
  }

  String GetWorstVariant() => worstVariant == null ? '-' : worstVariant;

  String GetWorstVariantString() {
    String out = '-';
    if(lossPercWithWorstVariant == null) return out;
    NumberFormat nf = NumberFormat.percentPattern();
    return 'loses ' + nf.format(lossPercWithWorstVariant);
  }
}

class DataHolder{
  DataHolder(this.id);
  var id;
  int wins = 0;
  int loss = 0;
  double winPerc = 0.0;
  double lossPerc = 0.0;

  void AddWin(){
    wins++;
    CalcPerc();
  }

  void AddLoss()
  {
    loss++;
    CalcPerc();
  }

  void CalcPerc(){
    if(wins + loss == 0) return;
    winPerc = wins / (wins + loss);
    lossPerc = loss / (wins + loss);
  }
}

class GameViewTeamModel extends GameViewSubModel<List>{

  @override
  List<Future<void>> GetFutures() {
    return [CalcPlays(), CalcWins(), CalcLosses(), CalcDraws(), CalcBestMatch(), CalcWorstMatch(), CalcBestAndWorstVariants()];
  }

  String teamString;

  GameViewTeamModel(Game game, List<Fighter> data, Database database, Selections selections, RecordCollection rc) : super(game, data, database, selections, rc){
    this.teamString = DataModel.StringFromList(this.data, '/', false);
  }
  Future<void> CalcPlays() async {retry(1, _GetPlays, null).then((value) => plays = value); rc.Nudge();}
  Future<void> CalcWins() async { retry(1, _GetResult, 'w').then((value) => wins = value); MakeSeriesData(); rc.Nudge();}
  Future<void> CalcLosses() async {retry(1, _GetResult, 'l').then((value) => losses = value); MakeSeriesData(); rc.Nudge();}
  Future<void> CalcDraws() async {retry(1, _GetResult, 'd').then((value) => draws = value); rc.Nudge();}
  Future<void> CalcBestMatch() async {
    double maxWinPercent = 0;
    List<Fighter> bestMatchupTemp = null;
    for (List<Fighter> fs in rc.rm.gameToTeamLookup[game].values) {
      String str = DataModel.StringFromList(fs, '/', true);
      int fighterWins;
      int fighterPlays;
      List fighterWinsList = await database.transaction((txn) =>
      txn.rawQuery(
          'SELECT id FROM Data WHERE game = \"${game.name}\" and player_fighter = \"/$teamString/\" and vs_fighter = \"$str\" and result=\"w\"'
              + (selections == null ? '' : selections.GetSQLString())
              + ' GROUP BY player,vs,record_num')).catchError((error) => { print('ERROR:' + error.toString()) });
      List fighterPlaysList = await database.transaction((txn) =>
          txn.rawQuery(
              'SELECT id FROM Data WHERE game = \"${game.name}\" and player_fighter = \"/$teamString/\" and vs_fighter = \"$str\"'
                  + (selections == null ? '' : selections.GetSQLString())
                  + ' GROUP BY player,vs,record_num')).catchError((error) => { print('ERROR:' + error.toString()) });
      fighterWins = fighterWinsList.length;
      fighterPlays = fighterPlaysList.length;
      if ((fighterWins.toDouble()/fighterPlays) > maxWinPercent) {
        maxWinPercent = (fighterWins.toDouble()/fighterPlays);
        bestMatchupTemp = fs;
      }
    }
    bestMatchup = bestMatchupTemp;
    winPercAgainstBestMatchup = maxWinPercent;
    rc.Nudge();
  }
  Future<void> CalcWorstMatch() async {// TODO Calculate best matchup
    double maxLossPercent = 0;
    List<Fighter> worstMatchupTemp = null;
    for (List<Fighter> fs in rc.rm.gameToTeamLookup[game].values) {
      String str = DataModel.StringFromList(fs, '/', true);
      int fighterLoss;
      int fighterPlays;
      List fighterLossList = await database.transaction((txn) =>
      txn.rawQuery('SELECT id FROM Data WHERE game = \"${game.name}\" and player_fighter = \"/$teamString/\" and vs_fighter = \"$str\" and result=\"l\"'
          + (selections == null ? '' : selections.GetSQLString())
          + ' GROUP BY player,vs,record_num')).catchError((error) => {print('ERROR:' +  error.toString()) });
      List fighterPlaysList = await database.transaction((txn) =>
      txn.rawQuery(
          'SELECT id FROM Data WHERE game = \"${game.name}\" and player_fighter = \"/$teamString/\" and vs_fighter = \"$str\" '
              + (selections == null ? '' : selections.GetSQLString())
              + ' GROUP BY player,vs,record_num')).catchError((error) => { print('ERROR:' + error.toString()) });
      //fighterLoss = fighterLossList.isEmpty ? 0 : fighterLossList[0]['COUNT(*)'];
      fighterLoss = fighterLossList.length;
      fighterPlays = fighterPlaysList.length;
      //print(f.name + ' ' + (fighterLoss.toDouble()/fighterPlays).toString());
      if ((fighterLoss.toDouble()/fighterPlays) > maxLossPercent) {
        maxLossPercent = (fighterLoss.toDouble()/fighterPlays);
        worstMatchupTemp = fs;
      }
    }
    worstMatchup = worstMatchupTemp;
    lossPercAgainstWorstMatchup = maxLossPercent;
    rc.Nudge();
  }
  Future<void> CalcBestAndWorstVariants() async {
    // List<String> vs = this.rc.rm.gameToFighterToVariantsLookup[game] == null ? [] : this.rc.rm.gameToFighterToVariantsLookup[game][fighter].toList();

    List variantResults = await database.transaction((txn) =>
      txn.rawQuery('SELECT player_fighter_variant,result FROM Data WHERE player_fighter = \"/$teamString\/"' + (selections == null ? '' : selections.GetSQLString()))).catchError((error) => print('ERROR: '+error.toString()));

    Map<String, DataHolder> uniqueVariants = {};
    for(Map map in variantResults) {
      String v = map['player_fighter_variant'];
      if(!uniqueVariants.keys.contains(v)) uniqueVariants.addAll({v : new DataHolder(v.substring(1, v.length - 1))});

      String r = map['result'];

      if(r == 'w') uniqueVariants[v].AddWin();
      else if(r == 'l') uniqueVariants[v].AddLoss();
    }

    String bestVariantTemp;
    double percWonAsBestVariant = 0.0;
    String worstVariantTemp;
    double percLostAsWorstVariant = 0.0;

      for(DataHolder dh in uniqueVariants.values)
      {
        double percWon = dh.winPerc;
        double percLost = dh.lossPerc;

        if(percWon > percWonAsBestVariant) {
          bestVariantTemp = dh.id as String;
          percWonAsBestVariant = percWon;
        }
        if(percLost > percLostAsWorstVariant){
          worstVariantTemp = dh.id as String;
          percLostAsWorstVariant = percLost;
        }
      }


      bestVariant = bestVariantTemp;
      worstVariant = worstVariantTemp;
      winPercWithBestVariant = percWonAsBestVariant;
      lossPercWithWorstVariant = percLostAsWorstVariant;


  }
  // Data


  Future<int> _GetPlays(Object args) async {
    List out = await database.transaction((txn) =>
    txn.rawQuery('SELECT id FROM Data WHERE game = \"${game.name}\" and player_fighter = \"/$teamString/\"'
        + (selections == null ? '' : selections.GetSQLString())
        + ' GROUP BY player_fighter,vs,record_num')).catchError((error) => { print('ERROR:' + error.toString()) });;
    return out.length;
  }
  Future<int> _GetResult(Object args) async {
    List out = await database.transaction((txn) =>
    txn.rawQuery('SELECT id FROM Data WHERE game = \"${game.name}\" and player_fighter = \"/$teamString/\" and result=\"${args as String}\"'
        + (selections == null ? '' : selections.GetSQLString())
        + ' GROUP BY player_fighter,vs,record_num')).catchError((error) => { print('ERROR:' + error.toString()) });;
    return out.length;
  }

  String GetFractionWinsString() {
    if(wins == null || losses == null || wins + losses == 0) return '-';

    var nf = NumberFormat.percentPattern();
    return nf.format(GetFractionWins());
  }
  String GetFractionLossesString() {
    if(wins == null || losses == null || wins + losses == 0) return '-';
    var nf = NumberFormat.percentPattern();
    return nf.format(GetFractionLoss());
  }
  double GetFractionWins() => (wins == null || losses == null || wins + losses == 0) ? 0 : wins.toDouble() / (wins + losses);
  double GetFractionLoss() => (wins == null || losses == null || wins + losses == 0) ? 0 : losses.toDouble() / (wins + losses);

  String GetDrawString() {
    if(draws == null) return '-';
    return draws.toString() + ' draw' + (draws == 1 ? '' : 's');
  }

  String GetPlaysString() {
    return plays == null ? '-' : plays.toString() + ' play' + (plays == 1 ? '' : 's');
  }
  String GetBestMatchupString() {
    String out = '-';
    if(winPercAgainstBestMatchup == null) return out;
    NumberFormat nf = NumberFormat.percentPattern();
    return 'wins ' + nf.format(winPercAgainstBestMatchup);
  }

  String GetWorstMatchupString() {
    String out = '-';
    if(lossPercAgainstWorstMatchup == null) return out;
    NumberFormat nf = NumberFormat.percentPattern();
    return 'loses ' + nf.format(lossPercAgainstWorstMatchup);
  }

  String GetBestMatchup() => (bestMatchup == null) ? '-' : DataModel.StringFromList(bestMatchup, '/', false);
  String GetWorstMatchup()  => (worstMatchup == null) ? '-' : DataModel.StringFromList(worstMatchup, '/', false);
  List<FighterWinsLossesData> winsLossesData;
//Stepper
  bool MakeSeriesData() {
    winsLossesData = [
      new FighterWinsLossesData('L', losses, Colors.red),
      new FighterWinsLossesData('W', wins, Colors.green), //Color.fromARGB(255, 173, 235, 173)
    ];

    return wins != null && losses != null && wins + losses > 0;
  }

}

class GameViewFighterModel extends GameViewSubModel<Fighter>{

  @override
  List<Future<void>> GetFutures() {
    // TODO: implement GetFutures
    return [CalcPlays(), CalcWins(), CalcLosses(), CalcDraws(), CalcBestMatch(), CalcWorstMatch(), CalcBestAndWorstTeams(), CalcBestAndWorstVariants()];
  }

  GameViewFighterModel(Game game, Fighter fighter, Database database, Selections selections, RecordCollection rc) : super(game,fighter,database,selections,rc){}

  Future<void> CalcPlays() async {retry(1, _GetPlays, null).then((value) => plays = value); rc.Nudge();}
  Future<void> CalcWins() async { retry(1, _GetResult, 'w').then((value) => wins = value); MakeSeriesData(); rc.Nudge();}
  Future<void> CalcLosses() async {retry(1, _GetResult, 'l').then((value) => losses = value); MakeSeriesData(); rc.Nudge();}
  Future<void> CalcDraws() async {retry(1, _GetResult, 'd').then((value) => draws = value); rc.Nudge();}
  Future<void> CalcBestMatch() async {
    double maxWinPercent = 0;
    Fighter bestMatchupTemp = null;
    for (Fighter f in rc.rm.gameToFighterLookup[game].values) {
      int fighterWins;
      int fighterPlays;
      List fighterWinsList = await database.transaction((txn) =>
      txn.rawQuery(
          'SELECT id FROM Data WHERE game = \"${game.name}\" and player_fighter LIKE \"%/${data.name}/%\" and vs_fighter LIKE \"%/${f.name}/%\" and result=\"w\"'
              + (selections == null ? '' : selections.GetSQLString())
              + ' GROUP BY player,vs,record_num')).catchError((error) => { print('ERROR:' + error.toString()) });
      List fighterPlaysList = await database.transaction((txn) =>
      txn.rawQuery(
          'SELECT id FROM Data WHERE game = \"${game.name}\" and player_fighter LIKE \"%${data.name}/%\" and vs_fighter LIKE \"%/${f.name}/%\"'
              + (selections == null ? '' : selections.GetSQLString())
              + ' GROUP BY player,vs,record_num')).catchError((error) => { print('ERROR:' + error.toString()) });
      fighterWins = fighterWinsList.length;
      fighterPlays = fighterPlaysList.length;
      if ((fighterWins.toDouble()/fighterPlays) > maxWinPercent) {
        maxWinPercent = (fighterWins.toDouble()/fighterPlays);
        bestMatchupTemp = f;
      }
    }
    bestMatchup = bestMatchupTemp;
    winPercAgainstBestMatchup = maxWinPercent;
    rc.Nudge();
  }
  Future<void> CalcWorstMatch() async {// TODO Calculate best matchup
    double maxLossPercent = 0;
    Fighter worstMatchupTemp = null;
    for (Fighter f in rc.rm.gameToFighterLookup[game].values) {
      int fighterLoss;
      int fighterPlays;
      List fighterLossList = await database.transaction((txn) =>
      txn.rawQuery('SELECT id FROM Data WHERE game = \"${game.name}\" and player_fighter LIKE \"%/${data.name}/%\" and vs_fighter LIKE \"%/${f.name}/%\" and result=\"l\"'
          + (selections == null ? '' : selections.GetSQLString())
          + ' GROUP BY player,vs,record_num')).catchError((error) => {print('ERROR:' +  error.toString()) });
      List fighterPlaysList = await database.transaction((txn) =>
      txn.rawQuery(
          'SELECT id FROM Data WHERE game = \"${game.name}\" and player_fighter LIKE \"%/${data.name}/%\" and vs_fighter LIKE \"%/${f.name}/%\"'
              + (selections == null ? '' : selections.GetSQLString())
              + ' GROUP BY player,vs,record_num')).catchError((error) => { print('ERROR:' + error.toString()) });
      //fighterLoss = fighterLossList.isEmpty ? 0 : fighterLossList[0]['COUNT(*)'];
      fighterLoss = fighterLossList.length;
      fighterPlays = fighterPlaysList.length;
      //print(f.name + ' ' + (fighterLoss.toDouble()/fighterPlays).toString());
      if ((fighterLoss.toDouble()/fighterPlays) > maxLossPercent) {
        maxLossPercent = (fighterLoss.toDouble()/fighterPlays);
        worstMatchupTemp = f;
      }
    }
    worstMatchup = worstMatchupTemp;
    lossPercAgainstWorstMatchup = maxLossPercent;
    rc.Nudge();
  }
  Future<void> CalcBestAndWorstTeams() async{
    List<Future> futures = [];

    List distinctTeams = await database.transaction((txn) =>
    txn.rawQuery('SELECT DISTINCT player_fighter FROM Data WHERE game = \"${game.name}\" and player_fighter LIKE \"%/${data.name}/%\" and team=\'1\''
        + (selections == null ? '' : selections.GetSQLString())
        + '')).catchError((error) => { print('ERROR:' + error.toString()) });

    futures.add(_CalcBestTeam(distinctTeams));
    futures.add(_CalcWorstTeam(distinctTeams));

    Future.wait(futures);
  }
  Future<void> CalcBestAndWorstVariants() async {
   // List<String> vs = this.rc.rm.gameToFighterToVariantsLookup[game] == null ? [] : this.rc.rm.gameToFighterToVariantsLookup[game][fighter].toList();

    List<String> vs = List<String>.generate(data.GetFieldValue('Variations').length, (i) => data.GetFieldValue('Variations')[i].toString());
    if(vs.isEmpty) return;

    List<Future<Map<String,dynamic>>> futures = List<Future<Map<String,dynamic>>>();

    for(String v in vs)
      {
        futures.add(_CalcVariantResults(v));
      }

    String bestVariantTemp;
    double percWonAsBestVariant = 0.0;
    String worstVariantTemp;
    double percLostAsWorstVariant = 0.0;

    Future.wait(futures).then((list) async {

      for(Map map in list)
        {
          double percWon = map['wins%'];
          double percLost = map['loss%'];

          if(percWon > percWonAsBestVariant) {
            bestVariantTemp = map['v'];
            percWonAsBestVariant = percWon;
          }
            if(percLost > percLostAsWorstVariant){
              worstVariantTemp = map['v'];
              percLostAsWorstVariant = percLost;
            }
          }


      bestVariant = bestVariantTemp;
      worstVariant = worstVariantTemp;
      winPercWithBestVariant = percWonAsBestVariant;
      lossPercWithWorstVariant = percLostAsWorstVariant;
    });

  }

  Future<Map<String,dynamic>> _CalcVariantResults(String v) async {
    List possibleFighterVariantPairs = await
    database.transaction((txn) =>
        txn.rawQuery('SELECT player_fighter,player_fighter_variant,result FROM Data WHERE game = \"${game.name}\" and player_fighter LIKE \"%/${data.name}/%\" and player_fighter_variant LIKE \"%/$v/%\"'
        + (selections == null ? '' : selections.GetSQLString())
        + '')).catchError((error) => { print('ERROR:' + error.toString()) });


    List actualPairs = [];
    int plays = 0;
    int winCount = 0;
    int lossCount = 0;
    for(Map map in possibleFighterVariantPairs)
      {
        if(RecordsModel.StringToList(map['player_fighter'].toString(), '/').indexOf(data.name) == RecordsModel.StringToList(map['player_fighter_variant'].toString(), '/').indexOf(v)) {
          actualPairs.add(map);
          //print((map['v'].toString()??'') + ', ' + data.name + ', ' + map.toString());
          plays++;
          if(map['result'] == 'w')
            {
              winCount++;
            }
          else if(map['result'] == 'l')
            {
              lossCount++;
            }
        }
      }

    double winPerc = (winCount + lossCount == 0 ? 0 : winCount / (winCount + lossCount));
    double lossPerc = (winCount + lossCount == 0 ? 0 : lossCount / (winCount + lossCount));

    return {'v' : v, 'wins' : winCount, 'loss' : lossCount, 'wins%' : winPerc, 'loss%' : lossPerc};

  }
  Future<void> _CalcBestTeam(List<Map> distinctTeams) async {
    int maxTeamFightsWon = 0;
    String bestTeamString;
    for (Map teamMap in distinctTeams) {

      String team = teamMap.values.first;
      int fighterTeamWins;
      await database.transaction((txn) =>
          txn.rawQuery('SELECT id FROM Data WHERE game = \"${game.name}\" and player_fighter = \"$team\" and result=\"w\"'
          + (selections == null ? '' : selections.GetSQLString())
          + '')).then((value) => fighterTeamWins = value.length);

      if (fighterTeamWins > maxTeamFightsWon) {
        maxTeamFightsWon = fighterTeamWins;
        bestTeamString = team;
      }
    }
    if(bestTeamString != null) bestTeam = RecordsModel.TeamStringToList(bestTeamString, game, rc.rm);
    rc.Nudge();
  }
  Future<void> _CalcWorstTeam(List<Map> distinctTeams) async {
    int maxTeamFightsLost = 0;
    String worstTeamString;
    for (Map teamMap in distinctTeams) {

      String team = teamMap.values.first;
      int fighterTeamLosses;
      await database.transaction((txn) =>
          txn.rawQuery('SELECT id FROM Data WHERE game = \"${game.name}\" and player_fighter = \"$team\" and result=\"l\"'
          + (selections == null ? '' : selections.GetSQLString())
          + '')).then((value) =>  fighterTeamLosses = value.length);

      if (fighterTeamLosses > maxTeamFightsLost) {
        maxTeamFightsLost = fighterTeamLosses;
        worstTeamString = team;
      }
    }
    if(worstTeamString != null) worstTeam = RecordsModel.TeamStringToList(worstTeamString, game, rc.rm);
    rc.Nudge();
  }
  Future<int> _GetPlays(Object args) async {
    List out = await database.transaction((txn) =>
      txn.rawQuery('SELECT id FROM Data WHERE game = \"${game.name}\" and player_fighter LIKE \"%/${data.name}/%"'
          + (selections == null ? '' : selections.GetSQLString())
          + ' GROUP BY player_fighter,vs,record_num')).catchError((error) => { print('ERROR:' + error.toString()) });
    return out.length;
  }
  Future<int> _GetResult(Object args) async {
    List out = await database.transaction((txn) =>
        txn.rawQuery('SELECT id FROM Data WHERE game = \"${game.name}\" and player_fighter LIKE \"/%${data.name}/%" and result=\"${args as String}\"'
        + (selections == null ? '' : selections.GetSQLString())
        + ' GROUP BY player_fighter,vs,record_num')).catchError((error) => { print('ERROR:' + error.toString()) });;
    return out.length;
  }

  List<FighterWinsLossesData> winsLossesData;

  bool MakeSeriesData() {
    winsLossesData = [
      new FighterWinsLossesData('L', losses, Colors.red),
      new FighterWinsLossesData('W', wins, Colors.green), //Color.fromARGB(255, 173, 235, 173)
    ];

    return wins != null && losses != null && wins + losses > 0;
  }

  String GetFractionWinsString() {
    if(wins == null || losses == null || wins + losses == 0) return '-';

    var nf = NumberFormat.percentPattern();
    return nf.format(GetFractionWins());
  }
  String GetFractionLossesString() {
    if(wins == null || losses == null || wins + losses == 0) return '-';
    var nf = NumberFormat.percentPattern();
    return nf.format(GetFractionLoss());
  }
  double GetFractionWins() => (wins == null || losses == null || wins + losses == 0) ? 0 : wins.toDouble() / (wins + losses);
  double GetFractionLoss() => (wins == null || losses == null || wins + losses == 0) ? 0 : losses.toDouble() / (wins + losses);

  String GetDrawString() {
    if(draws == null) return '-';
    return draws.toString() + ' draw' + (draws == 1 ? '' : 's');
  }

  String GetPlaysString() {
    return plays == null ? '-' : plays.toString() + ' play' + (plays == 1 ? '' : 's');
  }

  String GetBestMatchupString() {
    String out = '-';
    if(winPercAgainstBestMatchup == null) return out;
    NumberFormat nf = NumberFormat.percentPattern();
    return 'wins ' + nf.format(winPercAgainstBestMatchup);
  }

  String GetWorstMatchupString() {
    String out = '-';
    if(lossPercAgainstWorstMatchup == null) return out;
    NumberFormat nf = NumberFormat.percentPattern();
    return 'loses ' + nf.format(lossPercAgainstWorstMatchup);
  }



}




class FighterWinsLossesData {
  static String win = 'W';
  static String loss = 'L';
  final String tag;
  final int val;
  final charts.Color color;
  FighterWinsLossesData(this.tag,this.val, Color color)
      : this.color = new charts.Color(r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

class SQLInput {
  Game g;
  Format f;
  List<Player> ps = [];
  Map<Player,int> playerToPosition = {};
  Map<Player,List<Fighter>> playerToFighters = {};
  Map<Player,Map<Fighter, String>> playerToFightersToVariants = {};

  SQLInput(this.g,this.f,
      this.ps,this.playerToPosition,this.playerToFighters,this.playerToFightersToVariants) {}

      @override
  String toString() {
//    return g.toString() + ' ' + f.toString()
//        + '\n' + ps.toString()
//        + '\n' + playerToPosition.toString()
//        + '\n' + playerToFighters.toString()
//        + '\n' + playerToFightersToVariants.toString();
  }
}


/*
Builds subjective model based on records, along with data etc.
WILL NOT ATTEMPT TO SERIALIZE
 */
class RecordsModel
{
  // INPUTS and DATA OBJECTS
  RecordCollection recordCollection;

  List<Game> games = [];
  List<Player> players = [];

  Map<String, Game> gameLookup = {};
  Map<Game, Map<String, Format>> gameToFormatLookup = {};
  Map<Game, Map<String, Fighter>> gameToFighterLookup = {};
  Map<Game, Map<Fighter, Iterable<String>>> gameToFighterToVariantsLookup = {};
  Map<String, Player> playerLookup = {};
  Map<Game, Map<String, List<Fighter>>> gameToTeamLookup = {}; // TODO For variants also?

  // OUTCOMES
  List<SQLInput> sqlInputs = [];

  RecordsModel(this.recordCollection);

  /*
  Figure out what games, formats, players, fighters and variants exist. TODO index results?
   */
  SQLInput AddToModel(Record r)
  {
      String gameName = r.GamePlayed.name;
      Game g;
      Format f;
      List<Player> ps = [];
      Map<Player,int> playerToPosition = {};
      Map<Player,List<Fighter>> playerToFighters = {};
      Map<Player,Map<Fighter, String>> playerToFightersToVariants = {};

      if(gameLookup.containsKey(gameName))
      {
        // Fetch existing game
        g = gameLookup[gameName];

        // Try to fetch format
        if(gameToFormatLookup[g].containsKey(r.FormatPlayed.name))
        {
          f = gameToFormatLookup[g][r.FormatPlayed.name];
        }
      }
      else
      {
        // Add new game
        g = new Game(r.GamePlayed.name, r.GamePlayed.CloneFields());

        games.add(g);
        gameLookup.addAll({ gameName : g });
        gameToFormatLookup.addAll({ g : {} });
        gameToFighterLookup.addAll({ g : {} });
      }

      // If format uninitialised, create new one
      if(f == null)
      {
        f = Format(r.FormatPlayed.name, r.FormatPlayed.CloneFields());

        g.AddFormat(f);
        gameToFormatLookup[g].addAll({ f.name : f });
      }

      for(int i = 0; i < r.Podium.length; i++) // For each list of players in each podium position
          {
        int position = i + 1; // TODO Use position

        for(RPlayer rPlayerPlayed in r.Podium[i]) // For each player in that podium position
          {
          // The PLAYER
          Player p;

          // Try to fetch player
          if(playerLookup.containsKey(rPlayerPlayed.name))
          {
            p = playerLookup[rPlayerPlayed.name];
          }
          else // Add new player
              {
            p = new Player(rPlayerPlayed.name, []);

            players.add(p);
            playerLookup.addAll({p.name : p});
          }

          playerToPosition.addAll({p : position});
          ps.add(p);

          // The FIGHTER(s)
          playerToFighters.addAll({p : []});
          playerToFightersToVariants.addAll({p : {}});

          for(RFighter rFighterPlayed in rPlayerPlayed.Fighters)
          {
            Fighter f;
            //gameToFighterLookup.containsKey(g) ? print('CONTAINS ${g.name}') : () => null;
            if(gameToFighterLookup[g].containsKey(rFighterPlayed.name))
            {
              f = gameToFighterLookup[g][rFighterPlayed.name];
            }
            else
            {
              f = new Fighter(rFighterPlayed.name, [Field('Variations', [], 0)]);

              gameToFighterLookup[g].addAll({ f.name : f });
            }

            playerToFighters[p].add(f);

            // The VARIANT
            if(rFighterPlayed.v != null)
            {
              f.AddVariation(rFighterPlayed.v); // Avoids duplicating by itself
              playerToFightersToVariants[p].addAll({f : rFighterPlayed.v});
            }
            else
              {
                playerToFightersToVariants[p].addAll({f : null});
              }
          }

          // The TEAM(s), if it exists
          if(rPlayerPlayed.Fighters.length > 1)
            {
              String teamString = DataModel.StringFromList(playerToFighters[p], '/', true);

              if(!gameToTeamLookup.containsKey(g)) gameToTeamLookup.addAll({g : {}});
              if(!gameToTeamLookup[g].containsKey(teamString)) gameToTeamLookup[g].addAll({ teamString : playerToFighters[p] });
            }
        }
      } // All info acquired

      SQLInput sqli = SQLInput(g, f, ps, playerToPosition, playerToFighters, playerToFightersToVariants);
      sqlInputs.add(sqli);

      return sqli;
  }



  static List<Fighter> TeamStringToList(String teamString, Game game, RecordsModel rm) {

    if(teamString == '') return [];

    // Trim ends
    String str = teamString;//.substring(1, teamString.length - 2);

    List<String> list = str.split('/');
    list.removeWhere((element) => element == '');

    List<Fighter> outList = [];

    for(String fs in list)
    {
      outList.add(rm.gameToFighterLookup[game][fs]);
    }

    return outList;

  }
  static List StringToList(String s, String delim) {

    if(s == '') return [];

    List<String> list = s.split(delim);
    list.removeWhere((element) => element == '');

    return list;
  }
}

typedef Future<T> FutureGenerator<T>(Object args);
Future<T> retry<T>(int retries, FutureGenerator aFuture, Object args) async {
  try {
    return await aFuture(args);
  } catch (e) {
    if (retries > 1) {
      return retry(retries - 1, aFuture, args);
    }

    rethrow;
  }
}
