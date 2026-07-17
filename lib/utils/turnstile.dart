@JS()
library;

import 'dart:js_interop';

@JS('requestContactTurnstileToken')
external JSPromise<JSString> _requestContactTurnstileToken(JSString siteKey);

Future<String> requestContactTurnstileToken(String siteKey) async {
  final token = await _requestContactTurnstileToken(siteKey.toJS).toDart;
  return token.toDart;
}
