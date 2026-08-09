import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

var _channelCounter = 0;

/// Re-fetches [fetch] whenever the given table changes, so the value stays in
/// real time without polling. Use for values that are not a simple list — a
/// single row, a count, or a flag — where PostgREST's `.stream(primaryKey:)`
/// doesn't fit.
///
/// [filter] is a Postgres Change filter (e.g. `id=eq.123`) that narrows which
/// changes trigger a re-fetch; use it to avoid refetching on unrelated rows.
/// The channel is torn down when the returned stream is cancelled.
Stream<T> supabaseLiveStream<T>({
  required String table,
  required Future<T> Function() fetch,
  sb.PostgresChangeFilter? filter,
  String? channelName,
  String? schema,
}) {
  final client = sb.Supabase.instance.client;
  final controller = StreamController<T>();
  var disposed = false;

  Future<void> refresh() async {
    if (disposed) return;
    try {
      controller.add(await fetch());
    } catch (error, stackTrace) {
      if (!disposed) controller.addError(error, stackTrace);
    }
  }

  final channel = client
      .channel(channelName ?? 'live-$table-${_channelCounter++}')
      .onPostgresChanges(
        event: sb.PostgresChangeEvent.all,
        schema: schema ?? 'public',
        table: table,
        filter: filter,
        callback: (_) => refresh(),
      )
      .subscribe();

  refresh();

  controller.onCancel = () async {
    disposed = true;
    await client.removeChannel(channel);
  };

  return controller.stream;
}
