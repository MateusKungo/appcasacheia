import 'dart:convert';
import 'dart:async'; // Import para usar TimeoutException
import 'package:casacheiapp/page/CartItem.dart';
import 'package:casacheiapp/page/CartPage.dart';
import 'package:casacheiapp/page/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
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
      // Verifica se o produto já está no carrinho
      final existingCartItemIndex = CartPage.staticCartItems.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingCartItemIndex != -1) {
        // Se já existe, apenas incrementa a quantidade
        CartPage.staticCartItems[existingCartItemIndex].quantity++;
      } else {
        // Se não existe, adiciona como um novo item
        CartPage.staticCartItems.add(CartItem(product: product, quantity: 1));
      }
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar( 
      SnackBar(
        content: Text('${product.name} adicionado ao carrinho'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'Todos') {
      return _products;
    }
    return _products.where((product) => product.category == _selectedCategory).toList();
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
                icon: Icon(Icons.shopping_cart_outlined, color: colorScheme.primary),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
                },
              ),
              if (CartPage.staticCartItems.isNotEmpty)
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
                      CartPage.staticCartItems.length.toString(),
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
                              'Kz ${product.price.toStringAsFixed(2)}',
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
}