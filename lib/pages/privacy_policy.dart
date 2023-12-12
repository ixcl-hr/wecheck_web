import 'package:html/parser.dart';

class PrivacyPolicyPage {
  main() {
    var document =
        parse('<body>Hello world! <a href="www.html5rocks.com">HTML5 rocks!');
    print(document.outerHtml);
  }
}
