import 'package:casacheiapp/page/CartPage.dart';
import 'package:casacheiapp/page/product.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Product> _cartItems = [];

  void _addToCart(Product product) {
    setState(() {
      _cartItems.add(product);
    });
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
                          borderRadius: BorderRadius.circular(25),
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/promotions'),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 220,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/cardimage.png'),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black38,
                                BlendMode.darken,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Promoções\nImperdíveis!',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                      shadows: [
                                        Shadow(blurRadius: 8, color: Colors.black54)
                                      ]),
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    color: Colors.white, size: 20),
                              ],
                            ),
                          ),
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
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  ProductCard(
                    product: const Product(name: 'Arroz 25kg', price: 'Kz 15000', image: '🍚'),
                    colorScheme: colorScheme,
                    onAddToCart: () => _addToCart(
                        const Product(name: 'Arroz 25kg', price: 'Kz 15000', image: '🍚')),
                  ),
                  ProductCard(
                    product: const Product(
                        name: 'Feijão 1kg', price: 'Kz 1500', image: '🫘'),
                    colorScheme: colorScheme,
                    onAddToCart: () => _addToCart(
                        const Product(name: 'Feijão 1kg', price: 'Kz 1500', image: '🫘')),
                  ),
                  ProductCard(
                    product: const Product(
                        name: 'Óleo de Soja 1L', price: 'Kz 2000', image: '🫒'),
                    colorScheme: colorScheme,
                    onAddToCart: () => _addToCart(const Product(
                        name: 'Óleo de Soja 1L', price: 'Kz 2000', image: '🫒')),
                  ),
                  ProductCard(
                    product: const Product(
                        name: 'Açúcar 1kg', price: 'Kz 1200', image: '🍚'),
                    colorScheme: colorScheme,
                    onAddToCart: () => _addToCart(
                        const Product(name: 'Açúcar 1kg', price: 'Kz 1200', image: '🍚')),
                  ),
                  ProductCard(
                    product: const Product(
                        name: 'Café Solúvel',
                        price: 'Kz 1800',
                        image: '☕'),
                    colorScheme: colorScheme,
                    onAddToCart: () => _addToCart(const Product(
                        name: 'Café Solúvel',
                        price: 'Kz 1800',
                        image: '☕')),
                  ),
                  ProductCard(
                    product: const Product(name: 'Leite 1L', price: 'Kz 1100', image: '🥛'),
                    colorScheme: colorScheme,
                    onAddToCart: () => _addToCart(
                        const Product(name: 'Leite 1L', price: 'Kz 1100', image: '🥛')),
                  ),
                ],
              ),
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
                _buildBottomNavItem(Icons.person, 'Perfil', false, colorScheme),
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
                  product.price,
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