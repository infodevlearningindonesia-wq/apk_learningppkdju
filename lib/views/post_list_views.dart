// To parse this JSON data, do
//
//     final harrypotter = harrypotterFromJson(jsonString);

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

import '../models/post_models.dart' as post_models;
import '../services/api_services.dart';

part 'post_list_views.g.dart';

class PostListView extends StatefulWidget {
  const PostListView({super.key});

  @override
  State<PostListView> createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView> {
  final TextEditingController _searchController = TextEditingController();
  late Future<post_models.PostModels> _charactersFuture;

  Future<post_models.PostModels> _fetchCharacters() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.potterdb.com/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    return ApiService(dio).getCharacters();
  }

  Future<void> _refreshCharacters() async {
    setState(() {
      _charactersFuture = _fetchCharacters();
    });
    await _charactersFuture;
  }

  @override
  void initState() {
    super.initState();
    _charactersFuture = _fetchCharacters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<post_models.Datum> _filterCharacters(List<post_models.Datum> characters) {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return characters;
    }

    return characters.where((item) {
      final name = item.attributes?.name?.toLowerCase() ?? '';
      final house = item.attributes?.house?.toLowerCase() ?? '';
      return name.contains(query) || house.contains(query);
    }).toList();
  }

  Widget _buildCharacterList(List<post_models.Datum> filteredCharacters) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari nama atau house',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshCharacters,
            child: filteredCharacters.isEmpty
                ? const Center(child: Text('Tidak ada data yang cocok'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredCharacters.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filteredCharacters[index];
                      final name = item.attributes?.name ?? 'Unknown';
                      final house = item.attributes?.house ?? 'Unknown';
                      final imageUrl = item.attributes?.image;

                      return Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CharacterDetailScreen(
                                  character: item,
                                ),
                              ),
                            );
                          },
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: imageUrl != null && imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 52,
                                      height: 52,
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                      child: const Icon(Icons.person),
                                    ),
                                  )
                                : Container(
                                    width: 52,
                                    height: 52,
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    child: const Icon(Icons.person),
                                  ),
                          ),
                          title: Text(name),
                          subtitle: Text('House: $house'),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harry Potter'),
      ),
      body: FutureBuilder<post_models.PostModels>(
        future: _charactersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat data: ${snapshot.error}'),
            );
          }

          final characters = snapshot.data?.data ?? const <post_models.Datum>[];
          final filteredCharacters = _filterCharacters(characters);
          return _buildCharacterList(filteredCharacters);
        },
      ),
    );
  }
}

class CharacterDetailScreen extends StatelessWidget {
  final post_models.Datum character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    final attributes = character.attributes;
    final imageUrl = attributes?.image;
    final name = attributes?.name ?? 'Unknown';
    final house = attributes?.house ?? 'Unknown';
    final species = attributes?.species ?? 'Unknown';
    final bloodStatus = attributes?.bloodStatus ?? 'Unknown';
    final gender = attributes?.gender ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 180,
                        height: 180,
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: const Icon(Icons.person, size: 60),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            _InfoTile(label: 'Name', value: name),
            _InfoTile(label: 'House', value: house),
            _InfoTile(label: 'Species', value: species),
            _InfoTile(label: 'Blood Status', value: bloodStatus),
            _InfoTile(label: 'Gender', value: gender),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

Harrypotter harrypotterFromJson(String str) => Harrypotter.fromJson(json.decode(str));

String harrypotterToJson(Harrypotter data) => json.encode(data.toJson());

@JsonSerializable()
class Harrypotter {
    @JsonKey(name: "data")
    final List<Datum>? data;
    @JsonKey(name: "meta")
    final Meta? meta;
    @JsonKey(name: "links")
    final HarrypotterLinks? links;

    Harrypotter({
        this.data,
        this.meta,
        this.links,
    });

    factory Harrypotter.fromJson(Map<String, dynamic> json) => _$HarrypotterFromJson(json);

    Map<String, dynamic> toJson() => _$HarrypotterToJson(this);
}

@JsonSerializable()
class Datum {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "type")
    final String? type;
    @JsonKey(name: "attributes")
    final Attributes? attributes;
    @JsonKey(name: "links")
    final DatumLinks? links;

    Datum({
        this.id,
        this.type,
        this.attributes,
        this.links,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => _$DatumFromJson(json);

    Map<String, dynamic> toJson() => _$DatumToJson(this);
}

@JsonSerializable()
class Attributes {
    @JsonKey(name: "slug")
    final String? slug;
    @JsonKey(name: "alias_names")
    final List<dynamic>? aliasNames;
    @JsonKey(name: "animagus")
    final dynamic animagus;
    @JsonKey(name: "blood_status")
    final String? bloodStatus;
    @JsonKey(name: "boggart")
    final dynamic boggart;
    @JsonKey(name: "born")
    final String? born;
    @JsonKey(name: "died")
    final String? died;
    @JsonKey(name: "eye_color")
    final String? eyeColor;
    @JsonKey(name: "family_members")
    final List<String>? familyMembers;
    @JsonKey(name: "gender")
    final String? gender;
    @JsonKey(name: "hair_color")
    final String? hairColor;
    @JsonKey(name: "height")
    final dynamic height;
    @JsonKey(name: "house")
    final String? house;
    @JsonKey(name: "image")
    final String? image;
    @JsonKey(name: "jobs")
    final List<dynamic>? jobs;
    @JsonKey(name: "marital_status")
    final dynamic maritalStatus;
    @JsonKey(name: "name")
    final String? name;
    @JsonKey(name: "nationality")
    final String? nationality;
    @JsonKey(name: "patronus")
    final dynamic patronus;
    @JsonKey(name: "romances")
    final List<dynamic>? romances;
    @JsonKey(name: "skin_color")
    final String? skinColor;
    @JsonKey(name: "species")
    final String? species;
    @JsonKey(name: "titles")
    final List<dynamic>? titles;
    @JsonKey(name: "wands")
    final List<dynamic>? wands;
    @JsonKey(name: "weight")
    final dynamic weight;
    @JsonKey(name: "wiki")
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

    factory Attributes.fromJson(Map<String, dynamic> json) => _$AttributesFromJson(json);

    Map<String, dynamic> toJson() => _$AttributesToJson(this);
}

@JsonSerializable()
class DatumLinks {
    @JsonKey(name: "self")
    final String? self;

    DatumLinks({
        this.self,
    });

    factory DatumLinks.fromJson(Map<String, dynamic> json) => _$DatumLinksFromJson(json);

    Map<String, dynamic> toJson() => _$DatumLinksToJson(this);
}

@JsonSerializable()
class HarrypotterLinks {
    @JsonKey(name: "self")
    final String? self;
    @JsonKey(name: "current")
    final String? current;
    @JsonKey(name: "next")
    final String? next;
    @JsonKey(name: "last")
    final String? last;

    HarrypotterLinks({
        this.self,
        this.current,
        this.next,
        this.last,
    });

    factory HarrypotterLinks.fromJson(Map<String, dynamic> json) => _$HarrypotterLinksFromJson(json);

    Map<String, dynamic> toJson() => _$HarrypotterLinksToJson(this);
}

@JsonSerializable()
class Meta {
    @JsonKey(name: "pagination")
    final Pagination? pagination;
    @JsonKey(name: "copyright")
    final String? copyright;
    @JsonKey(name: "generated_at")
    final DateTime? generatedAt;

    Meta({
        this.pagination,
        this.copyright,
        this.generatedAt,
    });

    factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);

    Map<String, dynamic> toJson() => _$MetaToJson(this);
}

@JsonSerializable()
class Pagination {
    @JsonKey(name: "current")
    final int? current;
    @JsonKey(name: "next")
    final int? next;
    @JsonKey(name: "last")
    final int? last;
    @JsonKey(name: "records")
    final int? records;

    Pagination({
        this.current,
        this.next,
        this.last,
        this.records,
    });

    factory Pagination.fromJson(Map<String, dynamic> json) => _$PaginationFromJson(json);

    Map<String, dynamic> toJson() => _$PaginationToJson(this);
}
