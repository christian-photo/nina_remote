import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nina_remote/views/image/image_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:websocket_universal/websocket_universal.dart';

class ApiHelper {

  static bool _isConnected = false;
  static IWebSocketHandler? socket;
  static final List<Function(Map<String, dynamic>)> _listeners = [];

  static Future<(String, String)> _getIpAndPort() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString('saved-ip') ?? '127.0.0.1';
    String port = (prefs.getInt('saved-port') ?? 1888).toString();
    return (ip, port);
  }

  static Future<String> get(String url) async {
    var response = await http.get(Uri.parse(url));
    return response.body;
  }

  static Future<String> set(String url, String body) async {
    var response = await http.post(Uri.parse(url), body: body);
    return response.body;
  }

  static Future<String> getEquipment(String property, [String parameter = '', String index = '']) async {
    var (ip, port) = await _getIpAndPort();
    return get('http://$ip:$port/api/equipment?property=$property&parameter=$parameter&index=$index');
  }

  static Future<String> getSequence() async {
    var (ip, port) = await _getIpAndPort();
    return await get('http://$ip:$port/api/sequence?property=list');
  }

  static Future<String> getHistory([int index = -1]) async {
    var (ip, port) = await _getIpAndPort();
    return await get('http://$ip:$port/api/history?property=list&parameter=$index');
  }

  static Future<int> getImageCount() async {
    var (ip, port) = await _getIpAndPort();
    return jsonDecode(await get('http://$ip:$port/api/history?property=count'))["Response"]["Count"] ?? 0;
  }

  static Future<int> getSocketImageCount() async {
    var (ip, port) = await _getIpAndPort();
    return jsonDecode(await get('http://$ip:$port/api/socket-history?property=count'))["Response"]["Count"] ?? 0;
  }

  static Future<CapturedImage> getSocketImage(int index) async {
    var (ip, port) = await _getIpAndPort();
    Map<String, dynamic> response = jsonDecode(await get('http://$ip:$port/api/socket-history?property=list&parameter=$index'));
    response = response["Response"];
    Image thumb = await getThumbnail(index.toString());
    return CapturedImage(
      thumb, 
      response["Index"],
      response["Stars"],
      response["Filter"],
      response["Gain"],
      response["Offset"],
      response["Median"],
      response["RmsText"],
      response["HFR"],
      response["ExposureTime"],
      response["StDev"],
      response["Mean"],
      DateTime.parse(response["Date"]),
      double.parse(response["Temperature"]),
      response["CameraName"],
      response["TelescopeName"],
      response["FocalLength"],
    );
  }

  static Future<List<Image>> getThumbnails() async {
    int count = await getImageCount();

    List<Image> images = [];
    for (int i = 0; i < count; i++) {
      images.add(await getThumbnail(i.toString()));
    }

    return images;
  }

  static Future<List<CapturedImage>> getCapturedImages() async {
    List<CapturedImage> images = [];
    int count = await getImageCount();

    for (int i = 0; i < count; i++) {
      images.add(await getSocketImage(i));
    }

    return images;
  }

  static Future<Image> getScreenshot() async {
    var (ip, port) = await _getIpAndPort();
    Map<String, dynamic> response = jsonDecode(await set('http://$ip:$port/api/equipment', '{"Device":"application", "Action":"screenshot"}'));
    String image = response["Response"] ?? '';
    return Image.memory(base64Decode(image));
  }

  static Future<Image> getImage(String index, [int quality=-1]) async {
    var (ip, port) = await _getIpAndPort();
    Map<String, dynamic> response = jsonDecode(await get('http://$ip:$port/api/equipment?property=image&parameter=$quality&index=$index'));
    String image = response["Response"] ?? '';
    return Image.memory(base64Decode(image));
  }

  static Future<Image> getThumbnail(String index) async {
    return await getImage(index, 30);
  }

  static void addListener(Function(Map<String, dynamic>) listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function(Map<String, dynamic>) listener) {
    _listeners.remove(listener);
  }

  static void disconnect() {
    socket?.close();
    _isConnected = false;
  }

  static Future<bool> connect([bool useDelay = true]) async {
    if (_isConnected) {
      return true;
    }

    var (ip, port) = await _getIpAndPort();
    
    if (useDelay) {
      Future.delayed(const Duration(milliseconds: 500)); // For UI/UX reasons, otherwise a failed connection would look not good as the screen would just be popping in and out
    }
    
    try {
      socket = IWebSocketHandler.createClient('ws://$ip:$port/socket', SocketSimpleTextProcessor(), connectionOptions: const SocketConnectionOptions(failedReconnectionAttemptsLimit: 3));
    
      await socket?.connect();

      socket?.incomingMessagesStream.listen((event) {
        Map<String, dynamic> json = jsonDecode(event);
        for (Function(Map<String, dynamic>) listener in _listeners) {
          listener(json);
        }
      });
    }
    catch (e) {
      _isConnected = false;
      return _isConnected;
    }

    _isConnected = socket?.socketState.status == SocketStatus.connected;
    return _isConnected;
  }
}