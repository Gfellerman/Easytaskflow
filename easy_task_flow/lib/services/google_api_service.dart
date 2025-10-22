import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleApiService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      calendar.CalendarApi.calendarScope,
      drive.DriveApi.driveFileScope,
    ],
  );

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<GoogleSignInAccount?> signIn() async {
    return await _googleSignIn.signIn();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<http.Client> getHttpClient() async {
    final headers = await _googleSignIn.currentUser!.authHeaders;
    return AuthenticatedClient(headers);
  }

  Future<void> insertEvent(String title, DateTime startTime, DateTime endTime, String calendarId) async {
    final client = await getHttpClient();
    final calApi = calendar.CalendarApi(client);

    final event = calendar.Event()
      ..summary = title
      ..start = calendar.EventDateTime(dateTime: startTime.toUtc())
      ..end = calendar.EventDateTime(dateTime: endTime.toUtc());

    await calApi.events.insert(event, calendarId);
    client.close();
  }

  Future<drive.FileList> searchFiles(String query) async {
    final client = await getHttpClient();
    final driveApi = drive.DriveApi(client);
    final fileList = await driveApi.files.list(q: query);
    client.close();
    return fileList;
  }
}

class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final Map<String, String> _headers;

  AuthenticatedClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}
