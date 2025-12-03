import 'package:date_time_picker_plus/date_time_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:gantt_mobile/base/extra_functions.dart';
import 'package:gantt_mobile/base/utilities.dart';
import 'package:gantt_mobile/screens/auth/auth_service_provider.dart';
import 'package:gantt_mobile/screens/event/add_calendar_event_dialog.dart';
import 'package:gantt_mobile/screens/event/drive_files_list.dart';
import 'package:gantt_mobile/screens/event/event_service_provider.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';
import 'package:gantt_mobile/widgets/components/app_bar_title.dart';
import 'package:gantt_mobile/widgets/components/background_scaffold.dart';
import 'package:gantt_mobile/widgets/components/custom_circular_loader.dart';
import 'package:gantt_mobile/widgets/components/remove_focus.dart';
import 'package:gantt_mobile/widgets/components/text_field_widget.dart';
import 'package:gantt_mobile/widgets/components/two_button_widget.dart';
import 'package:gantt_mobile/widgets/homeWidgets/custom_switch.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:provider/provider.dart';

class EditEvent extends StatefulWidget {
  final String? calendarId;
  final String? eventId;
  final String? eventTitle;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? description;
  final String? location;
  final String? calendarName;
  final bool allDayEvent;
  final List<EventAttendee>? attendees;
  final List<EventAttachment>? attachments;

  const EditEvent({
    super.key,
    required this.eventTitle,
    required this.startTime,
    required this.endTime,
    this.description,
    this.calendarId,
    this.eventId,
    this.calendarName,
    this.allDayEvent = false,
    this.location,
    this.attendees = const [],
    this.attachments = const [],
  });

  @override
  _EditEventState createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  TextEditingController titleController = TextEditingController();
  TextEditingController calendarController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController attendeesController = TextEditingController();

  bool isSwitched = false;

  CalendarListEntry? selectedCalendar;

  DateTime startCheckDate = DateTime.now();
  DateTime endCheckDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  bool loader = false;

  List<String> attachments = [];

  List<EventAttachment>? eventAttachment = [];
  List<EventAttendee>? attendeesList = [];

  bool startShowNotification = true;
  bool endShowNotification = true;

  @override
  void initState() {
    titleController = TextEditingController(text: widget.eventTitle);
    calendarController = TextEditingController(text: widget.calendarName);
    startDateController =
        TextEditingController(text: widget.startTime.toString());
    endDateController = TextEditingController(text: widget.endTime.toString());
    descriptionController =
        TextEditingController(text: widget.description ?? "");
    locationController = TextEditingController(text: widget.location ?? "");
    isSwitched = widget.allDayEvent;
    debugPrint("EVENT ATTACHMENT: ${widget.attachments}");
    debugPrint("EVENT ATTACHMENT: $eventAttachment");

    eventAttachment = widget.attachments;
    debugPrint("EVENT ATTACHMENT: $eventAttachment");

    if (widget.attendees!.isNotEmpty) {
      attendeesList = widget.attendees;
    }

    clearSelection();
    checkDatesForNotifications();
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    calendarController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
    attendeesController.dispose();
    super.dispose();
  }

  void showCalendarDialog() {
    showDialog(
            builder: (BuildContext ctx) => const AddCalendarEventDialog(),
            context: context)
        .then((calendar) {
      if (calendar != null) {
        debugPrint("RETURNED CALENDAR: ${calendar.summary}");
        selectedCalendar = calendar;
        setState(() {
          calendarController.text = calendar.summary;
        });
      } else {
        debugPrint("NO VALUE RETURNED");
      }
    });
  }

  void clearSelection() {
    final eventProvider =
        Provider.of<EventServiceProvider>(context, listen: false);
    eventProvider.clearFileList();
  }

  void checkDatesForNotifications() {
    if (!isSwitched) {
      // For start date
      if (DateTime.parse(startDateController.text).isBefore(DateTime.now())) {
        startShowNotification = false;
      }

      // For end date
      if (DateTime.parse(endDateController.text).isBefore(DateTime.now())) {
        endShowNotification = false;
      }
    } else {
      // For start date
      DateTime date = DateTime.parse(startDateController.text);
      if (DateTime(date.year, date.month, date.day).isBefore(DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
        startShowNotification = false;
      }

      // For end date
      DateTime endDate = DateTime.parse(endDateController.text);
      if (DateTime(endDate.year, endDate.month, endDate.day).isBefore(DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
        endShowNotification = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    final eventProvider =
        Provider.of<EventServiceProvider>(context, listen: false);

    return RemoveFocus(
      child: BackgroundScaffold(
        safeArea: false,
        backgroundColor: AppColor.primaryLight,
        appBar: AppBar(
          title: const AppBarTitle(title: "Edit Event"),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Material(
                      elevation: 2,
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(8),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    color: AppColor.secondary,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomLeft: Radius.circular(8)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.event,
                                            color: AppColor.primaryLight,
                                            size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          widget.calendarName!.isEmpty
                                              ? " ---- "
                                              : widget.calendarName!,
                                          style: CustomTextStyle
                                              .smallTextLightBold,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: ListView(
                                  children: [
                                    GestureDetector(
                                      onTap: () => FocusScope.of(context)
                                          .requestFocus(FocusNode()),
                                      child: TextFieldWidget(
                                        autofocus: false,
                                        hintText: "EVENT TITLE",
                                        textEditingController: titleController,
                                        obscureText: false,
                                        textInputType:
                                            TextInputType.visiblePassword,
                                        validator: (String? value) =>
                                            validateEmptyField(
                                                context: context,
                                                value: value!,
                                                fieldName: "Title"),
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                        prefixIcon: const Icon(Icons.title,
                                            color: AppColor.primary),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomSwitch(
                                        switchValue: isSwitched,
                                        trackColor: AppColor.pale,
                                        thumbColor: AppColor.primary,
                                        title: "ALL DAY EVENT",
                                        onChanged: (value) {
                                          setState(() {
                                            isSwitched = value;

                                            if (isSwitched) {
                                              startCheckDate = DateTime(
                                                  DateTime.now().year,
                                                  DateTime.now().month,
                                                  DateTime.now().day);
                                              endCheckDate = DateTime(
                                                  DateTime.now().year,
                                                  DateTime.now().month,
                                                  DateTime.now().day + 1);
                                              debugPrint(
                                                  "$startCheckDate ===> $endCheckDate");
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Stack(
                                      children: [
                                        DateTimePicker(
                                          type: isSwitched
                                              ? DateTimePickerType.date
                                              : DateTimePickerType.dateTime,
                                          dateMask: isSwitched
                                              ? 'd MMMM, yyyy '
                                              : 'd MMMM, yyyy - hh:mm a',
                                          controller: startDateController,
                                          dateHintText: isSwitched
                                              ? "EVENT START DATE"
                                              : "EVENT START TIME",
                                          firstDate: DateTime(2021),
                                          lastDate: DateTime(2100),
                                          locale: const Locale("en", "US"),
                                          onChanged: (String val) {
                                            debugPrint(val);
                                            setState(() {
                                              startDateController.text = val;
                                              if (!isSwitched) {
                                                if (DateTime.parse(
                                                        startDateController
                                                            .text)
                                                    .isBefore(DateTime.now())) {
                                                  startShowNotification = false;
                                                } else {
                                                  startShowNotification = true;
                                                }
                                              } else {
                                                DateTime date = DateTime.parse(
                                                    startDateController.text);
                                                if (DateTime(date.year,
                                                        date.month, date.day)
                                                    .isBefore(DateTime(
                                                        DateTime.now().year,
                                                        DateTime.now().month,
                                                        DateTime.now().day))) {
                                                  startShowNotification = false;
                                                } else {
                                                  startShowNotification = true;
                                                }
                                              }
                                            });
                                          },
                                          icon: const Icon(
                                              Icons.watch_later_outlined,
                                              color: AppColor.primary),
                                        ),
                                        startDateController.text.isEmpty
                                            ? Container()
                                            : Positioned(
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          startDateController
                                                              .clear();
                                                          startShowNotification =
                                                              true;
                                                        });
                                                      },
                                                      icon: const Icon(
                                                          Icons.close,
                                                          color:
                                                              AppColor.danger)),
                                                ),
                                              )
                                      ],
                                    ),
                                    SizedBox(
                                        height: startShowNotification ? 0 : 8),
                                    startShowNotification
                                        ? Container()
                                        : Text(
                                            "Since the event starts before the current date, no notification will be sent to the attendees (if any).",
                                            style: CustomTextStyle.smallText
                                                .copyWith(
                                                    fontStyle: FontStyle.italic,
                                                    color: AppColor.danger)),
                                    const SizedBox(height: 12),
                                    Stack(
                                      children: [
                                        DateTimePicker(
                                          type: isSwitched
                                              ? DateTimePickerType.date
                                              : DateTimePickerType.dateTime,
                                          dateMask: isSwitched
                                              ? 'd MMMM, yyyy '
                                              : 'd MMMM, yyyy - hh:mm a',
                                          controller: endDateController,
                                          dateHintText: isSwitched
                                              ? "EVENT END DATE"
                                              : "EVENT END TIME",
                                          firstDate: DateTime(2021),
                                          lastDate: DateTime(2100),
                                          locale: const Locale("en", "US"),
                                          onChanged: (String val) {
                                            debugPrint(val);
                                            endDateController.text = val;
                                            if (!isSwitched) {
                                              if (DateTime.parse(
                                                      endDateController.text)
                                                  .isBefore(DateTime.now())) {
                                                endShowNotification = false;
                                              } else {
                                                endShowNotification = true;
                                              }
                                            } else {
                                              DateTime date = DateTime.parse(
                                                  endDateController.text);
                                              if (DateTime(date.year,
                                                      date.month, date.day)
                                                  .isBefore(DateTime(
                                                      DateTime.now().year,
                                                      DateTime.now().month,
                                                      DateTime.now().day))) {
                                                endShowNotification = false;
                                              } else {
                                                endShowNotification = true;
                                              }
                                            }
                                          },
                                          icon: const Icon(
                                              Icons.watch_later_outlined,
                                              color: AppColor.primary),
                                        ),
                                        endDateController.text.isEmpty
                                            ? Container()
                                            : Positioned(
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          endDateController
                                                              .clear();
                                                          endShowNotification =
                                                              true;
                                                        });
                                                      },
                                                      icon: const Icon(
                                                          Icons.close,
                                                          color:
                                                              AppColor.danger)),
                                                ),
                                              )
                                      ],
                                    ),
                                    SizedBox(
                                        height: endShowNotification ? 0 : 8),
                                    endShowNotification
                                        ? Container()
                                        : Text(
                                            "Since the event ends before the current date, no notification will be sent to the attendees (if any).",
                                            style: CustomTextStyle.smallText
                                                .copyWith(
                                                    fontStyle: FontStyle.italic,
                                                    color: AppColor.danger)),
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: () => currentFocus
                                          .requestFocus(FocusNode()),
                                      child: TextFieldWidget(
                                        autofocus: false,
                                        hintText: "LOCATION",
                                        textEditingController:
                                            locationController,
                                        obscureText: false,
                                        textInputType: TextInputType.text,
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                        prefixIcon: const Icon(
                                            Icons.location_pin,
                                            color: AppColor.primary),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Padding(
                                      padding:
                                          EdgeInsets.only(top: 8, bottom: 4),
                                      child: Text("DESCRIPTION",
                                          style: CustomTextStyle
                                              .hintSmallTextBold),
                                    ),
                                    GestureDetector(
                                      onTap: () => FocusScope.of(context)
                                          .requestFocus(FocusNode()),
                                      child: TextFieldWidget(
                                        autofocus: false,
                                        hintText: "Add event description...",
                                        textEditingController:
                                            descriptionController,
                                        maxLines: 4,
                                        obscureText: false,
                                        textInputType:
                                            TextInputType.visiblePassword,
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColor.primaryDark,
                                              width: 1.5),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColor.primary,
                                              width: 1),
                                        ),
                                        disabledBorder:
                                            const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColor.muted, width: 1),
                                        ),
                                        errorBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColor.danger,
                                              width: 1.5),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => currentFocus
                                                .requestFocus(FocusNode()),
                                            child: TextFieldWidget(
                                              autofocus: false,
                                              hintText: "ATTENDEES",
                                              textEditingController:
                                                  attendeesController,
                                              obscureText: false,
                                              textInputType: TextInputType.text,
                                              contentPadding:
                                                  const EdgeInsets.all(12),
                                              prefixIcon: const Icon(
                                                  Icons.groups,
                                                  color: AppColor.primary),
                                              onChanged: (String val) {
                                                setState(() {});
                                              },
                                              suffixIcon: attendeesController
                                                      .text.isEmpty
                                                  ? const SizedBox()
                                                  : IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          attendeesController
                                                              .clear();
                                                        });
                                                      },
                                                      icon: const Icon(
                                                        Icons.close,
                                                        color: AppColor.danger,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Material(
                                          color: AppColor.primary,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: TextButton(
                                            onPressed: () {
                                              debugPrint("Print");

                                              if (validateEmail(
                                                      context: context,
                                                      value: attendeesController
                                                          .text) ==
                                                  null) {
                                                setState(() {
                                                  EventAttendee eventAttendee =
                                                      EventAttendee();
                                                  eventAttendee.email =
                                                      attendeesController.text
                                                          .trim();

                                                  if (attendeesList!.every(
                                                      (element) =>
                                                          element.email !=
                                                          attendeesController
                                                              .text
                                                              .trim())) {
                                                    attendeesController.clear();
                                                    attendeesList
                                                        ?.add(eventAttendee);
                                                  } else {
                                                    showToast(
                                                        message:
                                                            "Email already added");
                                                  }
                                                });
                                                debugPrint(
                                                    "Attendees list: $attendeesList");
                                              } else {
                                                showToast(
                                                    message:
                                                        "${validateEmail(context: context, value: attendeesController.text, fieldName: "Attendees email")}");
                                              }
                                            },
                                            child: const Text(
                                              "ADD",
                                              style:
                                                  CustomTextStyle.bodyTextLight,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    attendeesList!.isEmpty
                                        ? const SizedBox()
                                        : Container(
                                            decoration: BoxDecoration(
                                                color: AppColor.light,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                child: Wrap(
                                                  direction: Axis.horizontal,
                                                  children: attendeesList!
                                                      .map<Widget>((item) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: attendeesTag(item),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        OutlinedButton.icon(
                                          icon: const Icon(
                                            Icons.attach_file,
                                            color: AppColor.primary,
                                          ),
                                          onPressed: () {
                                            Utilities.openActivity(context,
                                                    const DriveFilesList())
                                                .then((data) {
                                              debugPrint(
                                                  "Attachment value: ${eventProvider.selectedFileList}");
                                            });
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all<Color?>(
                                                    AppColor.light),
                                            side: WidgetStateProperty.all<
                                                    BorderSide?>(
                                                const BorderSide(
                                                    color: AppColor.primary)),
                                          ),
                                          label: const Text("ATTACHMENTS"),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                      child: eventAttachment!.isEmpty
                                          ? const SizedBox()
                                          : Wrap(
                                              direction: Axis.horizontal,
                                              children: eventAttachment!
                                                  .map<Widget>((item) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: attachmentTag(
                                                    item: item,
                                                    iconData: item.mimeType ==
                                                            "application/pdf"
                                                        ? Icons.picture_as_pdf
                                                        : item.mimeType!
                                                                .startsWith(
                                                                    "image")
                                                            ? Icons.photo
                                                            : Icons
                                                                .file_copy_outlined,
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                    ),
                                    Consumer<EventServiceProvider>(
                                      builder: (context, eventProvider, _) {
                                        return eventProvider
                                                .selectedFileList.isEmpty
                                            ? const SizedBox()
                                            : Container(
                                                width: Utilities.screenWidth(
                                                    context),
                                                color: AppColor.light,
                                                height: 120,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: eventProvider
                                                      .selectedFileList.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Stack(
                                                        clipBehavior: Clip.none,
                                                        children: [
                                                          Center(
                                                            child: Container(
                                                              height: 90,
                                                              width: 110,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  color: AppColor
                                                                      .primaryLight,
                                                                  border: Border.all(
                                                                      color: AppColor
                                                                          .primary)),
                                                              child: Column(
                                                                children: [
                                                                  Expanded(
                                                                    child: eventProvider
                                                                            .selectedFileList[
                                                                                index]
                                                                            .mimeType!
                                                                            .startsWith(
                                                                                "image")
                                                                        ? Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(2.0),
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: BorderRadius.circular(8),
                                                                              child: Image.network(
                                                                                "${eventProvider.selectedFileList[index].thumbnailLink}",
                                                                                fit: BoxFit.cover,
                                                                                width: double.maxFinite,
                                                                                filterQuality: FilterQuality.none,
                                                                                cacheHeight: 80,
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : eventProvider.selectedFileList[index].mimeType! ==
                                                                                "application/pdf"
                                                                            ? const SizedBox(child: Icon(Icons.picture_as_pdf, size: 54, color: AppColor.primary))
                                                                            : Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                  child: Center(
                                                                                    child: Image.network(
                                                                                      "${eventProvider.selectedFileList[index].iconLink}",
                                                                                      fit: BoxFit.cover,
                                                                                      width: 24,
                                                                                      height: 24,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4),
                                                                    child: Text(
                                                                      eventProvider
                                                                          .selectedFileList[
                                                                              index]
                                                                          .name!,
                                                                      maxLines:
                                                                          1,
                                                                      style: CustomTextStyle
                                                                          .extraSmallText,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 2,
                                                            right: -6,
                                                            child: Consumer<
                                                                EventServiceProvider>(
                                                              builder: (context,
                                                                  newsfeedProvider,
                                                                  _) {
                                                                return InkWell(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50),
                                                                  onTap: () {
                                                                    debugPrint(
                                                                        "Remove: ${eventProvider.selectedFileList[index].name}");

                                                                    eventProvider
                                                                        .selectedFileList
                                                                        .remove(
                                                                            eventProvider.selectedFileList[index]);

                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration: const BoxDecoration(
                                                                        color: AppColor
                                                                            .danger,
                                                                        shape: BoxShape
                                                                            .circle),
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            2),
                                                                    child: const Icon(
                                                                        Icons
                                                                            .close,
                                                                        color: AppColor
                                                                            .white,
                                                                        size:
                                                                            20),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: TwoButtonWidget(
                      leftButtonText: "CANCEL",
                      rightButtonText: "EDIT EVENT",
                      rightButtonTextStyle: CustomTextStyle.bodyTextSecondary,
                      leftButtonFunction: () {
                        currentFocus.unfocus();
                        Utilities.closeActivity(context);
                      },
                      rightButtonFuntion: () async {
                        currentFocus.unfocus();

                        final eventProvider = Provider.of<EventServiceProvider>(
                            context,
                            listen: false);
                        final FormState? form = _formKey.currentState;
                        if (form!.validate()) {
                          setState(() {
                            loader = true;
                          });
                          debugPrint(
                              "${titleController.text}, ${calendarController.text}, ${startDateController.text}, ${endDateController.text}, ${descriptionController.text}");

                          final authProvider = Provider.of<AuthServiceProvider>(
                              context,
                              listen: false);
                          authProvider.refreshToken().then((data) async {
                            if (data != "exception") {
                              final result = await eventProvider.updateEvent(
                                context: context,
                                eventId: widget.eventId,
                                calendarId: selectedCalendar == null
                                    ? widget.calendarId
                                    : selectedCalendar?.id,
                                title: titleController.text,
                                startTime: startDateController.text,
                                endTime: endDateController.text,
                                description: descriptionController.text,
                                location: locationController.text,
                                attendees: attendeesList,
                                allDayEvent: isSwitched,
                                eventAttachment: eventAttachment!.isEmpty
                                    ? []
                                    : eventAttachment!,
                                attachments: eventProvider.selectedFileList,
                              );

                              debugPrint("Return Event info: $result");
                              setState(() {
                                loader = false;
                              });
                              if (result != "exception") {
                                if (result.status == "confirmed") {
                                  showToast(
                                      message: "Event updated successfully");
                                  eventProvider.setEventEdited(true);
                                  Utilities.returnDataCloseActivity(
                                      context, "${result.status}");
                                } else {
                                  showToast(message: "Event update failed");
                                }
                              } else {
                                showToast(message: "Event update failed");
                              }
                            } else {
                              tokenExpire(context);
                            }
                          });
                        }
                      },
                      switchButtonDecoration: true,
                    ),
                  ),
                  const ImageIcon(
                    AssetImage('assets/images/rewards_inactive.png'),
                    // size: 300,
                    color: AppColor.muted,
                  )
                ],
              ),
            ),
            loader ? const CustomCircularLoader() : Container()
          ],
        ),
      ),
    );
  }

  Widget attendeesTag(EventAttendee item) {
    return InputChip(
      label: Text(item.email!),
      labelStyle: CustomTextStyle.smallTextBold,
      backgroundColor: AppColor.pale,
      onDeleted: () {
        setState(() {
          if (attendeesList!.isNotEmpty) {
            attendeesList?.remove(item);
            debugPrint("EVENT: ${attendeesList!.length}");
            debugPrint("EVENT c: ${widget.attendees!.length}");
          }
        });
      },
      deleteIcon: const Icon(Icons.cancel, color: AppColor.danger),
    );
  }

  Widget attachmentTag(
      {required EventAttachment item,
      Function()? onPressed,
      IconData? iconData}) {
    return InputChip(
      label: Text(item.title!),
      labelStyle: CustomTextStyle.smallTextLight,
      backgroundColor: AppColor.secondary,
      // onPressed: onPressed ?? () {},
      avatar: Icon(iconData ?? Icons.file_copy,
          color: AppColor.primaryLight, size: 20),
      onDeleted: () {
        debugPrint("Delete this: ${item.fileId}");

        setState(() {
          eventAttachment!.remove(item);
        });
      },
      deleteIcon: const Icon(Icons.cancel, color: AppColor.white),
    );
  }
}
