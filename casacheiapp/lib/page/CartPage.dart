import 'package:casacheiapp/page/product.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  final List<Product> cartItems;

  const CartPage({super.key, required this.cartItems});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Map<int, int> _itemQuantities = {};

  @override
  void initState() {
    super.initState();
    // Inicializa todas as quantidades como 1
    for (int i = 0; i < widget.cartItems.length; i++) {
      _itemQuantities[i] = 1;
    }
  }

  double get _totalPrice {
    double total = 0;
    for (int i = 0; i < widget.cartItems.length; i++) {
      final product = widget.cartItems[i];
      final quantity = _itemQuantities[i] ?? 1;
      final price = _parsePrice(product.price);
      total += price * quantity;
    }
    return total;
  }

  double _parsePrice(String priceString) {
    try {
      // Remove "Kz" e espaços, substitui vírgula por ponto
      final cleanString = priceString
          .replaceAll('Kz', '')
          .replaceAll(' ', '')
          .replaceAll(',', '.');
      return double.parse(cleanString);
    } catch (e) {
      return 0.0;
    }
  }

  void _incrementQuantity(int index) {
    setState(() {
      _itemQuantities[index] = (_itemQuantities[index] ?? 1) + 1;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      final currentQuantity = _itemQuantities[index] ?? 1;
      if (currentQuantity > 1) {
        _itemQuantities[index] = currentQuantity - 1;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _itemQuantities.remove(index);
      // Em uma aplicação real, você removeria o item da lista principal
      // widget.cartItems.removeAt(index);
    });
  }

  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8), // Mesmo raio do botão (8px)
          topRight: Radius.circular(8), // Mesmo raio do botão (8px)
        ),
      ),
      builder: (context) => _buildPaymentModal(),
    );
  }

  void _selectPaymentMethod(String method) {
    Navigator.pop(context); // Fecha o modal
    // TODO: Implementar lógica do método de pagamento selecionado
    _showConfirmationDialog(method);
  }

  void _showConfirmationDialog(String method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compra Finalizada!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: Kz ${_totalPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Pagamento: $method'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Carrinho'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: colorScheme.primary,
      ),
      body: widget.cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // Lista de itens
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      final quantity = _itemQuantities[index] ?? 1;
                      final itemPrice = _parsePrice(item.price);
                      final totalItemPrice = itemPrice * quantity;

                      return _buildCartItem(
                        item,
                        index,
                        quantity,
                        totalItemPrice,
                        colorScheme,
                      );
                    },
                  ),
                ),

                // Rodapé com total e botão
                _buildFooter(colorScheme),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Seu carrinho está vazio',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione produtos incríveis!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Continuar Comprando'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    Product item,
    int index,
    int quantity,
    double totalItemPrice,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              item.image,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text( // Preço unitário
              'Kz ${_parsePrice(item.price).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Controle de quantidade
            Row(
              children: [
                // Botão diminuir
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 14,
                    icon: Icon(
                      Icons.remove,
                      color: quantity > 1 ? Colors.red : Colors.grey[400],
                    ),
                    onPressed: quantity > 1
                        ? () => _decrementQuantity(index)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Quantidade
                Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                // Botão aumentar
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 14,
                    icon: Icon(
                      Icons.add,
                      color: colorScheme.primary,
                    ),
                    onPressed: () => _incrementQuantity(index),
                  ),
                ),
                const Spacer(),
                // Preço total do item
                Text(
                  'Kz ${totalItemPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
            size: 20,
            color: Colors.red,
          ),
          onPressed: () => _removeItem(index),
        ),
      ),
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Total à esquerda
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Kz ${_totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Botão finalizar compra à direita
          Expanded(
            child: SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _showPaymentModal,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Finalizar Compra',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentModal() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabeçalho do modal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.payment, size: 20),
                SizedBox(width: 8),
                Text(
                  'Escolha a forma de pagamento',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Opções de pagamento
          _buildPaymentOption(
            icon: Icons.storefront_outlined,
            title: 'Pagamento Presencial',
            subtitle: 'Pague na loja quando retirar',
            onTap: () => _selectPaymentMethod('Presencial'),
          ),
          _buildPaymentOption(
            icon: Icons.credit_card_outlined,
            title: 'Pagamento Online',
            subtitle: 'Pague com cartão ou PIX',
            onTap: () => _selectPaymentMethod('Online'),
          ),

          // Botão cancelar
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Mesmo raio do botão
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: const Text('Cancelar'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8), // Mesmo raio do botão
        ),
        child: Icon(icon, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}