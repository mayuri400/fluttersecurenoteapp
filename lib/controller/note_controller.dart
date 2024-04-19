import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/model/note_model.dart';
import 'package:notes_app/widgets/toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:encrypt/encrypt.dart' as en;
import '../database_helper/database_helper.dart';
import '../routing/app_routes.dart';
const String testKey = 'Oqbahahmeddxflutterapplication29';
final key = en.Key.fromUtf8(testKey);
final iv = en.IV.fromUtf8('hfyrujfisoldkide');
final encrypter = en.Encrypter(en.AES(key));
class NoteController extends GetxController {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  var notes = <Note>[].obs;
  var filesData = <FileSystemEntity>[].obs;

  @override
  void onInit() {
    getAllNotes();
    listFilesInDocumentsDirectory();
    update();
    super.onInit();
  }

  bool isEmpty() {
    return filesData.isEmpty;
  }

  void addNoteToDatabase() async {
    String title = titleController.text;
    String content = contentController.text;
    final encrypted = encrypter.encrypt(content, iv: iv);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    Note note = Note(
      title: title,
      content: encrypted.base64,
      dateTimeEdited: DateFormat("dd-MM-yyyy hh:mm a").format(DateTime.now()),
      dateTimeCreated: DateFormat("dd-MM-yyyy hh:mm a").format(DateTime.now()),
        isFavorite: false);
  //  await DatabaseHelper.instance.addNote(note);
    await encryptFile(title,content);
    titleController.text = "";
    contentController.text = "";
    getAllNotes();
    Get.back();
  }
  void updateNote(int id, String dTCreated) async {
    final title = titleController.text;
    final content = contentController.text;
    Note note = Note(
      id: id,
      title: title,
      content: content,
      dateTimeEdited: DateFormat("dd-MM-yyyy hh:mm a").format(DateTime.now()),
      dateTimeCreated: dTCreated,
    );
    await DatabaseHelper.instance.updateNote(note);
    titleController.text = "";
    contentController.text = "";
    getAllNotes();
    Get.offAllNamed(AppRoute.HOME);
  }

  void deleteNote(int id) async {
    Note note = Note(
      id: id,
    );
    await DatabaseHelper.instance.deleteNote(note);
    getAllNotes();
  }

  void favoriteNote(int id) async {
    Note note = notes.firstWhere((note) => note.id == id);
    if (note.isFavorite == true) {
      note.isFavorite = false; // Mark as not favorite
    } else {
      note.isFavorite = true; // Mark as favorite
    }
    await DatabaseHelper.instance.updateNote(note);
    getAllNotes();
  }

  void deleteAllNotes() async {
    await DatabaseHelper.instance.deleteAllNotes();
    getAllNotes();
  }

  void getAllNotes() async {
    notes.value = await DatabaseHelper.instance.getNoteList();
    update();
  }

  void shareNote(String title, String content) {
    Share.share("$title \n$content");
  }
  Future<void> encryptFile(String filename,String content) async {
// Convert the content to bytes
  try {
    List<int> contentBytes = content.codeUnits;
    // Encrypt file contents
    final encrypter = en.Encrypter(en.AES(key));
    final encryptedBytes = encrypter.encryptBytes(contentBytes, iv: iv);

    // Get directory for saving the encrypted file
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final Directory? appDocumentsDir = await getExternalStorageDirectory();
    Directory? directory = Directory("");
    if(Platform.isAndroid){
      try {
        directory = Directory("/storage/emulated/0/Download");
      }catch(e){
        directory = Directory("/storage/emulated/0/Downloads");
      }
    }else {
      directory = await getDownloadsDirectory();
    }
    if(directory!=null) {
      Directory customFolder = Directory('${directory.path}/notes');
      if (!customFolder.existsSync()) {
        customFolder.createSync();
      }
      String newPath = '${customFolder.path}/$filename.txt';
      String newPath1 = await getUniqueFileName(newPath);
      print(newPath1);
      // Write encrypted data to a new file
      File encryptedFile = File(newPath1);
      await encryptedFile.writeAsString(encryptedBytes.base64);
      await listFilesInDocumentsDirectory();
    }
  }catch(e){
    print(e.toString());
  }
  }
  Future<String> decryptFileContent(String file) async {
    // Read the encrypted file content
    List<int> encryptedBytes = await File(file).readAsBytes();

    // Decrypt the encrypted content
    final encrypter = en.Encrypter(en.AES(key));
    final decryptedData = encrypter.decrypt64(String.fromCharCodes(encryptedBytes),iv: iv);

    return decryptedData;
  }
  Future<void> listFilesInDocumentsDirectory() async {
    filesData.clear();
    // Get the app documents directory
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    Directory? directory;
    if(Platform.isAndroid){
      try {
        directory = Directory("/storage/emulated/0/Download");
      }catch(e){
        directory = Directory("/storage/emulated/0/Downloads");
      }
    }else {
      directory = await getDownloadsDirectory();
    }
    // List all files in the directory
    if(directory!=null) {
      Directory customFolder = Directory('${directory.path}/notes');
      if (!customFolder.existsSync()) {
        customFolder.createSync();
      }
      List<FileSystemEntity> files = customFolder.listSync();
      // Print the file paths
      files = files.reversed.toList();
      if (files.isNotEmpty) {
        filesData.addAll(files);
      }
    }else{
      showToast(message: 'Directory not available');
    }
  }
  Future<String> getUniqueFileName(String filePath) async {
    if (!await File(filePath).exists()) {
      return filePath; // File does not exist, return original name
    }

    String directory = Directory(filePath).parent.path;
    String fileName = File(filePath).path.split('/').last;
    String extension = fileName.split('.').last;
    String fileNameWithoutExtension = fileName.replaceAll('.$extension', '');

    int count = 1;
    String newFileName;
    do {
      newFileName = '$fileNameWithoutExtension($count).$extension';
      count++;
    } while (await File('$directory/$newFileName').exists());

    return '$directory/$newFileName';
  }
  bool isValidFileName(String fileName) {
    if (fileName.isEmpty) {
      return false;
    }
    List<String> invalidChars = ['/', '\\', ':', '*', '?', '"', '<', '>', '|','.'];
    if (invalidChars.any((char) => fileName.contains(char))) {
      return false;
    }
    if (fileName.length > 255) {
      return false;
    }
    return true;
  }
}
