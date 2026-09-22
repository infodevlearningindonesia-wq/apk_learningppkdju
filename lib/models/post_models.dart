// To parse this JSON data, do
//
//     final postModels = postModelsFromJson(jsonString);

import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'post_models.g.dart';

List<PostModels> postModelsFromJson(String str) => List<PostModels>.from(json.decode(str).map((x) => PostModels.fromJson(x)));

String postModelsToJson(List<PostModels> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@JsonSerializable()
class PostModels {
    @JsonKey(name: "userId")
    final int? userId;
    @JsonKey(name: "id")
    final int? id;
    @JsonKey(name: "title")
    final String? title;
    @JsonKey(name: "body")
    final String? body;

    PostModels({
        this.userId,
        this.id,
        this.title,
        this.body,
    });

    factory PostModels.fromJson(Map<String, dynamic> json) => _$PostModelsFromJson(json);

    Map<String, dynamic> toJson() => _$PostModelsToJson(this);
}
