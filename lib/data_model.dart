import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_model.g.dart';


@JsonSerializable()
class FighterVariantPairs {
  factory FighterVariantPairs.fromJson(Map<String, dynamic> json) => _$FighterVariantPairsFromJson(json);
  Map<String, dynamic> toJson() => _$FighterVariantPairsToJson(this);

  FighterVariantPairs.empty();
  FighterVariantPairs(this.fighters, this.variants);
  List<Fighter> fighters = [];
  Map<Object, String> variants = {};


}

@JsonSerializable()
class DataModel{
  factory DataModel.fromJson(Map<String, dynamic> json) => _$DataModelFromJson(json);
  Map<String, dynamic> toJson() => _$DataModelToJson(this);

  void DummyData()
  {
    ResetSelections();

    games.clear();
    players.clear();

    games = [
      Game("Ultimate Marvel vs Capcom 3", [Field('Nickname','UMVC3',0)]),
      Game("Street Fighter 4", [Field('Nickname','SF4',0)]),
      Game("Super Smash Bros Ultimate", [Field('Nickname','SSBU',0)])
    ];

    games[0].AddFormat(Format('Main',[Field('#Players', 2, 0),Field('#Fighters per Player', 3, 1)]));
    games[1].AddFormat(Format('Main',[Field('#Players', 2, 0),Field('#Fighters per Player', 1, 1)]));
    games[2].AddFormat(Format('1v1',[Field('#Players', 2, 0),Field('#Fighters per Player', 1, 1)]));
    games[2].AddFormat(Format('4-Player Free-for-all',[Field('#Players', 4, 0),Field('#Fighters per Player', 1, 1)]));

    games[0].AddFighter(Fighter("Haggar", [Field('Variations',['Lariat', 'Violent Ax'],0)]));
    games[0].AddFighter(Fighter("Hawkeye", [Field('Variations',['Triple Arrow'],0)]));
    games[0].AddFighter(Fighter("Ryu", [Field('Variations',['Hadouken', 'Tatsu', 'Shoryuken'],0)]));
    games[0].AddFighter(Fighter("Vergil", [Field('Variations',['Judgement cut', 'Rising sun', 'Rapid slash'],0)]));
    games[0].AddFighter(Fighter("Dr Doom", [Field('Variations',['Hidden missiles', 'Beam'],0)]));
    games[0].AddFighter(Fighter("Spiderman", [Field('Variations',[],0)]));
    games[0].AddFighter(Fighter("Magneto", [Field('Variations',['Beam'],0)]));

    games[1].AddFighter(Fighter("Ryu", []));
    games[1].AddFighter(Fighter("Ken", []));
    games[1].AddFighter(Fighter("Bison", []));
    games[1].AddFighter(Fighter("Sagat", []));
    games[1].AddFighter(Fighter("Chun-Li", []));

    games[2].AddFighter(Fighter("Mario", []));
    games[2].AddFighter(Fighter("Luigi", []));
    games[2].AddFighter(Fighter("Kirby", []));
    games[2].AddFighter(Fighter("DK", []));
    games[2].AddFighter(Fighter("Wario", []));

    players.add(Player("Alex", []));
    players.add(Player("Jason", []));
    players.add(Player("Samir", []));
    players.add(Player("Spongebob", []));
  }

  // Data objs
  List<Game> games = new List(); // Games contain Formats list
  List<Player> players = new List();

   // Data selections
   Game GameSelected;
   Format FormatSelected;
   List<Player> PlayersSelected = [];
   Map<Object, FighterVariantPairs> FightersSelected = {};

  List<Player> PlayerPodium = [];
  List<int> PodiumIndices = [];

  static int UP = 1;
  static int DOWN = -1;
  static int MOVE = 0;

  DataModel()
  {
    print("DataModel initialised");

    //DummyData();

    RefreshPrompts();
  }

  bool AddGame(Game game)
  {
    if(DataObj.CheckUniqueName(this.games, game))
      {
        games.add(game);
        return true;
      }
    else return false;
  }

  void SelectGame(int index) {
    if(index != games.indexOf(GameSelected))
      {
        FormatSelected = null;
        for(Object obj in FightersSelected.keys) FightersSelected[obj] = FighterVariantPairs.empty();
      }

    this.GameSelected = games[index];
  }

   void SelectFormat(int index) {
     if(FormatSelected != null && index != GameSelected.formats.indexOf(FormatSelected))
     {
        for(Object obj in FightersSelected.keys) FightersSelected[obj] = FighterVariantPairs.empty();
     }
    this.FormatSelected = GameSelected.formats[index];

  }

  int GetSelectionProgress() {

    int progress = -1;

    if(GameSelected != null) progress++;
    if(FormatSelected != null) progress++;
    if(FormatSelected != null && PlayersSelected.length > 0 && (PlayersSelected.length == FormatSelected.GetFieldValue('#Players'))) progress++;
    if(FormatSelected != null && PlayersSelected.length > 0 && FightersSelected.length == PlayersSelected.length) {
      bool allMatch = true;
      for(Player p in PlayersSelected) {
        if(FightersSelected[p].fighters.length != FormatSelected.GetFieldValue('#Fighters per Player')) allMatch = false;
      }
      if(allMatch) progress++;
      }

    return progress;
  }


  HasPlayerChosenSufficientFighters(Player player) {

    if(FightersSelected[player] == null || FightersSelected[player].fighters == null) return false;

    return (FightersSelected[player].fighters.length == FormatSelected.GetFieldValue('#Fighters per Player'));

  }


  int GetGameSelectedIndex() {return games.indexOf(GameSelected);}

   int GetFormatSelectedIndex() {
     return GameSelected.formats.indexOf(FormatSelected);
   }

  void TogglePlayerSelected(int index) {

    if(PlayersSelected.contains(players[index]))
      {
        PlayersSelected.remove(players[index]);
        PlayerPodium.remove(players[index]);
        if(FightersSelected.containsKey(players[index])) FightersSelected.remove(players[index] as Object);
      }
    else
      {
        PlayersSelected.add(players[index]);
        PlayerPodium.add(players[index]);
        FightersSelected.addAll({ players[index] : FighterVariantPairs.empty() });
      }

    RefreshPodiumIndices(0);

  }

  bool AddPlayer(Player player) {
    if(DataObj.CheckUniqueName(this.players, player))
      {
        players.add(player);
        return true;
      }
    else return false;
  }

  // Text prompts
  String Page1Prompt = "";
  String Page2Prompt = "";
  String Page3Prompt = "";
  String Page4Prompt = "";
  String Page5Prompt = "";

  void RefreshPrompts() {

    Page1Prompt = games.length == 0 ? "No games added, press \'+\' button above to add a game" : "";

    Page2Prompt = GameSelected == null ? "No game selected" :
    GameSelected.formats.length == 0 ? "No formats added for "+ GameSelected.GetFieldValue('Nickname') +", press \'+\' button above to add a format" : "";

    Page3Prompt = players.length == 0 ? "No players added, press \'+\' button above to add a player" : "";

    Page4Prompt = GameSelected == null ? "No game selected" :
    GameSelected.fighters.length == 0 ?  "No fighters added for "+GameSelected.GetFieldValue('Nickname') +", press \'+\' button above to add a fighter" :
    FormatSelected == null ? "No format selected for "+GameSelected.GetFieldValue('Nickname') :
    FormatSelected.GetFieldValue('#Players') > PlayersSelected.length ? "Insufficient players selected for "+GameSelected.GetFieldValue('Nickname') + " "+FormatSelected.name :
    FormatSelected.GetFieldValue('#Players') < PlayersSelected.length ? "Too many players selected for "+GameSelected.GetFieldValue('Nickname') + " "+FormatSelected.name :
    "";

    bool allMatch = true;
    if(FormatSelected != null)
      {
        for(Player p in PlayersSelected) {
          if(!FightersSelected.containsKey(p)
              || FightersSelected[p].fighters == null
                  || FightersSelected[p].fighters.length != FormatSelected.GetFieldValue('#Fighters per Player')) allMatch = false;
        }
      }

    Page5Prompt =
    GameSelected == null ? "Unable to add data until a game is selected" :
    FormatSelected == null ? "Unable to add data until a game format is selected" :
    PlayersSelected.length != FormatSelected.GetFieldValue('#Players') ? "Unable to add data until correct number of players are selected" :
    !allMatch ? "Unable to add data until correct number of fighters are selected" : "";

  }

  String GetPlayerSelectionPrompt(int i) {
    return (!PlayersSelected.contains(players[i]) ? "" : // Check that player is selected
    ' (' + (1 + PlayersSelected.indexOf(players[i])).toString() // Return index within "PlayerSelected"
        + '/' + (FormatSelected == null ? '?' : FormatSelected.GetFieldValue('#Players').toString()) // Return number of players required for format, if exists
        + ')'
    );
  }

  String GetFightersPromptForPlayer(Player p) {

    String text = "";
    try {
      List<Fighter> fighters = FightersSelected[p].fighters;
      Map<Fighter, String> variants = Map<Fighter, String>.from(
          FightersSelected[p].variants);

      for (Fighter f in fighters) {
        text += f.name +
            (!variants.containsKey(f) ? "" : " (" + variants[f] + ")")
            + (fighters.indexOf(f) < fighters.length - 1 ? '\n' : '');
      }
    }catch(e) { }
    if(text == "") text = "[ choose your fighter(s) ]";

    return text;
  }

  bool AddFighter(Fighter fighter) {
    if(GameSelected != null) return GameSelected.AddFighter(fighter);
    else return false;
  }

  bool IsFighterSelectedByPlayer(int i, Player player) {
    return FightersSelected[player].fighters.contains(GameSelected.fighters[i]);
  }

  void ToggleFighterSelected(player, fighterIndex, variantIndex) {
    if(!FightersSelected[player].fighters.contains(GameSelected.fighters[fighterIndex])) // If fighter not currently selected...
      {
        if(IsSingleFighter()) // Reset previous
          {
            FightersSelected[player].fighters.clear();
            FightersSelected[player].variants.clear();
          }
        FightersSelected[player].fighters.add(GameSelected.fighters[fighterIndex]);
        if(variantIndex != null) FightersSelected[player].variants.addAll
          ({GameSelected.fighters[fighterIndex] : GameSelected.fighters[fighterIndex].GetFieldValue('Variations')[variantIndex] });

      }
    else
      {
        FightersSelected[player].fighters.remove(GameSelected.fighters[fighterIndex]);
        if(FightersSelected[player].variants.containsKey(GameSelected.fighters[fighterIndex]))
          {
            FightersSelected[player].variants.remove(GameSelected.fighters[fighterIndex]);
          }
      }

  }

  String GetFighterSelectionPrompt(Fighter fighter, Player player) {

    if(FightersSelected[player] == null || FightersSelected[player].fighters == null) return '';
    return FightersSelected[player].fighters.contains(fighter) ?
      ' (' + (FightersSelected[player].fighters.indexOf(fighter) + 1).toString()
          + '/' + FormatSelected.GetFieldValue('#Fighters per Player').toString() + ')'
      : '';
    }

  bool IsSingleFighter() {
    return FormatSelected.GetFieldValue('#Fighters per Player') == 1;
  }

  void MovePodiumPosition(Object obj, int type) {
    if(type == DataModel.UP || type == DataModel.DOWN)
      {
        int index = obj as int; // The index being affected

        Player p = PlayerPodium[index];
        PlayerPodium.remove(p);

        if(type == DataModel.UP) PlayerPodium.insert(max(0, index - 1), p);
        if(type == DataModel.DOWN) PlayerPodium.insert(min(index + 1, PlayerPodium.length), p);
      }
    else if (type == DataModel.MOVE)
      {
        List<int> oldToNew = obj as List<int>;
        int oldIndex = oldToNew[0]; // The index being affected
        int newIndex = oldToNew[1]; // The final position

        Player p = PlayerPodium[oldIndex];
        PlayerPodium.remove(p);
        PlayerPodium.insert(oldIndex < newIndex ? newIndex - 1 : newIndex, p);
      }
  }

  void TogglePodiumIndex(Object obj) {
    int index = obj as int;
    int val = PodiumIndices[index];

    if(index == 0)
      {
        RefreshPodiumIndices(0);
      }
    else if(index > 0)
      {

        if(val == 1) RefreshPodiumIndices(index);
    else if(val > PodiumIndices[index - 1]) // If podium position is strictly lower than that above it
      {
        for(int i = index; i < PodiumIndices.length; i++) // for itself and beneath
          {
          PodiumIndices[i] -= 1; // raise position
          }
      }
  }

  }

  void RefreshPodiumIndices(int startAt) {

    if(PodiumIndices.length != PlayersSelected.length) {

      PodiumIndices =
          List.generate(PlayersSelected.length, (index) => index + 1);
    }
    else
      {

        int j = 1;

        for(int i = startAt; i < PlayerPodium.length; i++)
        {
          PodiumIndices[i] = j;
          j++;
        }
      }
  }

  void ResetSelections() {
    GameSelected = null;
    FormatSelected = null;
    PlayersSelected.clear();
    FightersSelected.clear();
    PlayerPodium.clear();
    PodiumIndices.clear();

    RefreshPrompts();
    RefreshPodiumIndices(0);
  }

  String GetSelectionProgressText() {

    switch(GetSelectionProgress())
    {
      case -1:
    return 'Selecting game...';
        break;
      case 0:
        return '${GameSelected.GetFieldValue('Nickname')} => Selecting format...';
        break;
      case 1:
        return '${GameSelected.GetFieldValue('Nickname')} => ${FormatSelected.name} '
            '=> ${PlayersSelected.isNotEmpty ? StringFromList(PlayersSelected,', ',false) : 'Selecting players...'}';
        break;
      case 2:
        return '${GameSelected.GetFieldValue('Nickname')} => ${FormatSelected.name} => ${StringFromList(PlayersSelected,', ',false)} '
            '=> ${PlayersWithFightersString() != null ? PlayersWithFightersString() : 'Selecting fighters...'}';

        break;
      case 3:
        return '${GameSelected.GetFieldValue('Nickname')} => ${FormatSelected.name} => ${PlayersWithFightersString()} => READY';

        break;
      default:
    return '?';
        break;
    }
  }

  static bool isLast(Object o, List<Object> os) {return (os.indexOf(o) == (os.length - 1));}

  static String StringFromList(List<DataObj> list, String delim, bool surround) {

    if(list == null || list.isEmpty) return '';

    String text = surround ? delim : '';

        for(DataObj d in list)
        {
          try {
            text += d.name + (surround ? delim
                : (!DataModel.isLast(d, list) ? delim
                : ''));
          }catch(e){print('StringFromListError: '+e.toString());}
        }


    return text;
  }



  static String VariantList(List<Fighter> list, Map<Fighter,String> map, String delim) {

    //print(list.toString() + ' ' + map.toString());

    if(map == null || map.isEmpty)
      {
        return delim + ('-'+delim)*list.length;
      }

    String text = delim;

    for(Fighter f in list)
    {
      text += (map.containsKey(f) ? map[f].toString() : '-') + delim;
    }

    return text;
  }

  String PlayersWithFightersString() {

    bool anyNonEmpty = false;
    for(FighterVariantPairs fvp in FightersSelected.values)
      {
        if(fvp.fighters.isNotEmpty) anyNonEmpty = true;
      }
    if(!anyNonEmpty) return null;

    String text = '';
    for(Player p in PlayersSelected)
      {
        String fighterString = FightersSelected[p] != null ? StringFromList(FightersSelected[p].fighters,'/',false) : '?';
        text += p.name + ' (' + (fighterString == '' ? '?' : fighterString) + ')'
            + (PlayersSelected.indexOf(p) < PlayersSelected.length - 1 ? ', ' : '');
      }

    return text;

  }

  void RandomSelection() {

    ResetSelections();
    Random rand = Random();

    if(games.isEmpty)
      {
        AddGame(Game.Gen());
      }

    SelectGame(rand.nextInt(games.length));

    if(GameSelected.formats.isEmpty)
    {
      GameSelected.AddFormat(Format.Gen(GameSelected.GetFieldValue('Nickname')));
    }

    SelectFormat(rand.nextInt(GameSelected.formats.length));

    if(players.length < FormatSelected.GetFieldValue('#Players'))
      {
        int diff = FormatSelected.GetFieldValue('#Players') - players.length;
        for(int i = 0; i < diff; i++){ AddPlayer(Player.Gen(players.length + 1 + i));}
      }

    int numChosenPlayers = 0;
    while(numChosenPlayers < FormatSelected.GetFieldValue('#Players'))
      {
        int pNum = rand.nextInt(players.length);
        if(!PlayersSelected.contains(players[pNum]))
          {
            TogglePlayerSelected(pNum);
            numChosenPlayers++;
          }
      }

    if(GameSelected.fighters.length < FormatSelected.GetFieldValue('#Fighters per Player'))
    {
      int diff = FormatSelected.GetFieldValue('#Fighters per Player') - GameSelected.fighters.length;
      for(int i = 0; i < diff; i++){
        AddFighter(Fighter.Gen(GameSelected.fighters.length + 1 + i));}
    }

    for(Player p in PlayersSelected)
      {
        int numFighters = 0;
        while(numFighters < FormatSelected.GetFieldValue('#Fighters per Player'))
        {
          int fNum = rand.nextInt(GameSelected.fighters.length);
          if(!FightersSelected[p].fighters.contains(GameSelected.fighters[fNum]))
          {
            int vNum = null;
            if(GameSelected.fighters[fNum].GetFieldValue('Variations') != null) vNum = rand.nextInt(GameSelected.fighters[fNum].GetFieldValue('Variations').length);
            ToggleFighterSelected(p, fNum, vNum);
            numFighters++;
          }
        }
      }

    PlayerPodium.shuffle();

    if(rand.nextDouble() < 0.95) return;
    else
    { // Instance of a draw
      TogglePodiumIndex(rand.nextInt(PlayerPodium.length));
    }
  }

  String PlayerVariantSelectionText(Player player, Fighter fighter) {
    if(FightersSelected[player] != null
        && FightersSelected[player].variants.containsKey(fighter))
      {
        return FightersSelected[player].variants[fighter];
      }
    else return null;
  }
  }


/*
Base class for data objects.
 */
abstract class DataObj
{
  List<Field> GetRequiredFields() {
    throw Exception("REQUIRED FIELDS NOT STATED");
  }

  @override
  String toString() => this.name;

  static bool CheckUniqueName(List<DataObj> list, DataObj obj)
  {
    bool unique = true;
    for(DataObj d in list) {  if(d.name == obj.name) unique = false;  }
    return unique;
  }
  
  String name;

  List<Field> fields;
  Map<String,int> fieldIndexOf; // Lookup a field index based on its name

  List<Field> customFields;

  int fieldsNum;

  DataObj.Empty(String name) {}


  /*
  Map input assumed to obey required fields, with list fields of form 'fieldName : listSize' and list entries of form 'fieldName_{index} : value'
   */
  DataObj.Map(Map<String,dynamic> map)
  {
    this.name = map['Name'];

    fields = [];

    for(Field f in GetRequiredFields())
      {
        if(map.containsKey(f.name))
          {
            switch(f.typeName)
            {
              case Field.TYPE_STRING:
                AddField(Field(f.name, map[f.name], f.index));
                break;
              case Field.TYPE_INT:
                AddField(Field(f.name, map[f.name], f.index));
                break;
              case Field.TYPE_LIST:
                List<String> list = [];
                for(int i = 0; i < map[f.name]; i++) list.add(map[f.name + '_${i}']);
                AddField(Field(f.name, list.isNotEmpty ? list : null, f.index));
                break;

            }
          }
      }
  }

  DataObj(String name, List<Field> fields)
  {
    this.name = name;
    this.fields = fields;
    GenerateFieldLookup();

//    if(DataObj.validateFields(fields, GetRequiredFields()))
//      {
//
//      }
//    else
//      {
//        throw Exception('Illegal field arguments');
//      }

  }

  void GenerateFieldLookup()
  {
    fieldIndexOf = {};
    for(Field f in this.fields)
      {
        fieldIndexOf.addAll({f.name : f.index});
      }
  }

  void AddField(Field f)
  {
    if(fields == null) fields = [];
    if(fieldIndexOf == null) fieldIndexOf = {};
    fields.add(f);
    fieldIndexOf.addAll({f.name : fields.indexOf(f)});
  }

  dynamic GetFieldValue(String name)
  {
    if(!fieldIndexOf.containsKey(name)) return null;
    return fields[fieldIndexOf[name]].value;
  }

  void SetFieldsNumber()
  {
    fieldsNum = 0;
    if(fields != null)
      {
        fieldsNum += fields.length;
      }
    if(customFields != null)
      {
        fieldsNum += customFields.length;
      }
  }

  void AddCustomFields(List<Field> list)
  {
    // TODO: Implement
  }

  String GetFieldsBlockTexts(bool includeNames) {

    String text = '';

    if (fields != null) {
      for (Field f in fields) {
        if(includeNames) text += f.name + ": " + f.value.toString() + (fields.indexOf(f) < fields.length - 1 ? "\n" : "");
        else text += f.value.toString() + (fields.indexOf(f) < fields.length - 1 ? "\n" : "");
      }
    }

    return text;
  }

//  static bool validateFields(List<Field> fields, List<Field> requiredFields)
//  {
//    for(Field rf in requiredFields)
//    {
//      print('rf: ${rf.name}');
//    }
//    for(Field f in fields)
//    {
//      print('f: ${f.name}');
//    }
//
//    for(Field rf in requiredFields)
//      {
//        bool found = false;
//        bool opt = rf.optional;
//
//        print('Field: '+rf.name+', opt: '+opt.toString());
//
//        for(Field f in fields)
//        { // Checks if non-optional fields have a matching name and type
//          print(f.name);
//          if(f.name == rf.name)
//          {
//            //if(f.value.runtimeType.toString() == rf.typeName) {
//              found = true;
//            //}
//            }
//        }
//
//        if(!opt && !found) print('return 2'); return false; // If not optional AND not found, return false
//        }
//
//
//        return true;
//      }



  List<Field> CloneFields()
  {
    List<Field> newList = [];
    for(Field f in fields) newList.add(f.CloneField());
    return newList;
  }
}

/*
Defines properties to add to data objects.
 */
@JsonSerializable()
class Field
{
  factory Field.fromJson(Map<String, dynamic> json) => _$FieldFromJson(json);
  Map<String, dynamic> toJson() => _$FieldToJson(this);

  static const String TYPE_STRING = 'String';
  static const String TYPE_INT = 'int';
  static const String TYPE_LIST = 'List';

  String name;
  String typeName;
  dynamic value;

  int index;
  bool optional;

  String descript;

  Field.EmptyField(String name, String typeName, bool optional, String descript)
  {
    this.name = name;
    this.typeName = typeName;
    this.optional = optional;
    this.descript = descript;
  }

  Field(String name, dynamic value, int index)
  {
    this.name = name;
    this.value = value;
    this.index = index;
    this.optional = false;
  }

  Field.CustomField(String name, dynamic value, int index, bool optional)
  {
    this.name = name;
    this.value = value;
    this.index = index;
    this.optional = optional;
  }

  Field CloneField() {
    return Field(this.name, this.value, this.index);
  }
}


@JsonSerializable()
class Game extends DataObj {
  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  Map<String, dynamic> toJson() => _$GameToJson(this);

  Game.Map(Map<String, dynamic> map) : super.Map(map);

  @override
  List<Field> GetRequiredFields() {
    return [
      Field.EmptyField("Nickname", Field.TYPE_STRING, false, 'Short identifier or abbreviation.')
    ];
  }

  // Game-specific additions
  List<Format> formats = [];
  List<Fighter> fighters = [];

  void AddFormat(Format format)
  {
    formats.add(format);
  }

  bool AddFighter(Fighter fighter)
  {
    if(DataObj.CheckUniqueName(this.fighters, fighter))
      {
        fighters.add(fighter);
        return true;
      }else return false;
  }

  Game.EmptyGame() : super.Empty(''){}
  Game.Gen() : super('Generated Game', [Field('Nickname', 'G', 0)]) {}

  //Game(List<TextEditingController> tcs){ super.FromForm(tcs) }
  Game(String name, List<Field> fields): super(name, fields) {  }


}

@JsonSerializable()
class Format extends DataObj
{
  factory Format.fromJson(Map<String, dynamic> json) => _$FormatFromJson(json);
Map<String, dynamic> toJson() => _$FormatToJson(this);

  @override
  List<Field> GetRequiredFields() {
    return [
      Field.EmptyField("#Players", Field.TYPE_INT, false, 'Number of required players.'),
      Field.EmptyField("#Fighters per Player",  Field.TYPE_INT, false, 'Number of fighters in a player\'s unit. Usually 1, more for Team Fighters.')
    ];
  }

  Format.Map(Map<String, dynamic> map) : super.Map(map);
  Format.EmptyFormat() : super.Empty('') {}

  Format(String name, List<Field> fields): super(name, fields)
  {
    //CreateFieldsBlockTexts();
  }

  Format.Gen(String gameNickname) : super(gameNickname + ' Format (Generated)', [Field('#Players', 2, 0), Field('#Fighters per Player', 1, 1)]);


}

@JsonSerializable()
class Player extends DataObj
{
  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  Player.Map(Map<String, dynamic> map) : super.Map(map);

  @override
  List<Field> GetRequiredFields() { return [];  }

  Player(String name, List<Field> fields): super(name, fields) {}

  Player.EmptyPlayer() : super.Empty('') {}
  Player.Gen(int index) : super('Player ${index} (Generated)', []) {}
  /*
  FOR RECORDING PURPOSES ONLY
   */
 // List<Fighter> Fighters;

}

@JsonSerializable()
class RPlayer extends Player
{
  factory RPlayer.fromJson(Map<String, dynamic> json) => _$RPlayerFromJson(json);
  Map<String, dynamic> toJson() => _$RPlayerToJson(this);

  List<RFighter> Fighters;

  RPlayer(String name, List<RFighter> Fighters) : super(name, []) {this.Fighters = Fighters;}

}

@JsonSerializable()
class Fighter extends DataObj {
  factory Fighter.fromJson(Map<String, dynamic> json) => _$FighterFromJson(json);
  Map<String, dynamic> toJson() => _$FighterToJson(this);

  Fighter.Map(Map<String, dynamic> map) : super.Map(map);

  @override
  List<Field> GetRequiredFields() {
    return [
      Field.EmptyField("Variations",  Field.TYPE_LIST, true, 'If a fighter can take on variations, or take equipment into a fight, list here.')
    ];
  }

//  static bool ValidateVariationString(String text)
//  {
//    return true;
//  }
//
//  static List<String> CSVtoList(String csvText)
//  {
//    if(csvText == '') return null;
//
//    List<String> list = csvText.split(',');
//
//    // Check for repeats or blanks
//    if(list.length > 0) {
//      for (String s in list) {
//        if (s == "") throw Exception(
//            'Invalid variation member, must be non-blank');
//        String newS = s.trim();
//        list[list.indexOf(s)] = newS; // Replace with trimmed version
//      } // TODO Check for repeating members
//    }
//
//    return list;
//  }

  bool AddVariation(String v)
  {
    List vars = this.GetFieldValue('Variations');

    bool unique = true;
    if(vars != null) for(dynamic d in vars) if(d.toString() == v) unique = false;
    if(vars != null && unique) vars.add(v);

    return unique;
  }

  Fighter.EmptyFighter() : super.Empty('') {}
  Fighter(String name, List<Field> fields): super(name, fields) {}
  Fighter.Gen(int index) : super('Fighter ${index} (Generated)', [ Field('Variations',['Variant 1','Variant 2','Variant 3'],0) ]);
}

@JsonSerializable()
class RFighter extends Fighter{
  factory RFighter.fromJson(Map<String, dynamic> json) => _$RFighterFromJson(json);
  Map<String, dynamic> toJson() => _$RFighterToJson(this);

  RFighter(String name, String v) : super(name, []) {this.v = v;}

  String v; // Variant equipped
}


@JsonSerializable()
class Record
{
  @override
  String toString()
  {
    return(TimeLogged.toString()
        + '\n' + GamePlayed.GetFieldValue('Nickname') + ' ' + FormatPlayed.name
        + '\n' + GetPodiumString(Podium));
  }

  factory Record.fromJson(Map<String, dynamic> json) => _$RecordFromJson(json);
  Map<String, dynamic> toJson() => _$RecordToJson(this);

  DateTime TimeLogged;
  Game GamePlayed;
  Format FormatPlayed;
  List<List<RPlayer>> Podium;

  Record() {}

  /*
   Produces output podium (List of Player -> List of Fighter: [variant])
   */
  void GenerateRecord(DataModel data) {

    this.TimeLogged = DateTime.now();
    this.GamePlayed = Game(data.GameSelected.name, data.GameSelected.CloneFields());
    this.FormatPlayed = Format(data.FormatSelected.name, data.FormatSelected.CloneFields());

    // Determine the number of unique positions on podium
    int maxPos = 1;
    for(int pos in data.PodiumIndices)
      {
        if(pos > maxPos) maxPos = pos;
      }

    // Create and add players as we go
    Podium = List<List<RPlayer>>.generate(maxPos, (i) => []);

    for(int i = 0; i < data.PlayerPodium.length; i++)
      {
        FighterVariantPairs fvp = data.FightersSelected[data.PlayerPodium[i]];

        List<RFighter> Fighters = List<RFighter>.generate(fvp.fighters.length, (i)
        => RFighter(fvp.fighters[i].name,
            fvp.variants.containsKey(fvp.fighters[i]) ? fvp.variants[fvp.fighters[i]] : null
        ));

        RPlayer rp = RPlayer(data.PlayerPodium[i].name, Fighters);

        // Adds to output podium in the appropriate position
        Podium[data.PodiumIndices[i] - 1].add(rp);
      }

  }

  static String GetPodiumString(List<List<RPlayer>> podium) {

    String out = '';
    for (int i = 0; i < podium.length; i++)
      {
        out += (i + 1).toString() + ': ';

        for(RPlayer rp in podium[i])
          {
            out += rp.name + ' (' + DataModel.StringFromList(rp.Fighters, '/', false) + ')' + (DataModel.isLast(rp, podium[i]) ? '' : ', ');
          }

        out += (i == podium.length - 1 ? '' : '\n');
      }

    return out;

  }

  String GetSnackbarMessage() {
    if(Podium[0].length == 1) {return Podium[0][0].name + '\'s win recorded';}
    else
      {
        return 'Drawn game recorded';
        //return DataModel.StringFromList(Podium[0], ' & ', false) + ' draw recorded';
      }
  }


}