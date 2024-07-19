import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StyledPrice extends StatelessWidget {
  StyledPrice(this.price, {this.style, super.key});

  final double price;
  final TextStyle? style;

  final NumberFormat value = NumberFormat("#,##0.00", "en_US");

  @override
  Widget build(BuildContext context) {
    return Text(
      "\$${value.format(price)}",
      style: style,
    );
  }
}

class StyledDate extends StatelessWidget {
  StyledDate(this.date, {super.key});

  final DateTime date;

  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Text(
      formatter.format(date),
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
