import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'constants/app_constants.dart';

Future<String> saveStreamAudioToFile(List<int> data, int sampleRate) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String recordingPath = '${appDocDir.path}/$recordingFolderName';
  if (!await Directory(recordingPath).exists()) {
    Directory(recordingPath).create(recursive: true);
  }

  String ttsFilePath =
      '$recordingPath/$defaultTTSPlayName${DateTime.now().millisecondsSinceEpoch}.wav';

  File audioFile = File(ttsFilePath);

  if (!await audioFile.exists()) {
    await audioFile.create(recursive: true);
  }

  var channels = 1;

  int byteRate = ((16 * sampleRate * channels) / 8).round();

  var size = data.length;

  var fileSize = size + 36;

  Uint8List header = Uint8List.fromList([
    // "RIFF"
    82, 73, 70, 70,
    fileSize & 0xff,
    (fileSize >> 8) & 0xff,
    (fileSize >> 16) & 0xff,
    (fileSize >> 24) & 0xff,
    // WAVE
    87, 65, 86, 69,
    // fmt
    102, 109, 116, 32,
    // fmt chunk size 16
    16, 0, 0, 0,
    // Type of format
    1, 0,
    // One channel
    channels, 0,
    // Sample rate
    sampleRate & 0xff,
    (sampleRate >> 8) & 0xff,
    (sampleRate >> 16) & 0xff,
    (sampleRate >> 24) & 0xff,
    // Byte rate
    byteRate & 0xff,
    (byteRate >> 8) & 0xff,
    (byteRate >> 16) & 0xff,
    (byteRate >> 24) & 0xff,
    // Uhm
    ((16 * channels) / 8).round(), 0,
    // bitSize
    16, 0,
    // "data"
    100, 97, 116, 97,
    size & 0xff,
    (size >> 8) & 0xff,
    (size >> 16) & 0xff,
    (size >> 24) & 0xff,
    ...data
  ]);
  audioFile.writeAsBytesSync(header, flush: true);
  return ttsFilePath;
}

Future<String> createTTSAudioFIle(
  String ttsResponse,
) async {
  Uint8List? fileAsBytes = base64Decode(ttsResponse);
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String recordingPath = '${appDocDir.path}/$recordingFolderName';
  if (!await Directory(recordingPath).exists()) {
    Directory(recordingPath).create(recursive: true);
  }

  String ttsFilePath =
      '$recordingPath/$defaultTTSPlayName${DateTime.now().millisecondsSinceEpoch}.wav';

  File ttsAudioFile = File(ttsFilePath);
  if (!await ttsAudioFile.exists()) {
    await ttsAudioFile.create(recursive: true);
  }
  await ttsAudioFile.writeAsBytes(fileAsBytes);
  return ttsFilePath;
}
