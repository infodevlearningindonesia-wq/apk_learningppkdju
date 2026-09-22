// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModels _$PostModelsFromJson(Map<String, dynamic> json) => PostModels(
  userId: (json['userId'] as num?)?.toInt(),
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  body: json['body'] as String?,
);

Map<String, dynamic> _$PostModelsToJson(PostModels instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
    };
