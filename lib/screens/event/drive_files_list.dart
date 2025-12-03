import 'package:flutter/material.dart';
import 'package:gantt_mobile/base/extra_functions.dart';
import 'package:gantt_mobile/base/utilities.dart';
import 'package:gantt_mobile/screens/auth/auth_service_provider.dart';
import 'package:gantt_mobile/screens/event/event_service_provider.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';
import 'package:gantt_mobile/widgets/components/app_bar_title.dart';
import 'package:gantt_mobile/widgets/components/background_scaffold.dart';
import 'package:gantt_mobile/widgets/components/custom_circular_loader.dart';
import 'package:gantt_mobile/widgets/components/lazy_loading_circular_loader.dart';
import 'package:gantt_mobile/widgets/components/no_data_widget.dart';
import 'package:gantt_mobile/widgets/components/remove_focus.dart';
import 'package:gantt_mobile/widgets/components/simple_circular_loader.dart';
import 'package:gantt_mobile/widgets/components/two_button_widget.dart';
import 'package:googleapis/drive/v3.dart' as gdrive;
import 'package:provider/provider.dart';

class DriveFilesList extends StatefulWidget {
  const DriveFilesList({Key? key}) : super(key: key);

  @override
  _DriveFilesListState createState() => _DriveFilesListState();
}

class _DriveFilesListState extends State<DriveFilesList> {
  bool loader = false;
  bool isLoading = false;
  bool isScrollLoading = false;

  List<gdrive.File> driveFiles = [];
  List<String> selectedFilelList = [];

  late gdrive.FileList fileList;
  late gdrive.DriveApi driveApi;

  late ScrollController _sc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _sc = ScrollController();
    isLoading = true;
    getDriveFiles();
    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        _getMoreData(context, fileList.nextPageToken);
      }
    });
  }

  getDriveFiles() {
    final eventProvider = Provider.of<EventServiceProvider>(context, listen: false);
    final authProvider = Provider.of<AuthServiceProvider>(context, listen: false);
    eventProvider.nextPageToken == "";

    authProvider.refreshToken().then((data) async {
      if (data != "exception") {
        final result = await eventProvider.listGoogleDriveFiles(context);

        if (result != null) {
          if (result != "exception") {
            // driveApi = result;
            fileList = result;
            // fileList = await driveApi.files.list();
            driveFiles = fileList.files ?? [];

            driveFiles =
                driveFiles.where((element) => element.mimeType != "application/vnd.google-apps.folder").toList();

            selectedFilelList.clear();
            if (eventProvider.selectedFileList.isNotEmpty) {
              for (gdrive.File file in eventProvider.selectedFileList) {
                debugPrint("${file.id}");
                for (gdrive.File element in driveFiles) {
                  if (element.id == file.id) {
                    selectedFilelList.add(file.id!);
                    break;
                  }
                }
                driveFiles = driveFiles.where((element) => element.id != file.id).toList();
              }
            }

            debugPrint("Selected file list: $selectedFilelList");

            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        tokenExpire(context);
      }
    });
  }

  _getMoreData(BuildContext context, String? pageToken) {
    final eventProvider = Provider.of<EventServiceProvider>(context, listen: false);
    final authProvider = Provider.of<AuthServiceProvider>(context, listen: false);

    if (!isScrollLoading) {
      setState(() {
        isScrollLoading = true;
      });
      authProvider.refreshToken().then((data) async {
        if (data != "exception") {
          final result = await eventProvider.listGoogleDriveFiles(context,
              pageToken: eventProvider.nextPageToken == "" ? "" : eventProvider.nextPageToken);

          if (result != null) {
            if (result != "exception") {
              fileList = result;

              if (fileList.files!.isNotEmpty) {
                for (gdrive.File file in fileList.files!) {
                  if (driveFiles.every((element) => element.id != file.id)) {
                    driveFiles.add(file);
                  }
                }
              }

              driveFiles =
                  driveFiles.where((element) => element.mimeType != "application/vnd.google-apps.folder").toList();

              selectedFilelList.clear();
              if (eventProvider.selectedFileList.isNotEmpty) {
                for (gdrive.File file in eventProvider.selectedFileList) {
                  debugPrint("${file.id}");
                  for (gdrive.File element in driveFiles) {
                    if (element.id == file.id) {
                      selectedFilelList.add(file.id!);
                      break;
                    }
                  }
                  driveFiles = driveFiles.where((element) => element.id != file.id).toList();
                }
              }
              debugPrint("Selected file list: $selectedFilelList");

              setState(() {
                isScrollLoading = false;
              });
            }
          }
        } else {
          setState(() {
            isScrollLoading = false;
          });
          tokenExpire(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventServiceProvider>(context, listen: false);

    return RemoveFocus(
      child: BackgroundScaffold(
        safeArea: false,
        backgroundColor: AppColor.primaryLight,
        appBar: AppBar(
          title: const AppBarTitle(title: "Google Drive"),
        ),
        body: Stack(
          children: [
            Scrollbar(
              controller: _sc,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: Material(
                        elevation: 2,
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(8),
                        child: isLoading
                            ? const Center(child: SimpleCircularLoader())
                            : Padding(
                                padding: const EdgeInsets.all(12),
                                child: driveFiles.isEmpty
                                    ? const NoDataWidget(title: "No data")
                                    : GridView.builder(
                                        controller: _sc,
                                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: Utilities.screenWidth(context) * 0.5,
                                            childAspectRatio: 1 / 1,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 8),
                                        itemCount: driveFiles.length + 1,
                                        itemBuilder: (BuildContext ctx, index) {
                                          return index == driveFiles.length
                                              ? LazyLoadingCircularLoader(isScrolling: isScrollLoading)
                                              : fileTile(
                                                  file: driveFiles[index],
                                                  onTap: () {
                                                    setState(() {
                                                      if (selectedFilelList.isEmpty) {
                                                        selectedFilelList.add(driveFiles[index].id!);
                                                      } else {
                                                        if (selectedFilelList
                                                            .every((element) => element != driveFiles[index].id!)) {
                                                          selectedFilelList.add(driveFiles[index].id!);
                                                        } else {
                                                          selectedFilelList.removeAt(
                                                              selectedFilelList.indexOf(driveFiles[index].id!));
                                                        }
                                                      }
                                                    });

                                                    debugPrint("THIS IS THE SELECTED ID LIST: $selectedFilelList");
                                                  },
                                                );
                                        }),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 12),
                      child: TwoButtonWidget(
                        leftButtonText: "CANCEL",
                        rightButtonText: "ADD FILES",
                        rightButtonTextStyle: CustomTextStyle.bodyTextSecondary,
                        leftButtonFunction: () {
                          Utilities.closeActivity(context);
                        },
                        rightButtonFuntion: () async {
                          if (selectedFilelList.isEmpty) {
                            // showToast(message: "Please select atleast one file to continue");
                            eventProvider.selectedFileList = [];
                            Utilities.closeActivity(context);
                          } else {
                            if (driveFiles.isNotEmpty) {
                              for (gdrive.File file in driveFiles) {
                                for (String id in selectedFilelList) {
                                  if (id == file.id) {
                                    debugPrint("Contains ID: ${file.id}");
                                    eventProvider.selectedFileList.add(file);
                                    break;
                                  }
                                }
                              }
                            }

                            debugPrint("FILE LIST: ${eventProvider.selectedFileList}");
                            Utilities.closeActivity(context);
                          }
                        },
                        switchButtonDecoration: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            loader ? const CustomCircularLoader() : Container()
          ],
        ),
      ),
    );
  }

  Widget fileTile({gdrive.File? file, Function()? onTap}) {
    final BorderRadius borderRadius = BorderRadius.circular(8);

    // debugPrint("URL: ${file!.thumbnailLink}");
    return Material(
      borderRadius: borderRadius,
      color: AppColor.primaryLight,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(borderRadius: borderRadius, border: Border.all(color: AppColor.primary)),
              child: Column(
                children: [
                  Expanded(
                    child: file!.mimeType!.startsWith("image")
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                "${file.thumbnailLink}",
                                fit: BoxFit.cover,
                                width: double.maxFinite,
                                filterQuality: FilterQuality.none,
                                cacheHeight: 200,
                              ),
                            ),
                          )
                        : file.mimeType! == "application/pdf"
                            ? const SizedBox(child: Icon(Icons.picture_as_pdf, size: 54, color: AppColor.primary))
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Center(
                                    child: Image.network(
                                      "${file.iconLink}",
                                      fit: BoxFit.cover,
                                      width: 36,
                                      height: 36,
                                    ),
                                  ),
                                ),
                              ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      file.name ?? " -- ",
                      style: CustomTextStyle.bodyTextBold,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
            selectedFilelList.contains(file.id)
                ? Container(
                    decoration: BoxDecoration(
                      color: AppColor.primaryDark.withOpacity(0.3),
                      borderRadius: borderRadius,
                    ),
                    child: Center(
                      child: Container(
                        decoration: const BoxDecoration(color: AppColor.light, shape: BoxShape.circle),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.check_circle, color: AppColor.primary, size: 32),
                        ),
                      ),
                    ))
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
