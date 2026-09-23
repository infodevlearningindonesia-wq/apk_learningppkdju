// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModels _$PostModelsFromJson(Map<String, dynamic> json) => PostModels(
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => Datum.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PostModelsToJson(PostModels instance) =>
    <String, dynamic>{'data': instance.data};

Datum _$DatumFromJson(Map<String, dynamic> json) => Datum(
  id: json['id'] as String?,
  type: json['type'] as String?,
  attributes: json['attributes'] == null
      ? null
      : Attributes.fromJson(json['attributes'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DatumToJson(Datum instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'attributes': instance.attributes,
};

Attributes _$AttributesFromJson(Map<String, dynamic> json) => Attributes(
  slug: json['slug'] as String?,
  aliasNames: (json['alias_names'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  animagus: json['animagus'] as String?,
  bloodStatus: json['blood_status'] as String?,
  boggart: json['boggart'] as String?,
  born: json['born'] as String?,
  died: json['died'] as String?,
  eyeColor: json['eye_color'] as String?,
  familyMembers: (json['family_members'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  gender: json['gender'] as String?,
  hairColor: json['hair_color'] as String?,
  height: json['height'],
  house: json['house'] as String?,
  image: json['image'] as String?,
  jobs: (json['jobs'] as List<dynamic>?)?.map((e) => e as String).toList(),
  maritalStatus: json['marital_status'] as String?,
  name: json['name'] as String?,
  nationality: json['nationality'] as String?,
  patronus: json['patronus'] as String?,
  romances: (json['romances'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  skinColor: json['skin_color'] as String?,
  species: json['species'] as String?,
  titles: (json['titles'] as List<dynamic>?)?.map((e) => e as String).toList(),
  wands: json['wands'],
  weight: json['weight'],
  wiki: json['wiki'] as String?,
);

Map<String, dynamic> _$AttributesToJson(Attributes instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'alias_names': instance.aliasNames,
      'animagus': instance.animagus,
      'blood_status': instance.bloodStatus,
      'boggart': instance.boggart,
      'born': instance.born,
      'died': instance.died,
      'eye_color': instance.eyeColor,
      'family_members': instance.familyMembers,
      'gender': instance.gender,
      'hair_color': instance.hairColor,
      'height': instance.height,
      'house': instance.house,
      'image': instance.image,
      'jobs': instance.jobs,
      'marital_status': instance.maritalStatus,
      'name': instance.name,
      'nationality': instance.nationality,
      'patronus': instance.patronus,
      'romances': instance.romances,
      'skin_color': instance.skinColor,
      'species': instance.species,
      'titles': instance.titles,
      'wands': instance.wands,
      'weight': instance.weight,
      'wiki': instance.wiki,
    };
