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

class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  TextEditingController titleController = TextEditingController();
  TextEditingController calendarController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController attendeesController = TextEditingController();

  /// in order to check if the event is all day event or not.
  bool isSwitched = true;

  List<String> attachemnts = [];

  List<EventAttendee>? attendeesList = [];

  CalendarListEntry? selectedCalendar;

  DateTime startCheckDate = DateTime.now();
  DateTime endCheckDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  bool loader = false;

  bool startShowNotification = true;
  bool endShowNotification = true;

  @override
  void initState() {
    clearSelection();
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    calendarController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
    locationController.dispose();
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
      }
    });
  }

  void clearSelection() {
    final eventProvider =
        Provider.of<EventServiceProvider>(context, listen: false);
    eventProvider.clearFileList();
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
          title: const AppBarTitle(title: "Create Event"),
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
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: ListView(
                                  children: [
                                    GestureDetector(
                                      onTap: () => currentFocus
                                          .requestFocus(FocusNode()),
                                      child: TextFieldWidget(
                                        autofocus: false,
                                        hintText: "EVENT TITLE",
                                        textEditingController: titleController,
                                        obscureText: false,
                                        textInputType: TextInputType.text,
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
                                    TextFieldWidget(
                                      autofocus: false,
                                      onTap: () {
                                        currentFocus.unfocus();
                                        showCalendarDialog();
                                      },
                                      hintText: "SELECT CALENDAR",
                                      textEditingController: calendarController,
                                      obscureText: false,
                                      textInputType: TextInputType.text,
                                      suffixIcon: calendarController
                                              .text.isEmpty
                                          ? const Icon(Icons.arrow_drop_down,
                                              color: AppColor.primary)
                                          : IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  calendarController.clear();
                                                  selectedCalendar = null;
                                                });
                                              },
                                              icon: const Icon(Icons.close),
                                              color: AppColor.danger,
                                            ),
                                      contentPadding: const EdgeInsets.all(12),
                                      disabledBorder:
                                          const UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: AppColor.primary,
                                                  width: 1)),
                                      prefixIcon: const Icon(
                                          Icons.calendar_today,
                                          color: AppColor.primary),
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
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
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
                                            setState(() {
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
                                            });
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
                                      onTap: () => currentFocus
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
                                                  EventAttendee();

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
                                    const SizedBox(height: 4),
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
                                    SizedBox(
                                        height:
                                            attendeesList!.isEmpty ? 12 : 4),
                                    Row(
                                      children: [
                                        OutlinedButton.icon(
                                          icon: const Icon(
                                            Icons.attach_file,
                                            color: AppColor.primary,
                                          ),
                                          onPressed: () {
                                            Utilities.openActivity(context,
                                                const DriveFilesList());
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
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
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
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              2.0),
                                                                          child:
                                                                              ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                            child:
                                                                                Image.network(
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
                                                                          ? const SizedBox(
                                                                              child: Icon(Icons.picture_as_pdf, size: 54, color: AppColor.primary))
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
                                                                    maxLines: 1,
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
                                                                  eventProvider
                                                                      .selectedFileList
                                                                      .remove(eventProvider
                                                                              .selectedFileList[
                                                                          index]);

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
                                                                      size: 20),
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
                                    }),
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
                      rightButtonText: "CREATE EVENT",
                      rightButtonTextStyle: CustomTextStyle.bodyTextSecondary,
                      leftButtonFunction: () {
                        currentFocus.unfocus();
                        eventProvider.selectedFileList = [];
                        Utilities.closeActivity(context);
                      },
                      rightButtonFuntion: () async {
                        currentFocus.unfocus();

                        final eventProvider = Provider.of<EventServiceProvider>(
                            context,
                            listen: false);
                        final FormState? form = _formKey.currentState;

                        if (selectedCalendar != null) {
                          if (form!.validate()) {
                            if (DateTime.parse(endDateController.text).isBefore(
                                DateTime.parse(startDateController.text))) {
                              showToast(
                                  message:
                                      "End date cannot come before start date.");
                            } else {
                              setState(() {
                                loader = true;
                              });

                              final authProvider =
                                  Provider.of<AuthServiceProvider>(context,
                                      listen: false);

                              authProvider.refreshToken().then((data) async {
                                if (data != "exception") {
                                  final result =
                                      await eventProvider.insertEvent(
                                          context: context,
                                          calendarId: selectedCalendar?.id,
                                          title: titleController.text,
                                          startTime: startDateController.text,
                                          endTime: endDateController.text,
                                          description:
                                              descriptionController.text,
                                          location: locationController.text,
                                          allDayEvent: isSwitched,
                                          attachments:
                                              eventProvider.selectedFileList,
                                          attendees: attendeesList);

                                  setState(() {
                                    loader = false;
                                  });
                                  if (result != "exception") {
                                    if (result.status == "confirmed") {
                                      // Mark that an event was created so home screen reloads
                                      eventProvider.setEventEdited(true);
                                      showToast(
                                          message:
                                              "Event created successfully");
                                      Utilities.returnDataCloseActivity(
                                          context, "${result.status}");
                                    } else {
                                      showToast(
                                          message: "Event creation failed");
                                    }
                                  } else {
                                    showToast(message: "Event creation failed");
                                  }
                                } else {
                                  tokenExpire(context);
                                }
                              });
                            }
                          }
                        } else {
                          showToast(
                              message: "Please select a calendar to continue");
                        }
                      },
                      switchButtonDecoration: true,
                    ),
                  ),
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
          }
        });
      },
      deleteIcon: const Icon(Icons.cancel, color: AppColor.danger),
    );
  }
}
