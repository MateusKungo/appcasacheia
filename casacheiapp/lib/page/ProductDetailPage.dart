// aqui na tela de detalhe do produto
import 'dart:convert';
import 'package:casacheiapp/page/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  List<Product> _relatedProducts = [];
  bool _isLoadingRelated = true;

  @override
  void initState() {
    super.initState();
    _fetchRelatedProducts();
  }

  double _parseDynamicNumber(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    if (value is Map && value.containsKey('\$numberDecimal')) {
      return double.tryParse(value['\$numberDecimal'].toString()) ?? 0.0;
    }
    return 0.0;
  }

  Future<void> _fetchRelatedProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://casa-fscp.onrender.com/api.casacheia/products'),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> data = responseBody['formatted'] ?? [];

        final allProducts = data.map<Product>((json) {
          String imageUrl = 'https://via.placeholder.com/150';
          if (json['image'] is List && (json['image'] as List).isNotEmpty) {
            imageUrl = (json['image'] as List).first.toString();
          } else if (json['image'] is String && json['image'].isNotEmpty) {
            imageUrl = json['image'];
          }

          return Product(
            id: json['_id'] ?? '',
            name: json['name'] ?? 'Produto sem nome',
            price: _parseDynamicNumber(json['price']),
            category: json['categoryName'] ?? 'Outros', // Usando categoryName se disponível
            stock: _parseDynamicNumber(json['stock']).toInt(),
            description: json['description'] ?? '',
            image: imageUrl,
          );
        }).toList();

        setState(() {
          _relatedProducts = allProducts.where((p) => p.category == widget.product.category && p.id != widget.product.id).toList();
          _isLoadingRelated = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingRelated = false);
      debugPrint('Erro ao buscar produtos relacionados: $e');
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  // Função para enviar mensagem no WhatsApp
  void _sendWhatsAppMessage() {
    final totalPrice = widget.product.price * _quantity;
    final message = '''
Olá! Gostaria de solicitar o seguinte produto:

*${widget.product.name}*
Quantidade: $_quantity
Preço unitário: Kz ${widget.product.price.toStringAsFixed(2)}
Preço total: Kz ${totalPrice.toStringAsFixed(2)}

Poderia me ajudar com este pedido?
''';

    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/244931352439?text=$encodedMessage';
    
    _launchUrl(whatsappUrl);
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFE6F5E9), // Verde-claro de fundo
      appBar: AppBar(
        title: const Text('Detalhes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey[800],
      ),
      body: Stack(
        children: [
          // Conteúdo principal com rolagem
          SingleChildScrollView(
            child: Column(
              children: [
                // Imagem do Produto
                SizedBox(
                  height: size.height * 0.35,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Image.network(
                      widget.product.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Container com as informações
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 120), // Padding inferior para o rodapé
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome do Produto
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Avaliação e Preço
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildRatingStars(),
                          Text(
                            'Kz ${widget.product.price.toStringAsFixed(2)} / KG',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Seletor de Quantidade
                      _buildQuantitySelector(),
                      const Divider(height: 48),

                      // Descrição
                      const Text(
                        'Descrição',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.description.isNotEmpty
                            ? widget.product.description
                            : 'Produto essencial da cesta básica, ideal para o dia a dia. Qualidade garantida para suas refeições.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Produtos Relacionados
                      const Text(
                        'Produtos Relacionados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: _isLoadingRelated
                            ? const Center(child: CircularProgressIndicator())
                            : _relatedProducts.isEmpty
                                ? Center(
                                    child: Text(
                                      'Nenhum produto relacionado encontrado.',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _relatedProducts.length,
                                    itemBuilder: (context, index) {
                                      return _buildRelatedProductCard(_relatedProducts[index]);
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Rodapé fixo
          _buildFooter(size, colorScheme),
        ],
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < 4 ? Icons.star_rounded : Icons.star_half_rounded,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text(
          'Quantidade:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        // Botão de decrementar
        IconButton.filled(
          onPressed: _decrementQuantity,
          icon: const Icon(Icons.remove),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black87,
          ),
        ),
        // Texto da quantidade
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _quantity.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Botão de incrementar
        IconButton.filled(
          onPressed: _incrementQuantity,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildRelatedProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(product.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kz ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(Size size, ColorScheme colorScheme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Preço Total
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Preço Total',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  'Kz ${(widget.product.price * _quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Botão Adicionar ao WhatsApp
            SizedBox(
              width: size.width * 0.5,
              child: FilledButton.icon(
                onPressed: _sendWhatsAppMessage,
                icon: const Icon(Icons.shopping_basket_outlined),
                label: const Text('Solicitar'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366), // Cor verde do WhatsApp
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}