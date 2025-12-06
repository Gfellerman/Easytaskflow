import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleApiService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      calendar.CalendarApi.calendarScope,
      drive.DriveApi.driveReadonlyScope,
    ],
  );

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<void> signIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print('Error signing in with Google: $error');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  // Renamed from addTaskToCalendar and added attendeeEmail
  Future<void> insertEvent(
      String taskName, DateTime startTime, DateTime endTime, String? attendeeEmail) async {
    final googleUser = await _googleSignIn.signInSilently();
    if (googleUser == null) {
      // User is not signed in, or needs to sign in again.
      return;
    }

    final authHeaders = await googleUser.authHeaders;
    final httpClient = GoogleAuthClient(authHeaders);
    final calendarApi = calendar.CalendarApi(httpClient);

    List<calendar.EventAttendee>? attendees;
    if (attendeeEmail != null) {
      attendees = [calendar.EventAttendee(email: attendeeEmail)];
    }

    final event = calendar.Event(
      summary: taskName,
      start: calendar.EventDateTime(dateTime: startTime),
      end: calendar.EventDateTime(dateTime: endTime),
      attendees: attendees,
    );

    await calendarApi.events.insert(event, 'primary');
  }

  Future<drive.FileList> searchFiles(String query) async {
    final googleUser = await _googleSignIn.signInSilently();
    if (googleUser == null) {
      throw Exception('User not signed in to Google');
    }

    final authHeaders = await googleUser.authHeaders;
    final httpClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(httpClient);

    return await driveApi.files.list(q: "name contains '$query'");
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
