String formatCurrency(int cents) {
  final value = cents / 100;
  return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
}
