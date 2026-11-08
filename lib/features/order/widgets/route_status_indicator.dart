import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/order/helper/route_polyline.dart';

/// Distinguishes an unavailable road route from provider/network failure.
class RouteStatusIndicator extends StatelessWidget {
  final RouteLoadStatus status;
  final VoidCallback onRetry;
  const RouteStatusIndicator({
    super.key,
    required this.status,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (status == RouteLoadStatus.idle || status == RouteLoadStatus.ready) {
      return const SizedBox.shrink();
    }
    return Material(
      color: Theme.of(context).cardColor,
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == RouteLoadStatus.loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.route_outlined, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                (status == RouteLoadStatus.loading
                        ? 'loading'
                        : status == RouteLoadStatus.noRoute
                        ? 'route_not_found'
                        : 'something_went_wrong')
                    .tr,
              ),
            ),
            if (status != RouteLoadStatus.loading)
              IconButton(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                tooltip: 'retry'.tr,
              ),
          ],
        ),
      ),
    );
  }
}
