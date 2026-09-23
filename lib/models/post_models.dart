import 'package:json_annotation/json_annotation.dart';

part 'post_models.g.dart';

@JsonSerializable()
class PostModels {
  final List<Datum>? data;

  PostModels({
    this.data,
  });

  factory PostModels.fromJson(Map<String, dynamic> json) =>
      _$PostModelsFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelsToJson(this);
}

@JsonSerializable()
class Datum {
  final String? id;
  final String? type;
  final Attributes? attributes;

  Datum({
    this.id,
    this.type,
    this.attributes,
  });

  factory Datum.fromJson(Map<String, dynamic> json) =>
      _$DatumFromJson(json);

  Map<String, dynamic> toJson() => _$DatumToJson(this);
}

@JsonSerializable()
class Attributes {
  final String? slug;

  @JsonKey(name: 'alias_names')
  final List<String>? aliasNames;

  final String? animagus;

  @JsonKey(name: 'blood_status')
  final String? bloodStatus;

  final String? boggart;
  final String? born;
  final String? died;

  @JsonKey(name: 'eye_color')
  final String? eyeColor;

  @JsonKey(name: 'family_members')
  final List<String>? familyMembers;

  final String? gender;

  @JsonKey(name: 'hair_color')
  final String? hairColor;

  final dynamic height;
  final String? house;
  final String? image;
  final List<String>? jobs;

  @JsonKey(name: 'marital_status')
  final String? maritalStatus;

  final String? name;
  final String? nationality;
  final String? patronus;
  final List<String>? romances;

  @JsonKey(name: 'skin_color')
  final String? skinColor;

  final String? species;
  final List<String>? titles;

  // Dibuat dynamic agar aman jika API mengirim
  // wands sebagai String maupun List.
  final dynamic wands;

  final dynamic weight;
  final String? wiki;

  Attributes({
    this.slug,
    this.aliasNames,
    this.animagus,
    this.bloodStatus,
    this.boggart,
    this.born,
    this.died,
    this.eyeColor,
    this.familyMembers,
    this.gender,
    this.hairColor,
    this.height,
    this.house,
    this.image,
    this.jobs,
    this.maritalStatus,
    this.name,
    this.nationality,
    this.patronus,
    this.romances,
    this.skinColor,
    this.species,
    this.titles,
    this.wands,
    this.weight,
    this.wiki,
  });

  factory Attributes.fromJson(Map<String, dynamic> json) =>
      _$AttributesFromJson(json);

  Map<String, dynamic> toJson() => _$AttributesToJson(this);
}