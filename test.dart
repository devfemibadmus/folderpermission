void main() {
  String contentUri =
      "content://com.android.externalstorage.documents/tree/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia%2F.Statuses/document/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia%2F.Statuses%2Fc7963d1a5bf647a48343ef0b59b48ab3.jpg";

  String filePath = convertContentUriToFilePath(contentUri);

  print(filePath);
}

String convertContentUriToFilePath(String contentUri) {
  String prefix = "primary:";
  String newPathPrefix = "/storage/emulated/0/";

  String newPath = contentUri.replaceAll("%2F", "/");
  newPath = newPath.replaceAll("%3A", ":");
  newPath = newPath.replaceAll("%2E", ".");
  //newPath = newPath.replaceAll(prefix, "");
  newPath = newPath.substring(newPath.indexOf('document/') + 9);
  //newPath = newPath.substring(newPath.indexOf(':') + 1);
  newPath = newPath.replaceAll(prefix, newPathPrefix);
  return newPath;
}
