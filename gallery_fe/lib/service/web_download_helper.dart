import 'dart:html' as html;

void downloadFileWeb(List<int> bytes, String filename) {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  final anchor = html.AnchorElement()
    ..href = url
    ..style.display = 'none'
    ..download = filename;
  
  html.document.body?.children.add(anchor);
  anchor.click();
  
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}