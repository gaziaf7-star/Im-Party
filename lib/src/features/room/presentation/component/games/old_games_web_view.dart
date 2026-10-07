// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:general/src/features/games/presentation/games/bloc/explore/explore_bloc.dart';
// import '../../../../../core/index.dart';

// class WebViewInRoom extends StatefulWidget {
//   final String url;
//   const WebViewInRoom({required this.url, super.key});

//   @override
//   State<WebViewInRoom> createState() => _WebViewInRoomState();
// }

// class _WebViewInRoomState extends State<WebViewInRoom> {
//   InAppWebViewController? _webViewController;

//   @override
//   void didUpdateWidget(covariant WebViewInRoom oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     final newUri = Uri.tryParse(widget.url);
//     if (oldWidget.url != widget.url && _webViewController != null && newUri != null) {
//       _webViewController!.loadUrl(
//         urlRequest: URLRequest(url: WebUri.uri(newUri)),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       onPopInvokedWithResult: (_, __) {
//         di<ExploreBloc>().add(const StopGameEvent());
//         Navigator.pop(context);
//       },
//       child: InAppWebView(
//         initialUrlRequest: URLRequest(
//           url: WebUri.uri(Uri.parse(widget.url)),
//         ),
//         onWebViewCreated: (controller) {
//           _webViewController = controller;
//         },
//       ),
//     );
//   }
// }
