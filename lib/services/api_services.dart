import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/post_models.dart';

part 'api_services.g.dart';

@RestApi(
  baseUrl: 'https://api.potterdb.com/v1',
)
abstract class ApiService {
  factory ApiService(Dio dio, {String? baseUrl}) = _ApiService;

  @GET('/characters')
  Future<PostModels> getCharacters();
}