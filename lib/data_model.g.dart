// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FighterVariantPairs _$FighterVariantPairsFromJson(Map json) {
  return FighterVariantPairs(
      (json['fighters'] as List)
          ?.map((e) => e == null
              ? null
              : Fighter.fromJson((e as Map)?.map(
                  (k, e) => MapEntry(k as String, e),
                )))
          ?.toList(),
      (json['variants'] as Map)?.map(
        (k, e) => MapEntry(k, e as String),
      ));
}

Map<String, dynamic> _$FighterVariantPairsToJson(FighterVariantPairs instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'fighters', instance.fighters?.map((e) => e?.toJson())?.toList());
  writeNotNull('variants', instance.variants);
  return val;
}

DataModel _$DataModelFromJson(Map json) {
  return DataModel()
    ..games = (json['games'] as List)
        ?.map((e) => e == null
            ? null
            : Game.fromJson((e as Map)?.map(
                (k, e) => MapEntry(k as String, e),
              )))
        ?.toList()
    ..players = (json['players'] as List)
        ?.map((e) => e == null
            ? null
            : Player.fromJson((e as Map)?.map(
                (k, e) => MapEntry(k as String, e),
              )))
        ?.toList()
    ..GameSelected = json['GameSelected'] == null
        ? null
        : Game.fromJson((json['GameSelected'] as Map)?.map(
            (k, e) => MapEntry(k as String, e),
          ))
    ..FormatSelected = json['FormatSelected'] == null
        ? null
        : Format.fromJson((json['FormatSelected'] as Map)?.map(
            (k, e) => MapEntry(k as String, e),
          ))
    ..PlayersSelected = (json['PlayersSelected'] as List)
        ?.map((e) => e == null
            ? null
            : Player.fromJson((e as Map)?.map(
                (k, e) => MapEntry(k as String, e),
              )))
        ?.toList()
    ..FightersSelected = (json['FightersSelected'] as Map)?.map(
      (k, e) => MapEntry(
          k,
          e == null
              ? null
              : FighterVariantPairs.fromJson((e as Map)?.map(
                  (k, e) => MapEntry(k as String, e),
                ))),
    )
    ..PlayerPodium = (json['PlayerPodium'] as List)
        ?.map((e) => e == null
            ? null
            : Player.fromJson((e as Map)?.map(
                (k, e) => MapEntry(k as String, e),
              )))
        ?.toList()
    ..PodiumIndices =
        (json['PodiumIndices'] as List)?.map((e) => e as int)?.toList()
    ..Page1Prompt = json['Page1Prompt'] as String
    ..Page2Prompt = json['Page2Prompt'] as String
    ..Page3Prompt = json['Page3Prompt'] as String
    ..Page4Prompt = json['Page4Prompt'] as String
    ..Page5Prompt = json['Page5Prompt'] as String;
}

Map<String, dynamic> _$DataModelToJson(DataModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('games', instance.games?.map((e) => e?.toJson())?.toList());
  writeNotNull('players', instance.players?.map((e) => e?.toJson())?.toList());
  writeNotNull('GameSelected', instance.GameSelected?.toJson());
  writeNotNull('FormatSelected', instance.FormatSelected?.toJson());
  writeNotNull('PlayersSelected',
      instance.PlayersSelected?.map((e) => e?.toJson())?.toList());
  writeNotNull('FightersSelected',
      instance.FightersSelected?.map((k, e) => MapEntry(k, e?.toJson())));
  writeNotNull(
      'PlayerPodium', instance.PlayerPodium?.map((e) => e?.toJson())?.toList());
  writeNotNull('PodiumIndices', instance.PodiumIndices);
  writeNotNull('Page1Prompt', instance.Page1Prompt);
  writeNotNull('Page2Prompt', instance.Page2Prompt);
  writeNotNull('Page3Prompt', instance.Page3Prompt);
  writeNotNull('Page4Prompt', instance.Page4Prompt);
  writeNotNull('Page5Prompt', instance.Page5Prompt);
  return val;
}

Field _$FieldFromJson(Map json) {
  return Field(json['name'] as String, json['value'], json['index'] as int)
    ..typeName = json['typeName'] as String
    ..optional = json['optional'] as bool
    ..descript = json['descript'] as String;
}

Map<String, dynamic> _$FieldToJson(Field instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('typeName', instance.typeName);
  writeNotNull('value', instance.value);
  writeNotNull('index', instance.index);
  writeNotNull('optional', instance.optional);
  writeNotNull('descript', instance.descript);
  return val;
}

Game _$GameFromJson(Map json) {
  return Game(
      json['name'] as String,
      (json['fields'] as List)
          ?.map((e) => e == null
              ? null
              : Field.fromJson((e as Map)?.map(
                  (k, e) => MapEntry(k as String, e),
                )))
          ?.toList())
    ..fieldIndexOf = (json['fieldIndexOf'] as Map)?.map(
      (k, e) => MapEntry(k as String, e as int),
    )
    ..customFields = (json['customFields'] as List)
        ?.map((e) => e == null
            ? null
            : Field.fromJson((e as Map)?.map(
                (k, e) => MapEntry(k as String, e),
              )))
        ?.toList()
    ..fieldsNum = json['fieldsNum'] as int
    ..formats = (json['formats'] as List)
        ?.map((e) => e == null
            ? null
            : Format.fromJson((e as Map)?.map(
                (k, e) => MapEntry(k as String, e),
              )))
        ?.toList()
    ..fighters = (json['fighters'] as List)
        ?.map((e) => e == null
            ? null
            : Fighter.fromJson((e as Map)?.map(
                (k, e) => MapEntry(k as String, e),
              )))
        ?.toList();
}

Map<String, dynamic> _$GameToJson(Game instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('fields', instance.fields?.map((e) => e?.toJson())?.toList());
  writeNotNull('fieldIndexOf', instance.fieldIndexOf);
  writeNotNull(
      'customFields', instance.customFields?.map((e) => e?.toJson())?.toList());
  writeNotNull('fieldsNum', instance.fieldsNum);
  writeNotNull('formats', instance.formats?.map((e) => e?.toJson())?.toList());
  writeNotNull(
      'fighters', instance.fighters?.map((e) => e?.toJson())?.toList());
  return val;
}

Format _$FormatFromJson(Map json) {
  return Format(
      json['name'] as String,
      (json['fields'] as List)
          ?.map((e) => e == null
              ? null
              : Field.fromJson((e as Map)?.map(
                  (k, e) => MapEntry(k as String, e),
                )))
          ?.toList())
    ..fieldIndexOf = (json['fieldIndexOf'] as Map)?.map(
      (k, e) => MapEntry(k as String, e as int),
    )
    ..customFields = (json['customFields'] as List)
        ?.map((e) => e == null
            ? null
            : Field.fromJson((e as Map)?.map(
                (k, e) => MapEntry(k as String, e),
              )))
        ?.toList()
    ..fieldsNum = json['fieldsNum'] as int;
}

Map<String, dynamic> _$FormatToJson(Format instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('fields', instance.fields?.map((e) => e?.toJson())?.toList());
  writeNotNull('fieldIndexOf', instance.fieldIndexOf);
  writeNotNull(
      'customFields', instance.customFields?.map((e) => e?.toJson())?.toList());
  writeNotNull('fieldsNum', instance.fieldsNum);
  return val;
}

Player _$PlayerFromJson(Map json) {
  return Player(
      json['name'] as String,
      (json['fields'] as List)
          ?.map((e) => e == null
              ? null
              : Field.fromJson((e as Map)?.map(
                  (k, e) => MapEntry(k as String, e),
                )))
          ?.toList())
    ..fieldIndexOf = (json['fieldIndexOf'] as Map)?.map(
      (k, e) => MapEntry(k as String, e as int),
    )
    ..customFields = (json['customFields'] as List)
        ?.map((e) => e == null
            ? null
            : Field.fromJson((e as Map)?.map(
                (k, e) => MapEntry(k as String, e),
              )))
        ?.toList()
    ..fieldsNum = json['fieldsNum'] as int;
}

Map<String, dynamic> _$PlayerToJson(Player instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('fields', instance.fields?.map((e) => e?.toJson())?.toList());
  writeNotNull('fieldIndexOf', instance.fieldIndexOf);
  writeNotNull(
      'customFields', instance.customFields?.map((e) => e?.toJson())?.toList());
  writeNotNull('fieldsNum', instance.fieldsNum);
  return val;
}

RPlayer _$RPlayerFromJson(Map json) {
  return RPlayer(
      json['name'] as String,
      (json['Fighters'] as List)
          ?.map((e) => e == null
              ? null
              : RFighter.fromJson((e as Map)?.map(
                  (k, e) => MapEntry(k as String, e),
                )))
          ?.toList())
    ..fields = (json['fields'] as List)
        ?.map((e) => e == null
            ? null
            : Field.fromJson((e as Map)?.map(
                (k, e) => MapEntry(k as String, e),
              )))
        ?.toList()
    ..fieldIndexOf = (json['fieldIndexOf'] as Map)?.map(
      (k, e) => MapEntry(k as String, e as int),
    )
    ..customFields = (json['customFields'] as List)
        ?.map((e) => e == null
            ? null
            : Field.fromJson((e as Map)?.map(
                (k, e) => MapEntry(k as String, e),
              )))
        ?.toList()
    ..fieldsNum = json['fieldsNum'] as int;
}

Map<String, dynamic> _$RPlayerToJson(RPlayer instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('fields', instance.fields?.map((e) => e?.toJson())?.toList());
  writeNotNull('fieldIndexOf', instance.fieldIndexOf);
  writeNotNull(
      'customFields', instance.customFields?.map((e) => e?.toJson())?.toList());
  writeNotNull('fieldsNum', instance.fieldsNum);
  writeNotNull(
      'Fighters', instance.Fighters?.map((e) => e?.toJson())?.toList());
  return val;
}

Fighter _$FighterFromJson(Map json) {
  return Fighter(
      json['name'] as String,
      (json['fields'] as List)
          ?.map((e) => e == null
              ? null
              : Field.fromJson((e as Map)?.map(
                  (k, e) => MapEntry(k as String, e),
                )))
          ?.toList())
    ..fieldIndexOf = (json['fieldIndexOf'] as Map)?.map(
      (k, e) => MapEntry(k as String, e as int),
    )
    ..customFields = (json['customFields'] as List)
        ?.map((e) => e == null
            ? null
            : Field.fromJson((e as Map)?.map(
                (k, e) => MapEntry(k as String, e),
              )))
        ?.toList()
    ..fieldsNum = json['fieldsNum'] as int;
}

Map<String, dynamic> _$FighterToJson(Fighter instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('fields', instance.fields?.map((e) => e?.toJson())?.toList());
  writeNotNull('fieldIndexOf', instance.fieldIndexOf);
  writeNotNull(
      'customFields', instance.customFields?.map((e) => e?.toJson())?.toList());
  writeNotNull('fieldsNum', instance.fieldsNum);
  return val;
}

RFighter _$RFighterFromJson(Map json) {
  return RFighter(json['name'] as String, json['v'] as String)
    ..fields = (json['fields'] as List)
        ?.map((e) => e == null
            ? null
            : Field.fromJson((e as Map)?.map(
                (k, e) => MapEntry(k as String, e),
              )))
        ?.toList()
    ..fieldIndexOf = (json['fieldIndexOf'] as Map)?.map(
      (k, e) => MapEntry(k as String, e as int),
    )
    ..customFields = (json['customFields'] as List)
        ?.map((e) => e == null
            ? null
            : Field.fromJson((e as Map)?.map(
                (k, e) => MapEntry(k as String, e),
              )))
        ?.toList()
    ..fieldsNum = json['fieldsNum'] as int;
}

Map<String, dynamic> _$RFighterToJson(RFighter instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('fields', instance.fields?.map((e) => e?.toJson())?.toList());
  writeNotNull('fieldIndexOf', instance.fieldIndexOf);
  writeNotNull(
      'customFields', instance.customFields?.map((e) => e?.toJson())?.toList());
  writeNotNull('fieldsNum', instance.fieldsNum);
  writeNotNull('v', instance.v);
  return val;
}

Record _$RecordFromJson(Map json) {
  return Record()
    ..TimeLogged = json['TimeLogged'] == null
        ? null
        : DateTime.parse(json['TimeLogged'] as String)
    ..GamePlayed = json['GamePlayed'] == null
        ? null
        : Game.fromJson((json['GamePlayed'] as Map)?.map(
            (k, e) => MapEntry(k as String, e),
          ))
    ..FormatPlayed = json['FormatPlayed'] == null
        ? null
        : Format.fromJson((json['FormatPlayed'] as Map)?.map(
            (k, e) => MapEntry(k as String, e),
          ))
    ..Podium = (json['Podium'] as List)
        ?.map((e) => (e as List)
            ?.map((e) => e == null
                ? null
                : RPlayer.fromJson((e as Map)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )))
            ?.toList())
        ?.toList();
}

Map<String, dynamic> _$RecordToJson(Record instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('TimeLogged', instance.TimeLogged?.toIso8601String());
  writeNotNull('GamePlayed', instance.GamePlayed?.toJson());
  writeNotNull('FormatPlayed', instance.FormatPlayed?.toJson());
  writeNotNull(
      'Podium',
      instance.Podium?.map((e) => e?.map((e) => e?.toJson())?.toList())
          ?.toList());
  return val;
}
