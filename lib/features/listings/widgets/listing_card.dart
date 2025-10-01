import 'package:flutter/material.dart';
import 'package:prokat_app/features/listings/domain/listing.dart';

class ListingCard extends StatelessWidget {
  final Listing item;
  const ListingCard({super.key, required this.item});

  String _priceLine() {
    if (item.priceDay != null) return '${item.priceDay!.toStringAsFixed(0)} ₽/день';
    if (item.priceHour != null) return '${item.priceHour!.toStringAsFixed(0)} ₽/час';
    if (item.priceMonth != null) return '${item.priceMonth!.toStringAsFixed(0)} ₽/мес';
    return 'Без цены';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.inventory_2_outlined),
        title: Text(item.title),
        subtitle: Text('${_priceLine()} • ${item.address}'),
        onTap: () {},
      ),
    );
  }
}
