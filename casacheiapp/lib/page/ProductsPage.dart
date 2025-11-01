import 'dart:convert';
import 'dart:async'; // Import para usar TimeoutException
import 'package:casacheiapp/page/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final List<Product> _cartItems = [];
  List<Product> _products = [];
  String _selectedCategory = 'Todos';
  bool _isLoading = true;
  bool _isRetrying = false; // Novo estado para o botão de tentar novamente
  String? _error;

  final List<String> _categories = [
    'Todos',
    'Grãos',
    'Bebidas',
    'Enlatados',
    'Higiene',
    'Laticínios',
    'Cestas',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Função auxiliar para extrair números de forma segura
  double _parseDynamicNumber(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    // Verifica se é um mapa (comum em respostas de MongoDB, ex: {"$numberDecimal": "15000"})
    if (value is Map && value.containsKey('\$numberDecimal')) {
      return double.tryParse(value['\$numberDecimal'].toString()) ?? 0.0;
    }
    // Retorna 0.0 se não conseguir converter
    debugPrint('Não foi possível converter o valor: $value para double.');
    return 0.0;
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isRetrying = true; // Ativa o estado de carregamento do botão
    });
    try {
      final response = await http.get(
        Uri.parse('https://casa-fscp.onrender.com/api.casacheia/products'),
      ).timeout(const Duration(seconds: 15)); // Adiciona um timeout de 15 segundos

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        // A API retorna um objeto, e a lista de produtos está dentro de uma chave (ex: 'products')
        final List<dynamic> data = responseBody['formatted'] ?? [];

        setState(() {
          _products = data.map<Product>((json) {
            // Mapeia o ID da categoria para um nome legível.
            final categoryId = json['category']?.toString() ?? '';
            final categoryName = {
              '6904dc7f2195ccf3cdb1a10a': 'Laticínios',
              '6904dcd22195ccf3cdb1a10d': 'Grãos',
              // Adicione outros mapeamentos de ID para nome aqui
            }[categoryId] ?? 'Outros';

            // Extrai a URL da imagem
            String imageUrl = 'https://via.placeholder.com/150'; // Imagem padrão
            if (json['image'] is List && (json['image'] as List).isNotEmpty) {
              imageUrl = (json['image'] as List).first.toString();
            } else if (json['image'] is String && json['image'].isNotEmpty) {
              imageUrl = json['image'];
            }

            return Product(
              id: json['_id'] ?? '',
              name: json['name'] ?? 'Produto sem nome',
              price: _parseDynamicNumber(json['price']),
              category: categoryName,
              stock: _parseDynamicNumber(json['stock']).toInt(),
              description: json['description'] ?? '',
              image: imageUrl,
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        // Adiciona um log para o console quando a resposta não for 200
        debugPrint('Falha ao carregar produtos. Status: ${response.statusCode}');
        debugPrint('Corpo da resposta: ${response.body}');
        setState(() {
          _error = 'Falha ao carregar produtos: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } on TimeoutException {
      // Adiciona um log para o console em caso de timeout
      debugPrint('Erro: Timeout ao buscar produtos.');
      // Trata o erro de tempo limite esgotado
      setState(() {
        _error = 'A requisição demorou muito para responder. Verifique sua conexão e tente novamente.';
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      // Adiciona um log para o console para outras exceções
      debugPrint('Erro de conexão ao buscar produtos: $e');
      debugPrint('StackTrace: $stackTrace');
      setState(() {
        _error = 'Erro de conexão: $e';
        _isLoading = false;
      });
    } finally {
      // Garante que o estado de carregamento do botão seja desativado
      if (mounted) setState(() => _isRetrying = false);
    }
  }

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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _isRetrying ? null : _fetchProducts, // Desabilita o botão enquanto estiver tentando
                                child: _isRetrying
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Tentar Novamente'),
                              )
                            ],
                          ),
                        ),
                      )
                    : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) =>
                    _buildProductCard(_filteredProducts[index], colorScheme),
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
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 40,
                        );
                      },
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
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              product.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                            )),
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