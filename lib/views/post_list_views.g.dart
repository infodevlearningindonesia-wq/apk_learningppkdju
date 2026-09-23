// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_list_views.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Harrypotter _$HarrypotterFromJson(Map<String, dynamic> json) => Harrypotter(
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => Datum.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'] == null
      ? null
      : Meta.fromJson(json['meta'] as Map<String, dynamic>),
  links: json['links'] == null
      ? null
      : HarrypotterLinks.fromJson(json['links'] as Map<String, dynamic>),
);

Map<String, dynamic> _$HarrypotterToJson(Harrypotter instance) =>
    <String, dynamic>{
      'data': instance.data,
      'meta': instance.meta,
      'links': instance.links,
    };

Datum _$DatumFromJson(Map<String, dynamic> json) => Datum(
  id: json['id'] as String?,
  type: json['type'] as String?,
  attributes: json['attributes'] == null
      ? null
      : Attributes.fromJson(json['attributes'] as Map<String, dynamic>),
  links: json['links'] == null
      ? null
      : DatumLinks.fromJson(json['links'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DatumToJson(Datum instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'attributes': instance.attributes,
  'links': instance.links,
};

Attributes _$AttributesFromJson(Map<String, dynamic> json) => Attributes(
  slug: json['slug'] as String?,
  aliasNames: json['alias_names'] as List<dynamic>?,
  animagus: json['animagus'],
  bloodStatus: json['blood_status'] as String?,
  boggart: json['boggart'],
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
  jobs: json['jobs'] as List<dynamic>?,
  maritalStatus: json['marital_status'],
  name: json['name'] as String?,
  nationality: json['nationality'] as String?,
  patronus: json['patronus'],
  romances: json['romances'] as List<dynamic>?,
  skinColor: json['skin_color'] as String?,
  species: json['species'] as String?,
  titles: json['titles'] as List<dynamic>?,
  wands: json['wands'] as List<dynamic>?,
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

DatumLinks _$DatumLinksFromJson(Map<String, dynamic> json) =>
    DatumLinks(self: json['self'] as String?);

Map<String, dynamic> _$DatumLinksToJson(DatumLinks instance) =>
    <String, dynamic>{'self': instance.self};

HarrypotterLinks _$HarrypotterLinksFromJson(Map<String, dynamic> json) =>
    HarrypotterLinks(
      self: json['self'] as String?,
      current: json['current'] as String?,
      next: json['next'] as String?,
      last: json['last'] as String?,
    );

Map<String, dynamic> _$HarrypotterLinksToJson(HarrypotterLinks instance) =>
    <String, dynamic>{
      'self': instance.self,
      'current': instance.current,
      'next': instance.next,
      'last': instance.last,
    };

Meta _$MetaFromJson(Map<String, dynamic> json) => Meta(
  pagination: json['pagination'] == null
      ? null
      : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
  copyright: json['copyright'] as String?,
  generatedAt: json['generated_at'] == null
      ? null
      : DateTime.parse(json['generated_at'] as String),
);

Map<String, dynamic> _$MetaToJson(Meta instance) => <String, dynamic>{
  'pagination': instance.pagination,
  'copyright': instance.copyright,
  'generated_at': instance.generatedAt?.toIso8601String(),
};

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
  current: (json['current'] as num?)?.toInt(),
  next: (json['next'] as num?)?.toInt(),
  last: (json['last'] as num?)?.toInt(),
  records: (json['records'] as num?)?.toInt(),
);

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'current': instance.current,
      'next': instance.next,
      'last': instance.last,
      'records': instance.records,
    };
