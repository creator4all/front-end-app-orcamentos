import "package:flutter/material.dart";
import "package:flutter_mobx/flutter_mobx.dart";
import "package:multimidiaapp/widgets/CustomAppBar.dart";
import "package:multimidiaapp/screens/profile/profile_screen.dart";

import "../stores/store_provider.dart";
import "../theme/app_theme.dart";
import "../widgets/index.dart";

class BudgetListScreen extends StatefulWidget {
  const BudgetListScreen({super.key});

  @override
  State<BudgetListScreen> createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends State<BudgetListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filterOptions = [
    "Aprovados",
    "Não aprovados",
    "Expirados",
    "Pendentes",
    "Arquivados",
  ];
  String _selectedFilter = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budgetStore = StoreProvider.of(context).budgetStore;
      budgetStore.fetchBudgets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetStore = StoreProvider.of(context).budgetStore;
    final authStore = StoreProvider.of(context).authStore;

    return Scaffold(
      appBar: CustomAppBar(
        isBackButtonVisible: false,
        title: "Orçamentos",
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            child: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Filtros and Resetar row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Filtros",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextButtonLink(
                      text: "Resetar",
                      onPressed: () {
                        setState(() {
                          _selectedFilter = "";
                          _searchController.clear();
                        });
                        budgetStore.setSelectedFilter("todos");
                        budgetStore.setSearchQuery("");
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Busca por código ou cidade",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    budgetStore.setSearchQuery(value);
                  },
                ),
                const SizedBox(height: 16),

                // Filter buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: BudgetFilter(
                          label: filter,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedFilter = isSelected ? "" : filter;
                            });
                            final storeFilter =
                                isSelected ? "todos" : filter.toLowerCase();
                            budgetStore.setSelectedFilter(storeFilter);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Realizados section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Realizados",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to create budget screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  child: const Text("Novo"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Budget list
          Expanded(
            child: Observer(
              builder: (_) {
                if (budgetStore.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (budgetStore.error != null) {
                  return Center(
                    child: Text(
                      "Erro ao carregar orçamentos: ${budgetStore.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final budgets = budgetStore.filteredBudgets;

                if (budgets.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Nenhum orçamento encontrado",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: budgets.length,
                  itemBuilder: (context, index) {
                    final budget = budgets[index];
                    return BudgetCard(
                      city: budget["city"],
                      state: budget["state"],
                      code: budget["code"],
                      date: budget["date"],
                      daysRemaining: budget["daysRemaining"],
                      value: budget["value"],
                      status: budget["status"],
                      onTap: () {
                        // Navigate to budget details
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
