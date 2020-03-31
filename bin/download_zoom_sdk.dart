import 'dart:core';
import 'dart:io';


void main() {

  var location = Platform.script.toString().replaceFirst("file://", "").replaceFirst("/bin/download_zoom_sdk.dart", "");

  print(location);

  HttpClient client = new HttpClient();
  var _downloadData = List<int>();
  var fileSave = new File(location + '/logo.png');
  client.getUrl(Uri.parse("https://assets.website-files.com/5e130ef44b55b08a66410bb1/5e131166946b12bd3abfddd4_logo.png"))
      .then((HttpClientRequest request) {
    return request.close();
  })
      .then((HttpClientResponse response) {
    response.listen((d) => _downloadData.addAll(d),
        onDone: () {
          fileSave.writeAsBytes(_downloadData);
        }
    );
  });
}
