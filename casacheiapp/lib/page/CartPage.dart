import 'package:casacheiapp/page/CartItem.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CartPage extends StatefulWidget { 
  // Lista estática para ser acessível de qualquer lugar da aplicação.
  static final List<CartItem> staticCartItems = [];
  CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String? _selectedPaymentMethod;

  // Lista de métodos de pagamento - apenas Dinheiro e Cartão
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Dinheiro',
      'icon': Icons.money,
      'description': 'Pagamento na entrega',
      'type': 'presencial'
    },
    {
      'name': 'Cartão',
      'icon': Icons.credit_card,
      'description': 'Cartão de crédito/débito',
      'type': 'online'
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  double get _totalPrice {
    double total = 0;
    for (final cartItem in CartPage.staticCartItems) {
      total += cartItem.product.price * cartItem.quantity;
    }
    return total;
  }

  void _incrementQuantity(int index) {
    setState(() {
      CartPage.staticCartItems[index].quantity++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (CartPage.staticCartItems[index].quantity > 1) {
        CartPage.staticCartItems[index].quantity--;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      CartPage.staticCartItems.removeAt(index);
    });
  }

  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) => _buildPaymentModal(),
    );
  }

  void _showConfirmationDialog(String method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pedido Enviado!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: Kz ${_totalPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Pagamento: $method'),
            const SizedBox(height: 8),
            const Text('Seu pedido foi enviado com sucesso!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fecha o dialog
              Navigator.pop(context); // Fecha o modal de pagamento
              // Aqui você pode adicionar lógica para limpar o carrinho
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showOnlinePaymentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Insira os dados do Cartão', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 24),
            const TextField(decoration: InputDecoration(labelText: 'Número do Cartão')),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'Validade (MM/AA)'))),
                SizedBox(width: 16),
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'CVV'))),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o modal de pagamento online
                _showConfirmationDialog('Cartão');
              },
              child: const Text('Pagar Agora'),
            ),
            const SizedBox(height: 16),
          ],
        ),
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
      body: CartPage.staticCartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // Lista de itens
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: CartPage.staticCartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = CartPage.staticCartItems[index];

                      return _buildCartItem(
                        cartItem,
                        index,
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
    CartItem cartItem,
    int index,
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
          child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                cartItem.product.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            )


            ,
        ),
        title: Text(
          cartItem.product.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Kz ${cartItem.product.price.toStringAsFixed(2)}',
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
                      color: cartItem.quantity > 1 ? Colors.red : Colors.grey[400],
                    ),
                    onPressed: cartItem.quantity > 1
                        ? () => _decrementQuantity(index)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Quantidade
                Text(
                  cartItem.quantity.toString(),
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
                  'Kz ${(cartItem.product.price * cartItem.quantity).toStringAsFixed(2)}',
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
    return StatefulBuilder(builder: (BuildContext context, StateSetter modalSetState) {
      return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do modal de pagamento
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.payment, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Método de Pagamento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Lista de métodos de pagamento
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final paymentMethod = _paymentMethods[index];
                final isSelected = _selectedPaymentMethod == paymentMethod['name']; 

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  elevation: isSelected ? 2 : 1,
                  child: ListTile(
                    leading: Icon(
                      paymentMethod['icon'] as IconData,
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[700],
                      size: 28,
                    ),
                    title: Text(
                      paymentMethod['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      paymentMethod['description'],
                      style: TextStyle(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[600],
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          )
                        : const Icon(
                            Icons.radio_button_unchecked,
                            color: Colors.grey,
                            size: 24,
                          ),
                    onTap: () {
                      modalSetState(() {
                        _selectedPaymentMethod = paymentMethod['name'];
                      });
                      
                      // Se for Cartão, abre o modal de pagamento online
                      if (paymentMethod['type'] == 'online') {
                        Future.delayed(Duration.zero, () {
                          Navigator.pop(context); // Fecha o modal atual
                          _showOnlinePaymentModal();
                        });
                      }
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Botão de enviar pedido (apenas para Dinheiro)
          if (_selectedPaymentMethod == 'Dinheiro') ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Kz ${_totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Método selecionado:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _selectedPaymentMethod!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog(_selectedPaymentMethod!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Enviar Pedido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else if (_selectedPaymentMethod == null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Selecione um método de pagamento',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Voltar ao Carrinho'),
            ),
          ),
        ],
      ),
    );
    });
  }
}