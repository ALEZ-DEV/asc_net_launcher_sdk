import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf_io;
import 'package:shelf/shelf_io.dart';
import 'package:shelf_proxy/shelf_proxy.dart';

enum ProxyState {
  idle,
  startProxying,
  proxying,
}

class Proxy {
  Proxy._();
  static final instance = Proxy._();

  final List<String> _urlToRedirect = [
    "http://prod-encdn-akamai.kurogame.net",
    "https://prod-zspnslog.kurogame.net:50443",
    "https://ipv4.icanhazip.com",
    "http://prod-encdn-aliyun.kurogame.net",
    "https://kurogame.net",
  ];

  final _redirectedIp = "127.0.0.1";
  final _redirectedPort = 80;

  List<HttpServer> _proxyingServer = [];

  void Start() async {
    List<HttpServer> _servers = [];

    for (String url in _urlToRedirect) {
      final server = await serve(
        proxyHandler(url),
        _redirectedIp,
        _redirectedPort,
      );

      server.listen(
        (event) => _controller.add(event.requestedUri.toString()),
      );
      _controller.add(
          'Start proxying from $url to https://${server.address.host}:${server.port}');

      _servers.add(server);
    }

    _proxyingServer = _servers;
  }

  StreamController<String> _controller = StreamController();
  Stream<String> get stdout => _controller.stream;
}
