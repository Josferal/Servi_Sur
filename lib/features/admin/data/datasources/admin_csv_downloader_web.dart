// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

// TODO(firebase): Replace local CSV generation with secure report exports
// once admin data is served by Firebase/Cloud Functions.
import 'dart:convert';
import 'dart:html' as html;

Future<bool> downloadCsv(String csv, String filename) async {
  final bytes = utf8.encode(csv);
  final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';

  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
  return true;
}
