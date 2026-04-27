import 'package:http/http.dart' as http;

void main() async {
  try {
    final response = await http.get(
      Uri.parse('https://i.ibb.co/W4X3GS6c/b173e89886ef.png'),
      headers: {'User-Agent': 'Mozilla/5.0'}
    );
    print('Status: \${response.statusCode}');
    print('Length: \${response.bodyBytes.length}');
  } catch (e) {
    print('Error: \$e');
  }
}
