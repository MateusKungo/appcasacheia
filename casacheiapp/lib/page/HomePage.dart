import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:casacheiapp/page/CartPage.dart';
import 'package:casacheiapp/page/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Estado para o carrinho e para os produtos
  final List<Product> _cartItems = [];
  List<Product> _featuredProducts = [];
  bool _isLoading = true;
  String? _error;

  // Estado para o carrossel de banners
  Timer? _bannerTimer;
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  final List<String> _bannerImages = [
    'assets/images/cardimage.png',
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _fetchFeaturedProducts();
    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerTimer() {
    // Troca o banner a cada 5 segundos
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bannerController.hasClients) {
        int nextPage = _currentBannerIndex + 1;
        if (nextPage >= _bannerImages.length) {
          nextPage = 0; // Volta para o primeiro
        }
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Função para buscar produtos da API
  Future<void> _fetchFeaturedProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://casa-fscp.onrender.com/api.casacheia/products'),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        // A API retorna um objeto, e a lista de produtos está dentro de uma chave (ex: 'products')
        final List<dynamic> data = responseBody['allProducts'] ?? [];

        setState(() {
          _featuredProducts = data.map<Product>((json) {
            final category = json['category'] ?? 'Outros';
            final image = {
              'Grãos': '🍚',
              'Bebidas': '🥤',
              'Enlatados': '🥫',
              'Higiene': '🧼',
              'Laticínios': '🥛',
              'Cestas': '🛒',
            }[category] ?? '📦';

            return Product(
              id: json['_id'] ?? '',
              name: json['name'] ?? 'Produto sem nome',
              price: _parseDynamicNumber(json['price']),
              category: category,
              stock: _parseDynamicNumber(json['stock']).toInt(),
              description: json['description'] ?? '',
              image: image,
            );
          }).take(6).toList(); // Pega apenas os 6 primeiros como destaque
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Falha ao carregar produtos';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro de conexão. Verifique sua internet.';
        _isLoading = false;
      });
    }
  }

  void _addToCart(Product product) {
    setState(() {
      _cartItems.add(product);
    });
    // Adiciona um feedback visual
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${product.name} adicionado ao carrinho!'),
      duration: const Duration(seconds: 1),
    ));
  }

  // Função auxiliar para extrair números de forma segura
  double _parseDynamicNumber(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    if (value is Map && value.containsKey(r'$numberDecimal')) {
      return double.tryParse(value[r'$numberDecimal'].toString()) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              Icon(
                Icons.shopping_basket_outlined,
                color: colorScheme.primary,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                'Casa Cheia',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: Colors.grey[600]),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container com fundo gradiente para busca e promoções
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary.withOpacity(0.08),
                      colorScheme.primary.withOpacity(0.03),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
                child: Column(
                  children: [
                    // Campo de Busca
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar produtos...',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ),
                  
                    // Seção de Promoções
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: SizedBox(
                        height: 200,
                        child: Column(
                          children: [
                            Expanded(
                              child: PageView.builder(
                                controller: _bannerController,
                                itemCount: _bannerImages.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentBannerIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        image: DecorationImage(
                                          image: AssetImage(_bannerImages[index]),
                                          fit: BoxFit.cover,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorScheme.primary.withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_bannerImages.length, (index) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  height: 8,
                                  width: _currentBannerIndex == index ? 24 : 8,
                                  decoration: BoxDecoration(
                                    color: _currentBannerIndex == index
                                        ? colorScheme.primary
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
              ),

              // Seção de Categorias
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Categorias',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    CategoryItem(
                        icon: Icons.rice_bowl,
                        label: 'Grãos',
                        colorScheme: colorScheme),
                    CategoryItem(
                        icon: Icons.liquor,
                        label: 'Bebidas',
                        colorScheme: colorScheme),
                    CategoryItem(
                        icon: Icons.soup_kitchen,
                        label: 'Enlatados',
                        colorScheme: colorScheme),
                    CategoryItem(
                        icon: Icons.clean_hands,
                        label: 'Higiene',
                        colorScheme: colorScheme),
                    CategoryItem(
                        icon: Icons.kitchen,
                        label: 'Cestas',
                        colorScheme: colorScheme),
                    CategoryItem(
                        icon: Icons.local_drink,
                        label: 'Laticínios',
                        colorScheme: colorScheme),
                  ],
                ),
              ),

              // Lista de Produtos
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Produtos em Destaque',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildProductGrid(colorScheme),
              const SizedBox(height: 80),
            ],
          ),
        ),

        // Botão Flutuante do Carrinho
        floatingActionButton: Stack(
          children: [
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CartPage(cartItems: _cartItems)));
              },
              backgroundColor: colorScheme.primary,
              child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            ),
            if (_cartItems.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    _cartItems.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        // Menu Inferior
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomAppBar(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.home, 'Home', true, colorScheme),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/products'),
                  child: _buildBottomNavItem(
                      Icons.category, 'Produtos', false, colorScheme),
                ),
                const SizedBox(width: 40), // Espaço para o FAB
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CartPage(cartItems: _cartItems)));
                  },
                  child: _buildBottomNavItem(
                      Icons.shopping_cart, 'Carrinho', false, colorScheme),
                ),
                InkWell(
                  onTap: () {
                    // Pega os dados do usuário passados como argumento para a HomePage
                    final user = ModalRoute.of(context)?.settings.arguments;
                    Navigator.pushNamed(context, '/profile', arguments: user);
                  },
                  child: _buildBottomNavItem(Icons.person, 'Perfil', false, colorScheme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
      IconData icon, String label, bool isActive, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? colorScheme.primary : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? colorScheme.primary : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Widget para a grade de produtos
  Widget _buildProductGrid(ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(_error!),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _fetchFeaturedProducts,
                child: const Text('Tentar Novamente'),
              )
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _featuredProducts.length,
      itemBuilder: (context, index) {
        final product = _featuredProducts[index];
        return ProductCard(
          product: product,
          colorScheme: colorScheme,
          onAddToCart: () => _addToCart(product),
        );
      },
    );
  }
}

// Widget para Categorias
class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para Produtos
class ProductCard extends StatelessWidget {
  final Product product;
  final ColorScheme colorScheme;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.colorScheme,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem do produto
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Text(
                product.image,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),

          // Informações do produto
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Kz ${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: FilledButton.icon(
                    onPressed: onAddToCart,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(
                      Icons.add_shopping_cart,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Adicionar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}