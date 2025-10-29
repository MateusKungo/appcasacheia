import 'package:flutter/material.dart';

class Product {
  final String name;
  final double price;
  final String image;
  final String category;

  const Product({
    required this.name,
    required this.price,
    required this.image,
    required this.category,
  });
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final List<Product> _cartItems = [];
  String _selectedCategory = 'Todos';
  
  final List<Product> _products = [
    // Grãos
    Product(name: 'Arroz Integral', price: 2500, image: '🍚', category: 'Grãos'),
    Product(name: 'Feijão Vermelho', price: 1800, image: '🫘', category: 'Grãos'),
    Product(name: 'Milho Seco', price: 1200, image: '🌽', category: 'Grãos'),
    Product(name: 'Farinha de Trigo', price: 1500, image: '🌾', category: 'Grãos'),
    Product(name: 'Açúcar Branco', price: 1400, image: '🍚', category: 'Grãos'),
    Product(name: 'Feijão Preto', price: 2000, image: '🫘', category: 'Grãos'),
    Product(name: 'Arroz Branco', price: 2200, image: '🍚', category: 'Grãos'),
    Product(name: 'Fuba de Milho', price: 1100, image: '🌽', category: 'Grãos'),
    
    // Bebidas
    Product(name: 'Água Mineral 1.5L', price: 200, image: '💧', category: 'Bebidas'),
    Product(name: 'Sumo de Laranja', price: 800, image: '🧃', category: 'Bebidas'),
    Product(name: 'Refrigerante', price: 600, image: '🥤', category: 'Bebidas'),
    Product(name: 'Cerveja Nacional', price: 400, image: '🍺', category: 'Bebidas'),
    Product(name: 'Vinho Tinto', price: 3500, image: '🍷', category: 'Bebidas'),
    Product(name: 'Sumo de Manga', price: 750, image: '🧃', category: 'Bebidas'),
    Product(name: 'Água com Gás', price: 250, image: '💧', category: 'Bebidas'),
    Product(name: 'Energético', price: 900, image: '🥤', category: 'Bebidas'),
    
    // Enlatados
    Product(name: 'Atum em Lata', price: 1200, image: '🐟', category: 'Enlatados'),
    Product(name: 'Sardinha', price: 800, image: '🐠', category: 'Enlatados'),
    Product(name: 'Milho em Conserva', price: 900, image: '🌽', category: 'Enlatados'),
    Product(name: 'Feijão Enlatado', price: 1100, image: '🫘', category: 'Enlatados'),
    Product(name: 'Ervilhas', price: 950, image: '🫛', category: 'Enlatados'),
    Product(name: 'Cogumelos', price: 1300, image: '🍄', category: 'Enlatados'),
    
    // Higiene
    Product(name: 'Sabonete', price: 300, image: '🧼', category: 'Higiene'),
    Product(name: 'Pasta Dental', price: 700, image: '🦷', category: 'Higiene'),
    Product(name: 'Shampoo', price: 1200, image: '🧴', category: 'Higiene'),
    Product(name: 'Desodorante', price: 900, image: '🧴', category: 'Higiene'),
    Product(name: 'Papel Higiênico', price: 1500, image: '🧻', category: 'Higiene'),
    Product(name: 'Creme Dental', price: 800, image: '🦷', category: 'Higiene'),
    Product(name: 'Sabão em Pó', price: 1800, image: '🧼', category: 'Higiene'),
    Product(name: 'Amaciador', price: 1600, image: '🧴', category: 'Higiene'),
    
    // Laticínios
    Product(name: 'Leite UHT 1L', price: 600, image: '🥛', category: 'Laticínios'),
    Product(name: 'Queijo', price: 1800, image: '🧀', category: 'Laticínios'),
    Product(name: 'Manteiga', price: 1000, image: '🧈', category: 'Laticínios'),
    Product(name: 'Iogurte Natural', price: 400, image: '🥛', category: 'Laticínios'),
    Product(name: 'Leite Condensado', price: 800, image: '🥛', category: 'Laticínios'),
    Product(name: 'Requeijão', price: 1200, image: '🧀', category: 'Laticínios'),
    Product(name: 'Iogurte de Morango', price: 450, image: '🥛', category: 'Laticínios'),
    
    // Cestas
    Product(name: 'Cesta Básica Pequena', price: 15000, image: '🛒', category: 'Cestas'),
    Product(name: 'Cesta Básica Média', price: 25000, image: '🛒', category: 'Cestas'),
    Product(name: 'Cesta Básica Grande', price: 35000, image: '🛒', category: 'Cestas'),
    Product(name: 'Cesta Familiar', price: 45000, image: '🛒', category: 'Cestas'),
  ];

  final List<String> _categories = [
    'Todos',
    'Grãos',
    'Bebidas',
    'Enlatados',
    'Higiene',
    'Laticínios',
    'Cestas',
  ];

  void _addToCart(Product product) {
    setState(() {
      _cartItems.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} adicionado ao carrinho'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'Todos') {
      return _products;
    }
    return _products.where((product) => product.category == _selectedCategory).toList();
  }

  double get _totalPrice {
    return _cartItems.fold(0, (total, product) => total + product.price);
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(2)} Kz';
  }

  void _showCartDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) => _buildCartModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos os Produtos'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: colorScheme.primary,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: colorScheme.primary),
                onPressed: _showCartDialog,
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _cartItems.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro de Categorias
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8, top: 12, bottom: 12),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: colorScheme.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? colorScheme.primary : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: isSelected ? colorScheme.primary : Colors.grey[300]!,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Lista de Produtos em Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72, // Ajustado para melhor proporção
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  
                  return _buildProductCard(product, colorScheme);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem do produto
                Container(
                  height: constraints.maxWidth * 0.5, // Altura proporcional à largura
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      product.image,
                      style: const TextStyle(fontSize: 32), // Tamanho reduzido
                    ),
                  ),
                ),

                // Informações do produto - Usando Expanded para evitar overflow
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nome e categoria
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.category,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // Preço e botão
                        Column(
                          children: [
                            Text(
                              _formatPrice(product.price),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: double.infinity,
                              height: 32,
                              child: FilledButton.icon(
                                onPressed: () => _addToCart(product),
                                style: FilledButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                ),
                                icon: const Icon(
                                  Icons.add_shopping_cart,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Adicionar',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCartModal() {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabeçalho do carrinho
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Meu Carrinho',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_cartItems.length} itens',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Lista de itens no carrinho
          if (_cartItems.isEmpty)
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Carrinho vazio',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _cartItems.length,
                itemBuilder: (context, index) {
                  final product = _cartItems[index];
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            product.image,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      title: Text(
                        product.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        _formatPrice(product.price),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => _removeFromCart(index),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Total e ações
          if (_cartItems.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatPrice(_totalPrice),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implementar finalização de compra
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Finalizar Compra',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar Comprando'),
          ),
        ],
      ),
    );
  }
}