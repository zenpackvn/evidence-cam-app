# RepaintBoundary and Isolates

## RepaintBoundary

Wrap expensive custom paint widgets and frequently animated widgets with `RepaintBoundary`. Each boundary creates a separate render layer, so only that subtree repaints. Do not overuse — each boundary allocates an offscreen buffer.

### Example

```dart
class ChartSection extends StatelessWidget {
  const ChartSection({super.key, required this.data});

  final List<double> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Revenue'),
        // The custom painter repaints on every animation tick.
        // Boundary isolates it so the Text above does not repaint.
        RepaintBoundary(
          child: CustomPaint(
            size: const Size(double.infinity, 200),
            painter: _LineChartPainter(data: data),
          ),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({required this.data});

  final List<double> data;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    final maxY = data.reduce((a, b) => a > b ? a : b);

    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxY) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) => oldDelegate.data != data;
}
```

---

## Heavy Computation with Isolates

Use `Isolate.run()` or the legacy `compute()` for CPU-intensive work: JSON parsing of large payloads, image processing, data aggregation. Never block the main isolate — it causes jank.

### Example: parsing large JSON list in an isolate

```dart
/// In a repository or data source — never in a widget build method.
class OrderRemoteDataSource {
  OrderRemoteDataSource({required this.apiClient});

  final ApiClient apiClient;

  Future<List<Order>> fetchOrders() async {
    final response = await apiClient.get('/orders');
    final jsonString = response.body;

    // Parse on a background isolate — main thread stays responsive.
    final orders = await Isolate.run(() => _parseOrders(jsonString));
    return orders;
  }
}

/// Top-level or static function — required for Isolate.run().
List<Order> _parseOrders(String jsonString) {
  final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
  return jsonList
      .map((e) => Order.fromJson(e as Map<String, dynamic>))
      .toList();
}
```

### WRONG

```dart
// BAD: Parsing a potentially huge JSON list on the main isolate.
Future<List<Order>> fetchOrders() async {
  final response = await apiClient.get('/orders');
  final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
  // If jsonList has 10 000 items, this freezes the UI.
  return jsonList.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
}
```
