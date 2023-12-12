import 'dart:io';
// import 'package:universal_io/io.dart';
import 'dart:typed_data';
import 'package:path/path.dart' as Path;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/util_service.dart';

class AttachFileWidget extends StatefulWidget {
  final Function(File? file)? onSelected;
  final Function(String title, String desc)? onError;
  final bool? withLabel;
  final bool? allowLocalImg;
  final bool? allowCamera;
  final TextEditingController attachFileController;

  const AttachFileWidget(
      {super.key,
      this.onSelected,
      this.onError,
      this.withLabel = true,
      this.allowLocalImg = true,
      this.allowCamera = true,
      required this.attachFileController});

  @override
  State<StatefulWidget> createState() => _AttachFileState(attachFileController);
}

class _AttachFileState extends State<AttachFileWidget> {
  late TextEditingController attachFileController; // = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  _AttachFileState(TextEditingController txtcontroller) {
    attachFileController = txtcontroller;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        children: [
          (widget.withLabel ?? false)
              ? Text(UtilService.getTextFromLang("attachments", "ไฟล์แนบ"))
              : Container(),
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
          (widget.allowCamera ?? false)
              ? IconButton(
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
                )
              : const SizedBox(
                  width: 5,
                ),
        ],
      ),
    );
  }

  addFile({bool fromCamera = false}) async {
    if (fromCamera) {
      // Take photo
      pickImage(ImageSource.camera);
    } else {
      // Browse file
      if (kIsWeb) {
        browseFile();
      } else {
        if (!kIsWeb && Platform.isIOS) {
          // In iOS, use have to select to browse image gallery or files
          showCupertinoModalPopup<void>(
            context: context,
            builder: (BuildContext context) => CupertinoActionSheet(
              actions: <Widget>[
                CupertinoActionSheetAction(
                  onPressed: () {
                    pickImage(ImageSource.gallery, removePopup: true);
                  },
                  child: const Text('Gallery'),
                ),
                CupertinoActionSheetAction(
                  onPressed: () {
                    browseFile(removePopup: true);
                  },
                  child: const Text('Files'),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ),
          );
        } else {
          browseFile();
        }
      }
    }
  }

  // Browse file using File_picker
  browseFile({bool removePopup = false}) async {
    // print("from web");
    //     image = Image.network(_picker);
    //     pickImage(ImageSource.gallery);
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      changeAttachFile(File(result.files.single.path ?? ""));
    }
    if (removePopup) {
      Navigator.pop(context);
    }
  }

  // Browse image for iOS using Image_picker
  pickImage(ImageSource imageSource, {bool removePopup = false}) async {
    PickedFile? pickedFile = await _picker.getImage(source: imageSource);
    bool finishedChangedAttachFile = false;
    if (pickedFile != null) {
      finishedChangedAttachFile = changeAttachFile(File(pickedFile.path));
    }
    if (removePopup && finishedChangedAttachFile) {
      Navigator.pop(context);
    }
  }

  // Call callback function to change attached file var on parent widget or show error
  bool changeAttachFile(File? file) {
    if (file != null) {
      Uint8List data = file.readAsBytesSync();
      double fileSize = data.length / 1024 / 1024; // File size in MB
      if (fileSize <= 5) {
        if (widget.onSelected != null) {
          widget.onSelected!(file);
        }
        attachFileController.text = Path.basename(file.path);
        return true;
      } else {
        if (widget.onSelected != null) {
          widget.onSelected!(null);
        }
        attachFileController.text = '';
        if (widget.onError != null) {
          widget.onError!(
              UtilService.getTextFromLang("error", "เกิดข้อผิดพลาด"),
              'ไฟล์มีขนาดใหญ่กว่า 5 MB');
          // print(fileSize);
        }
      }
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
