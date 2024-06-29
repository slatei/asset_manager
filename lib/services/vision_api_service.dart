import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:googleapis_auth/auth_io.dart';

// spell-checker: disable
const accountCredentialsJson = r'''
{
  "account": "",
  "client_id": "",
  "client_secret": "",
  "quota_project_id": "",
  "refresh_token": "",
  "type": "authorized_user",
  "universe_domain": "googleapis.com"
}
''';
// spell-checker: enable

class VisionApiService {
  final vision.VisionApi _visionApi;

  VisionApiService(this._visionApi);

  static Future<VisionApiService> create() async {
    final accountCredentials =
        ServiceAccountCredentials.fromJson(accountCredentialsJson);

    final httpClient = await clientViaServiceAccount(
        accountCredentials, [vision.VisionApi.cloudPlatformScope]);
    final visionApi = vision.VisionApi(httpClient);

    return VisionApiService(visionApi);
  }

  Future<vision.TextAnnotation?> detectText(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final request = vision.BatchAnnotateImagesRequest(
      requests: [
        vision.AnnotateImageRequest(
          image: vision.Image(content: base64Image),
          features: [vision.Feature(type: 'TEXT_DETECTION')],
        ),
      ],
    );

    final response = await _visionApi.images.annotate(request);
    return response.responses?.first.fullTextAnnotation;
  }
}
