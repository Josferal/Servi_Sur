import 'dart:io';

Future<void> main(List<String> args) async {
  final port = _readIntArg(args, '--port', 5764);
  final host = _readStringArg(args, '--host', '127.0.0.1');
  final rootPath = _readStringArg(args, '--root', 'build/web');
  final root = Directory(rootPath).absolute;
  final index = File(_join(root.path, 'index.html'));

  if (!index.existsSync()) {
    stderr.writeln(
      'No se encontro build/web/index.html. Ejecuta primero: flutter build web',
    );
    exitCode = 64;
    return;
  }

  final rootCanonical = root.resolveSymbolicLinksSync();
  final server = await HttpServer.bind(host, port);
  stdout.writeln('Dashboard admin disponible en http://$host:$port/admin');

  await for (final request in server) {
    await _handleRequest(request, rootCanonical, index);
  }
}

Future<void> _handleRequest(
  HttpRequest request,
  String rootCanonical,
  File index,
) async {
  final response = request.response;
  final method = request.method.toUpperCase();

  if (method != 'GET' && method != 'HEAD') {
    response.statusCode = HttpStatus.methodNotAllowed;
    await response.close();
    return;
  }

  final file = _resolveRequestFile(request, rootCanonical, index);
  if (file == null) {
    response.statusCode = HttpStatus.forbidden;
    await response.close();
    return;
  }

  response.headers
    ..contentType = ContentType.parse(_contentType(file.path))
    ..set(HttpHeaders.cacheControlHeader, 'no-store');

  if (method == 'HEAD') {
    await response.close();
    return;
  }

  await response.addStream(file.openRead());
  await response.close();
}

File? _resolveRequestFile(
  HttpRequest request,
  String rootCanonical,
  File index,
) {
  final uriPath = Uri.decodeComponent(request.uri.path);
  final relativePath = uriPath == '/'
      ? 'index.html'
      : uriPath.substring(1).replaceAll('/', Platform.pathSeparator);
  final candidate = File(_join(rootCanonical, relativePath));

  if (candidate.existsSync()) {
    final candidateCanonical = candidate.resolveSymbolicLinksSync();
    if (!candidateCanonical.startsWith(rootCanonical)) {
      return null;
    }
    return File(candidateCanonical);
  }

  return index;
}

String _contentType(String path) {
  final extension = path.split('.').last.toLowerCase();
  return switch (extension) {
    'html' => 'text/html; charset=utf-8',
    'js' => 'text/javascript; charset=utf-8',
    'css' => 'text/css; charset=utf-8',
    'json' => 'application/json; charset=utf-8',
    'png' => 'image/png',
    'jpg' || 'jpeg' => 'image/jpeg',
    'svg' => 'image/svg+xml',
    'ico' => 'image/x-icon',
    'wasm' => 'application/wasm',
    'ttf' => 'font/ttf',
    _ => 'application/octet-stream',
  };
}

int _readIntArg(List<String> args, String name, int fallback) {
  final value = _readStringArg(args, name, fallback.toString());
  return int.tryParse(value) ?? fallback;
}

String _readStringArg(List<String> args, String name, String fallback) {
  final equalsPrefix = '$name=';
  for (var index = 0; index < args.length; index++) {
    final arg = args[index];
    if (arg.startsWith(equalsPrefix)) {
      return arg.substring(equalsPrefix.length);
    }
    if (arg == name && index + 1 < args.length) {
      return args[index + 1];
    }
  }
  return fallback;
}

String _join(String left, String right) {
  if (left.endsWith(Platform.pathSeparator)) {
    return '$left$right';
  }
  return '$left${Platform.pathSeparator}$right';
}
