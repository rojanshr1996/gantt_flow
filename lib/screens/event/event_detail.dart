import 'package:flutter/material.dart';
import 'package:gantt_mobile/base/extra_functions.dart';
import 'package:gantt_mobile/base/utilities.dart';
import 'package:gantt_mobile/screens/auth/auth_service_provider.dart';
import 'package:gantt_mobile/screens/event/edit_event.dart';
import 'package:gantt_mobile/screens/event/event_service_provider.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';
import 'package:gantt_mobile/widgets/components/app_bar_title.dart';
import 'package:gantt_mobile/widgets/components/background_scaffold.dart';
import 'package:gantt_mobile/widgets/components/custom_alert_dialog.dart';
import 'package:gantt_mobile/widgets/components/custom_circular_loader.dart';
import 'package:gantt_mobile/widgets/components/info_field_widget.dart';
import 'package:gantt_mobile/widgets/components/no_data_widget.dart';
import 'package:gantt_mobile/widgets/components/remove_focus.dart';
import 'package:gantt_mobile/widgets/components/simple_circular_loader.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetail extends StatefulWidget {
  final String eventId;
  final String calendarId;
  const EventDetail({Key? key, required this.eventId, required this.calendarId})
      : super(key: key);

  @override
  _EventDetailState createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  bool isLoading = false;
  Event? eventDetail;
  bool loader = false;

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    isLoading = true;
    super.initState();
    getEvent(context);
  }

  getEvent(BuildContext context) {
    final eventProvider =
        Provider.of<EventServiceProvider>(context, listen: false);
    final authProvider =
        Provider.of<AuthServiceProvider>(context, listen: false);
    authProvider.refreshToken().then((data) async {
      if (data != "exception") {
        final result = await eventProvider.getEventDetail(
            calendarId: widget.calendarId,
            eventId: widget.eventId,
            context: context);
        isLoading = false;
        setState(() {});
        if (result != null) {
          debugPrint("THIS IS EVENT: $result");
          eventDetail = result;
          debugPrint(
              "THIS IS EVENT Attendees: ${eventDetail?.attendees?.length}");
        }
        eventProvider.setEventDeleted(false);
      } else {
        tokenExpire(context);
      }
    });
  }

  Future<void> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      isLoading = true;
    });
    getEvent(context);
    return;
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsetsGeometry headerPadding =
        EdgeInsets.fromLTRB(16, 0, 16, 8); //Padding for header field info
    const EdgeInsetsGeometry summaryPadding =
        EdgeInsets.fromLTRB(8, 16, 8, 16); //Padding for event title

    return RemoveFocus(
      child: BackgroundScaffold(
        safeArea: false,
        backgroundColor: AppColor.primaryLight,
        appBar: AppBar(
          title: const AppBarTitle(title: "Event Detail"),
          actions: [
            isLoading
                ? Container()
                : IconButton(
                    onPressed: () {
                      Utilities.openActivity(
                          context,
                          EditEvent(
                            calendarId: eventDetail?.organizer?.email ?? "",
                            eventId: eventDetail?.id,
                            calendarName: eventDetail?.organizer?.displayName ??
                                eventDetail?.organizer?.email ??
                                "",
                            eventTitle: eventDetail?.summary ?? "",
                            startTime: eventDetail?.start?.date ??
                                eventDetail?.start?.dateTime
                                    ?.add(DateTime.now().timeZoneOffset),
                            endTime: eventDetail?.end?.date
                                    ?.subtract(const Duration(days: 1)) ??
                                eventDetail?.end?.dateTime
                                    ?.add(DateTime.now().timeZoneOffset),
                            description: eventDetail?.description ?? "",
                            location: eventDetail?.location ?? "",
                            allDayEvent:
                                eventDetail?.start?.date == null ? false : true,
                            attendees: eventDetail?.attendees ?? [],
                            attachments: eventDetail?.attachments ?? [],
                          )).then((data) {
                        getEvent(context);
                      });
                    },
                    icon: const Icon(Icons.edit_outlined),
                  ),
            Consumer<EventServiceProvider>(
              builder: (context, eventProvider, _) {
                return isLoading
                    ? Container()
                    : IconButton(
                        onPressed: () {
                          deleteEvent(context);
                        },
                        icon: const Icon(Icons.delete),
                      );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          key: refreshKey,
          onRefresh: refreshList,
          backgroundColor: AppColor.primary,
          color: AppColor.white,
          child: Stack(
            children: [
              ListView(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: Utilities.screenWidth(context),
                        child: Material(
                          elevation: 2,
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(8),
                          child: isLoading
                              ? const Center(child: SimpleCircularLoader())
                              : eventDetail == null
                                  ? const NoDataWidget(title: "No data")
                                  : Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                                color: AppColor.secondary,
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(8)),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.event,
                                                        color: AppColor
                                                            .primaryLight,
                                                        size: 18),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      eventDetail?.organizer
                                                              ?.displayName ??
                                                          eventDetail?.organizer
                                                              ?.email ??
                                                          " ---- ",
                                                      style: CustomTextStyle
                                                          .smallTextLightBold,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  eventDetail?.creator?.email ??
                                                      "",
                                                  style: CustomTextStyle
                                                      .smallTextBold),
                                            )
                                          ],
                                        ),
                                        Expanded(
                                          child: ListView(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Padding(
                                                  padding: summaryPadding,
                                                  child: Text(
                                                      eventDetail?.summary ??
                                                          " -- No Title --",
                                                      style: CustomTextStyle
                                                          .largeHeaderText),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              timeTile(
                                                  title: "START TIME",
                                                  body: eventDetail
                                                          ?.start?.date ??
                                                      eventDetail
                                                          ?.start?.dateTime
                                                          ?.add(DateTime.now()
                                                              .timeZoneOffset),
                                                  allDayEvent: eventDetail
                                                              ?.start?.date ==
                                                          null
                                                      ? false
                                                      : true),
                                              timeTile(
                                                  title: "END TIME",
                                                  body: eventDetail?.end?.date
                                                          ?.subtract(
                                                              const Duration(
                                                                  days: 1)) ??
                                                      eventDetail?.end?.dateTime
                                                          ?.add(DateTime.now()
                                                              .timeZoneOffset),
                                                  allDayEvent: eventDetail
                                                              ?.start?.date ==
                                                          null
                                                      ? false
                                                      : true),
                                              const SizedBox(height: 8),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: InfoFieldWidget(
                                                    fieldName: "DESCRIPTION",
                                                    fieldInfo: eventDetail
                                                            ?.description ??
                                                        " ---- ",
                                                    fieldNameStyle:
                                                        CustomTextStyle
                                                            .hintbodyText),
                                              ),
                                              Padding(
                                                padding: headerPadding,
                                                child: InfoFieldWidget(
                                                    fieldName: "LOCATION",
                                                    fieldInfo:
                                                        eventDetail?.location ??
                                                            " ---- ",
                                                    fieldNameStyle:
                                                        CustomTextStyle
                                                            .hintbodyText),
                                              ),
                                              const Padding(
                                                padding: headerPadding,
                                                child: Text("ATTENDEES",
                                                    style: CustomTextStyle
                                                        .hintbodyText),
                                              ),
                                              Padding(
                                                padding: headerPadding,
                                                child:
                                                    eventDetail?.attendees ==
                                                            null
                                                        ? const SizedBox(
                                                            child: Padding(
                                                              padding:
                                                                  headerPadding,
                                                              child: Text(
                                                                " ---- ",
                                                                style: CustomTextStyle
                                                                    .bodyTextBold,
                                                              ),
                                                            ),
                                                          )
                                                        : Container(
                                                            decoration: BoxDecoration(
                                                                color: AppColor
                                                                    .light,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      8,
                                                                      0,
                                                                      8,
                                                                      8),
                                                              child: SizedBox(
                                                                child: Column(
                                                                  children: eventDetail!
                                                                      .attendees!
                                                                      .map<Widget>(
                                                                          (item) {
                                                                    return Padding(
                                                                      padding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          0,
                                                                          8,
                                                                          0,
                                                                          0),
                                                                      child:
                                                                          Container(
                                                                        decoration: BoxDecoration(
                                                                            color: item.responseStatus! == "accepted"
                                                                                ? AppColor.success
                                                                                : item.responseStatus! == "declined"
                                                                                    ? AppColor.muted
                                                                                    : AppColor.primary,
                                                                            border: Border.all(
                                                                                color: item.responseStatus! == "accepted"
                                                                                    ? AppColor.success
                                                                                    : item.responseStatus! == "declined"
                                                                                        ? AppColor.muted
                                                                                        : AppColor.primary),
                                                                            borderRadius: BorderRadius.circular(5)),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 5,
                                                                              child: Container(
                                                                                decoration: BoxDecoration(color: AppColor.white, borderRadius: BorderRadius.circular(5)),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(8),
                                                                                  child: Text(
                                                                                    item.email ?? " --",
                                                                                    style: CustomTextStyle.bodyTextAccentBold,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(left: 8, right: 8),
                                                                                child: Text(
                                                                                  item.responseStatus == "needsAction" ? "Action needed" : item.responseStatus!.substring(0, 1).toUpperCase() + item.responseStatus!.substring(1),
                                                                                  style: item.responseStatus! == "accepted"
                                                                                      ? CustomTextStyle.smallTextLightBold
                                                                                      : item.responseStatus! == "declined"
                                                                                          ? CustomTextStyle.smallTextBold
                                                                                          : CustomTextStyle.smallTextLightBold,
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                              ),
                                              const SizedBox(height: 8),
                                              const Padding(
                                                padding: headerPadding,
                                                child: Text("ATTACHMENTS",
                                                    style: CustomTextStyle
                                                        .hintbodyText),
                                              ),
                                              Padding(
                                                padding: headerPadding,
                                                child: eventDetail
                                                            ?.attachments ==
                                                        null
                                                    ? const SizedBox(
                                                        child: Padding(
                                                          padding:
                                                              headerPadding,
                                                          child: Text(
                                                            " ---- ",
                                                            style: CustomTextStyle
                                                                .bodyTextBold,
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        decoration: BoxDecoration(
                                                            color:
                                                                AppColor.light,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Wrap(
                                                            direction:
                                                                Axis.horizontal,
                                                            children: eventDetail!
                                                                .attachments!
                                                                .map<Widget>(
                                                                    (item) {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            8.0),
                                                                child: attachmentTag(
                                                                    title: "${item.title}",
                                                                    iconData: item.mimeType == "application/pdf"
                                                                        ? Icons.picture_as_pdf
                                                                        : item.mimeType!.startsWith("image")
                                                                            ? Icons.photo
                                                                            : Icons.file_copy_outlined,
                                                                    onPressed: () => _launchURL(item.fileUrl!)),
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                              const SizedBox(height: 20)
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              loader ? const CustomCircularLoader() : Container()
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  Widget attachmentTag(
      {required String title, Function()? onPressed, IconData? iconData}) {
    return InputChip(
      label: Text(title),
      labelStyle: CustomTextStyle.smallTextLight,
      backgroundColor: AppColor.secondary,
      onPressed: onPressed ?? () {},
      avatar: Icon(iconData ?? Icons.file_copy,
          color: AppColor.primaryLight, size: 20),
    );
  }

  Widget timeTile(
      {required String title,
      required DateTime? body,
      TextStyle? titleStyle = CustomTextStyle.hintbodyText,
      TextStyle? bodyStyle = CustomTextStyle.bodyTextBold,
      bool allDayEvent = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      child: Container(
        width: Utilities.screenWidth(context),
        decoration: BoxDecoration(
            color: AppColor.light, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(title, style: titleStyle),
            ),
            Expanded(
              flex: 2,
              child: Text(
                  allDayEvent
                      ? DateFormat.yMMMEd().format(body!)
                      : DateFormat.yMMMEd().format(body!) +
                          ", " +
                          DateFormat.jm().format(body),
                  style: bodyStyle,
                  softWrap: true,
                  textAlign: TextAlign.end),
            ),
          ],
        ),
      ),
    );
  }

  deleteEvent(BuildContext context) {
    final eventProvider =
        Provider.of<EventServiceProvider>(context, listen: false);

    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return CustomAlertDialog(
          leftButtonText: "YES",
          rightButtonText: "NO",
          title: const Text("Do you want to delete this event?",
              style: CustomTextStyle.headerTextLight),
          body: const Text(
              "The event will also be removed from the Google Calendar.",
              style: CustomTextStyle.bodyTextLight),
          rightButtonFunction: () {
            Utilities.closeActivity(ctx);
          },
          leftButtonFunction: () {
            Utilities.closeActivity(ctx);
            setState(() {
              loader = true;
            });
            final authProvider =
                Provider.of<AuthServiceProvider>(context, listen: false);
            authProvider.refreshToken().then((data) async {
              if (data != "exception") {
                eventProvider
                    .deleteEvent(
                        context: context,
                        calendarId: widget.calendarId,
                        eventId: widget.eventId)
                    .then((data) {
                  debugPrint("$data");
                  setState(() {
                    loader = false;
                  });
                  eventProvider.setEventDeleted(true);
                  showToast(message: "Event deleted successfully");
                  Utilities.returnDataCloseActivity(context, "reload");
                });
              } else {
                tokenExpire(context);
              }
            });
          },
        );
      },
    );
  }
}
