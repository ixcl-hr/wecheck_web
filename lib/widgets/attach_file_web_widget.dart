import 'dart:typed_data';
import 'package:path/path.dart' as Path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wecheck/services/util_service.dart';

class AttachFileWebWidget extends StatefulWidget {
  // final Function(File file) onSelected;
  late final Function(Uint8List? fileData)? onSelected;
  late final Function(String title, String desc)? onError;
  late final String? filename;
  late final bool? withLabel;
  late final bool? allowLocalImg;

  final TextEditingController
      attachFileController; // = TextEditingController();

  AttachFileWebWidget(
      {Key? key,
      Function(Uint8List? fileData)? onSelected,
      Function(String title, String desc)? onError,
      bool? withLabel,
      bool? allowLocalImg,
      required this.attachFileController})
      : super(key: key) {
    this.onSelected = onSelected;
    this.onError = onError;
    this.withLabel = withLabel ?? true;
    this.allowLocalImg = allowLocalImg ?? true;

    //_AttachFileState(filename);
  }

  @override
  State<StatefulWidget> createState() => _AttachFileState(attachFileController);
}

class _AttachFileState extends State<AttachFileWebWidget> {
  late TextEditingController attachFileController; // = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  _AttachFileState(TextEditingController txtcontroller) {
    attachFileController = txtcontroller;
    // if (filename != null) {
    //   attachFileController = TextEditingController();
    //   attachFileController.text = filename;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        children: [
          (widget.withLabel ?? false) ? const Text('ไฟล์แนบ:') : Container(),
          Expanded(
            child: Container(
              margin: (widget.withLabel ?? false)
                  ? const EdgeInsets.symmetric(horizontal: 10.0)
                  : const EdgeInsets.only(right: 10.0),
              padding: const EdgeInsets.symmetric(
                  // vertical: 5.0,
                  // horizontal: 5.0
                  ),
              // decoration: BoxDecoration(
              //   border: Border.all(color: Colors.grey[600]),
              // ),
              child: TextField(
                controller: attachFileController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: UtilService.getTextFromLang(
                      "no_attachments", "ไม่มีไฟล์แนบ"),
                  suffixIcon: (widget.allowLocalImg ?? false)
                      ? Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.more_horiz,
                              size: 13,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              addFile();
                            },
                          ),
                        )
                      : Container(),
                  suffixIconConstraints: const BoxConstraints(
                    maxHeight: 30,
                    maxWidth: 25,
                  ),
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                ),
              ),
            ),
            // child: Container(
            //   margin: EdgeInsets.symmetric(horizontal: 10.0),
            //   padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Colors.grey[600]),
            //   ),
            //   child: Text(
            //     attachedFile == null ? 'File' : Path.basename(attachedFile.path),
            //     style: TextStyle(fontSize: 15.0),
            //   ),
            // ),
          ),
          IconButton(
            constraints: const BoxConstraints(
              maxWidth: 100,
            ),
            icon: const Icon(
              Icons.camera_alt,
              color: Color.fromRGBO(245, 157, 86, 1.0),
            ),
            padding: const EdgeInsets.only(left: 5.0),
            onPressed: () {
              addFile(fromCamera: true);
            },
          ),
        ],
      ),
    );
  }

  addFile({bool fromCamera = false}) async {
    // if (fromCamera) {
    //   // Take photo
    //   pickImage(ImageSource.camera);
    // } else {
    //   browseFile();
    // }
    browseFile();
  }

  // Browse file using File_picker
  browseFile({bool removePopup = false}) async {
    // print("from web");
    //     image = Image.network(_picker);
    //     pickImage(ImageSource.gallery);
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      changeAttachFile(result);
      print("FileName: ${result.files.first.name}");
    }
    if (removePopup) {
      Navigator.pop(context);
    }
  }

  // Call callback function to change attached file var on parent widget or show error
  bool changeAttachFile(FilePickerResult? result) {
    if (result != null) {
      PlatformFile? file = result.files[0];

      Uint8List data = file.bytes!;
      // file.readAsBytesSync();
      int fileSize =
          file.size; // result.length / 1024 / 1024; // File size in MB
      if (widget.onSelected != null) {
        widget.onSelected!(data);
      }
      attachFileController.text = Path.basename(file.name);
      return true;

      // if (fileSize <= 5) {
      //   if (widget.onSelected != null) {
      //     widget.onSelected(data);
      //   }
      //   attachFileController.text = Path.basename(file.name);
      //   return true;
      // } else {
      //   if (widget.onSelected != null) {
      //     widget.onSelected(null);
      //   }
      //   attachFileController.text = '';
      //   if (widget.onError != null) {
      //     widget.onError('เกิดข้อผิดพลาด', 'ไฟล์มีขนาดใหญ่กว่า 5 MB');
      //     // print(fileSize);
      //   }
      // }
    } else {
      if (widget.onSelected != null) {
        widget.onSelected!(null);
      }
      attachFileController.text = '';
      if (widget.onError != null) {
        widget.onError!('เกิดข้อผิดพลาด', 'ไม่สามารถอ่านข้อมูลไฟล์ได้');
      }
    }
    return false;
  }
}
