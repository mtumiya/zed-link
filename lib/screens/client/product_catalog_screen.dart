import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import 'product_detail_screen.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(context),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<ProductProvider>(context, listen: false)
                              .searchProducts('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                Provider.of<ProductProvider>(context, listen: false)
                    .searchProducts(value);
              },
            ),
          ),
          
          // Category filter chips
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              return SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: ProductCategory.values.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('All'),
                          selected: productProvider.selectedCategory == null,
                          onSelected: (selected) {
                            productProvider.filterByCategory(null);
                          },
                        ),
                      );
                    }
                    
                    final category = ProductCategory.values[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_getCategoryName(category)),
                        selected: productProvider.selectedCategory == category,
                        onSelected: (selected) {
                          productProvider.filterByCategory(selected ? category : null);
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
          
          // Product grid
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final products = productProvider.products;
                
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            productProvider.clearFilters();
                            _searchController.clear();
                          },
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () => productProvider.refreshProducts(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(context, products[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image placeholder
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder(product);
                          },
                        ),
                      )
                    : _buildImagePlaceholder(product),
              ),
            ),
            
            // Product info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.supplierName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.formattedPrice,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          '/${product.unit}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(Product product) {
    IconData icon;
    Color color;
    
    switch (product.category) {
      case ProductCategory.agriculture:
        icon = Icons.agriculture;
        color = Colors.green;
        break;
      case ProductCategory.food:
        icon = Icons.restaurant;
        color = Colors.orange;
        break;
      case ProductCategory.clothing:
        icon = Icons.checkroom;
        color = Colors.purple;
        break;
      case ProductCategory.electronics:
        icon = Icons.devices;
        color = Colors.blue;
        break;
      default:
        icon = Icons.shopping_bag;
        color = Colors.grey;
    }
    
    return Center(
      child: Icon(
        icon,
        size: 32,
        color: color,
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Products'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Categories'),
                leading: Radio<ProductCategory?>(
                  value: null,
                  groupValue: Provider.of<ProductProvider>(context, listen: false).selectedCategory,
                  onChanged: (value) {
                    Provider.of<ProductProvider>(context, listen: false).filterByCategory(value);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ...ProductCategory.values.map((category) => ListTile(
                title: Text(_getCategoryName(category)),
                leading: Radio<ProductCategory?>(
                  value: category,
                  groupValue: Provider.of<ProductProvider>(context, listen: false).selectedCategory,
                  onChanged: (value) {
                    Provider.of<ProductProvider>(context, listen: false).filterByCategory(value);
                    Navigator.of(context).pop();
                  },
                ),
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  String _getCategoryName(ProductCategory category) {
    switch (category) {
      case ProductCategory.agriculture:
        return 'Agriculture';
      case ProductCategory.food:
        return 'Food';
      case ProductCategory.clothing:
        return 'Clothing';
      case ProductCategory.electronics:
        return 'Electronics';
      case ProductCategory.home:
        return 'Home';
      case ProductCategory.health:
        return 'Health';
      case ProductCategory.automotive:
        return 'Automotive';
      case ProductCategory.services:
        return 'Services';
      case ProductCategory.other:
        return 'Other';
    }
  }
}