import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notes_app/database_helper/database_firebase.dart';
import 'package:notes_app/routing/app_routes.dart';
import 'package:notes_app/screens/search_screen.dart';

import '../constants/colors.dart';
import '../controller/note_controller.dart';
import '../widgets/alert_dialog.dart';

class HomePage extends StatelessWidget {
  final controller = Get.put(NoteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Flutter Notes App",
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          GestureDetector(onTap:()async{
           await Database().uploadData();
          },child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(Icons.cloud_upload),
          ))
        ],
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.search),
        //     onPressed: () {
        //       showSearch(context: context, delegate: Search());
        //     },
        //   ),
        //   PopupMenuButton(
        //     onSelected: (val) {
        //       if (val == 0) {
        //         showDialog(
        //           context: context,
        //           builder: (context) {
        //             return AlertDialogWidget(
        //               headingText: "Are you sure you want to delete all notes?",
        //               contentText:
        //                   "This will delete all notes permanently. You cannot undo this action.",
        //               confirmFunction: () {
        //                 controller.deleteAllNotes();
        //                 Get.back();
        //               },
        //               declineFunction: () {
        //                 Get.back();
        //               },
        //             );
        //           },
        //         );
        //       }
        //     },
        //     itemBuilder: (context) => [
        //       const PopupMenuItem(
        //         value: 0,
        //         child: Text(
        //           "Delete All Notes",
        //           style: TextStyle(
        //             fontWeight: FontWeight.normal,
        //           ),
        //         ),
        //       )
        //     ],
        //   ),
        // ],
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: GetBuilder<NoteController>(
        builder: (_) => controller.isEmpty() ? emptyNotes() : viewNotes(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed(AppRoute.ADD_NEW_NOTE);
        },
        label: const Text(
          "Create Note file",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: Colors.white),
        ),
        icon: const Icon(
          Icons.add,
        ),
        backgroundColor: AppColor.buttonColor,
      ),
    );
  }

  Widget viewNotes() {
    return Scrollbar(
      child: Container(
        padding: const EdgeInsets.only(
          top: 10,
          right: 10,
          left: 10,
        ),
        child: ListView.builder(
          shrinkWrap: false,
          itemCount: controller.notes.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async{
               // Get.toNamed(AppRoute.NOTE_DETAILS, arguments: index);
               //  String s=await controller.decryptFileContent(controller.filesData[index].path);
               //  print(s);
               //  showDialog(
               //    context: context,
               //    builder: (context) {
               //      return AlertDialogWidget(
               //        headingText: "File content",
               //        contentText:s,
               //        confirmFunction: () {
               //          Get.back();
               //        },
               //        declineFunction: () {
               //        },
               //      );
               //    },
               //  );
              },
              onLongPress: () async {

              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.grayColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(controller.notes[index].title.toString()
                            /*  controller.filesData[index].path.substring(controller.filesData[index].path.lastIndexOf('/') + 1)*/,
                              style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.textColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // const SizedBox(
                            //   height: 10,
                            // ),
                            // Text(
                            //   controller.notes[index].content!,
                            //   style: const TextStyle(
                            //       fontSize: 18, color: AppColor.textColor),
                            //   overflow: TextOverflow.ellipsis,
                            //   maxLines: 2,
                            // ),
                            // const SizedBox(
                            //   height: 10,
                            // ),
                            // Text(
                            //   controller.notes[index].dateTimeEdited!,
                            //   style: const TextStyle(
                            //       fontSize: 14, color: AppColor.textColor),
                            // ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      // InkWell(
                      //   onTap: () {
                      //     controller.favoriteNote(controller.notes[index].id!);
                      //   },
                      //   child: Icon(
                      //     controller.notes[index].isFavorite == true
                      //         ? Icons.favorite
                      //         : Icons.favorite_border,
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget emptyNotes() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image(
            height: 200,
            width: 200,
            image: AssetImage('assets/no_notes1.png'),
          ),
          Text(
            "Create your first note file!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
