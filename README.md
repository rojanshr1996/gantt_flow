# Gantt Mobile

A scheduling app based on Flutter where user can add calendars and events and show it in a Gantt Chart. It shows multiple calendars at once where users can see the events on a timeline. With a quick glance, you can identify scheduling gaps and prevent overbooking.

With the sharable Google calendars, multiple users can view the calendar and see the event timeline of other users with whom the calendars have been shared.

## Getting Started
### Login

The app uses Google Sign In method in order to login the app and get the google calendars of the user. Firebase Authentication has been used to allow for Google Sign in and saves the logged in use info.

Users are required to give the calendar scope permission and google drive permission.

Calendar permission is for fetching Calendars and doing CRUD operations on the events of the calendar.
Google Drive permission is to access users drive to fetch the images and files in order to add to the event.
<br><br>
<img src="assets/screenshots/login.png" alt="Login Screen" height="380" width="170"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<img src="assets/screenshots/googleSign.png" alt="Google Account Enter" height="380" width="170">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<img src="assets/screenshots/googlePermission.png" alt="Give Calendar permission" height="380" width="170">
<br><br>

### Home

Once user signs in, they are greeted with the home screen which contains a `Add Calendar`  button from which new calendars can be added to the application.
<br><br>
<img src="assets/screenshots/home.png" alt="Home Screen" height="380" width="170">
<br><br>
User can add new calendars by selecting the calendar from the dialog box. When user selects the calendar, the calendar is added to the home screen in the form of Gantt Chart with events shown as the timeline of the Gantt Chart.

There are two date format that can be toggled to show the Gantt Chart i.e `Month` and  `Year`.

<br><br>
<img src="assets/screenshots/addCalendar.png" alt="Add Calendar" height="380" width="170">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<img src="assets/screenshots/ganttChart.png" alt="Gantt Chart Screen" height="380" width="170">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<img src="assets/screenshots/changeGanttView.png" alt="Change Calendar date" height="380" width="170">

There is a `Menu bar` in the home screen which contains three buttons. 

`Add calendar` button is used to add new calendar to the Gantt Chart

`Add Event` button is used to create new event in the calendar that is selected by the user

`PDF` button is used to create a PDF document of the Gantt Charts selected by the user

<img src="assets/screenshots/menubar.png" alt="Google Account Enter" height="50" width="250">
<br><br>

### Event

User can add event to the google calendars directly from the application. This created event will be shown in the timeline in the Gantt Chart also based on the event start and end date.

`Attendees` and `Attachments` can also be attached to the Event.

<img src="assets/screenshots/addEvent.png" alt="Add Event" height="380" width="170">
<br><br>

Similarly, use can also edit the created event and also delete the event from the app itself. Deleting and editing the event from the app will result the app to also be deleted from all the instances of Google Calendar where the user has logged in.
<br><br>
<img src="assets/screenshots/eventDetail.png" alt="Event Detail Screen" height="380" width="170"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<img src="assets/screenshots/deleteEvent.png" alt="Delete Event" height="380" width="170">&nbsp;&nbsp;&nbsp;&nbsp;
<br><br>

### Profile

Profile cannot be edited and is fetched from the Google profile data.

<br><br>
<img src="assets/screenshots/profile.png" alt="Profile Screen" height="380" width="170">

### PDF

The gantt chart can be printed as a PDF and shared in other platforms or can ve saved in the device storage.
<br><br>
<img src="assets/screenshots/ganttpdf.png" alt="PDF generate Screen" height="380" width="170">




