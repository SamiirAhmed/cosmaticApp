import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';

class ApiService {
  static String get baseUrl => ApiConstants.baseUrl; 

  static Future<Map<String, dynamic>> post(String route, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$route'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));
      
      return _processResponse(response);
    } on TimeoutException {
      return {'status': false, 'message': 'Request timed out. Please check your network or server.'};
    } catch (e) {
      return {'status': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> postMultipart(String route, Map<String, String> fields, XFile? file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/$route'));
      request.fields.addAll(fields);
      
      if (file != null) {
        if (kIsWeb) {
             // Web: Read as bytes
             var bytes = await file.readAsBytes();
             request.files.add(http.MultipartFile.fromBytes(
               'image', 
               bytes,
               filename: file.name
             ));
        } else {
             // Mobile/Desktop: Read from path
             request.files.add(await http.MultipartFile.fromPath('image', file.path));
        }
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 45));
      var response = await http.Response.fromStream(streamedResponse);
      
      return _processResponse(response);
    } on TimeoutException {
      return {'status': false, 'message': 'Multipart request timed out.'};
    } catch (e) {
      return {'status': false, 'message': 'Multipart error: $e'};
    }
  }

  static Future<Map<String, dynamic>> get(String route, {Map<String, String>? params}) async {
    try {
      String queryString = '';
      if (params != null) {
        params.forEach((key, value) {
          queryString += '${queryString.isEmpty ? '?' : '&'}$key=$value';
        });
      }

      final url = Uri.parse('$baseUrl/$route$queryString');
      final response = await http.get(url).timeout(const Duration(seconds: 30));

      return _processResponse(response);
    } on TimeoutException {
      return {'status': false, 'message': 'Request timed out. Please try again.'};
    } catch (e) {
      return {'status': false, 'message': 'Connection error: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> put(String route, String id, Map<String, dynamic> data) async {
    try {
       final response = await http.put(
        Uri.parse('$baseUrl/$route?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));
      return _processResponse(response);
    } on TimeoutException {
      return {'status': false, 'message': 'Update request timed out.'};
    } catch (e) {
       return {'status': false, 'message': 'Connection error: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> delete(String route, String id) async {
    try {
       final response = await http.delete(
        Uri.parse('$baseUrl/$route?id=$id'),
      ).timeout(const Duration(seconds: 30));
      return _processResponse(response);
    } on TimeoutException {
      return {'status': false, 'message': 'Delete request timed out.'};
    } catch (e) {
       return {'status': false, 'message': 'Connection error: $e'};
    }
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    try {
      final decoded = json.decode(response.body);
      // The backend now returns a boolean 'status' field.
      // We check for successful HTTP code AND the boolean status.
      bool isSuccess = (response.statusCode >= 200 && response.statusCode < 300) && (decoded['status'] == true);
      
      return {
        ...decoded,
        'status': isSuccess, // Force boolean status for consistency
      };
    } catch (e) {
      // If not JSON or other error, return failure
      return {'status': false, 'message': 'Response processing error: $e'};
    }
  }
}
