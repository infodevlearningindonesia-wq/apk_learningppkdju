import 'package:devlearning_indonesia/services/api_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/post_models.dart';

class PostListView extends StatefulWidget {
  const PostListView({super.key});

  @override
  State<PostListView> createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView> {
  final ApiService apiService = ApiService(Dio());

  late Future<PostModels> futureCharacters;

  @override
  void initState() {
    super.initState();
    futureCharacters = apiService.getCharacters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harry Potter Characters'),
      ),
      body: FutureBuilder<PostModels>(
        future: futureCharacters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('Data tidak ditemukan'),
            );
          }

          final result = snapshot.data!;
          final characters = result.data ?? [];

          if (characters.isEmpty) {
            return const Center(
              child: Text('Tidak ada karakter'),
            );
          }

          return ListView.builder(
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              final attributes = character.attributes;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: _characterImage(
                    attributes?.image,
                  ),
                  title: Text(
                    attributes?.name ?? 'Unknown',
                  ),
                  subtitle: Text(
                    attributes?.house ?? 'No House',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _characterImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const CircleAvatar(
        child: Icon(Icons.person),
      );
    }

    return CircleAvatar(
      backgroundImage: NetworkImage(imageUrl),
    );
  }
}