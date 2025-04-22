import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/partner_service.dart';
import '../theme/app_theme.dart';
import '../widgets/index.dart';

class CNPJSearchScreen extends StatefulWidget {
  const CNPJSearchScreen({Key? key}) : super(key: key);

  @override
  State<CNPJSearchScreen> createState() => _CNPJSearchScreenState();
}

class _CNPJSearchScreenState extends State<CNPJSearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cnpjController = TextEditingController();
  
  @override
  void dispose() {
    _cnpjController.dispose();
    super.dispose();
  }

  // Format CNPJ as user types (XX.XXX.XXX/XXXX-XX)
  String _formatCNPJ(String value) {
    // Remove all non-numeric characters
    value = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (value.length > 2) {
      value = value.substring(0, 2) + '.' + value.substring(2);
    }
    if (value.length > 6) {
      value = value.substring(0, 6) + '.' + value.substring(6);
    }
    if (value.length > 10) {
      value = value.substring(0, 10) + '/' + value.substring(10);
    }
    if (value.length > 15) {
      value = value.substring(0, 15) + '-' + value.substring(15);
    }
    
    return value;
  }

  void _searchCNPJ() async {
    if (_formKey.currentState?.validate() ?? false) {
      final partnerService = Provider.of<PartnerService>(context, listen: false);
      String cnpj = _cnpjController.text.replaceAll(RegExp(r'[^0-9]'), '');
      
      bool success = await partnerService.searchPartnerByCNPJ(cnpj);
      
      if (mounted) {
        if (success) {
          _showFoundPartnerModal(partnerService.foundPartner!);
        } else {
          _showNotFoundModal();
        }
      }
    }
  }
  
  void _showFoundPartnerModal(partner) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Empresa encontrada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CNPJ: ${partner.cnpj}'),
            const SizedBox(height: 8),
            Text('Nome Fantasia: ${partner.fantasyName}'),
            const SizedBox(height: 8),
            Text('Razão Social: ${partner.companyName}'),
          ],
        ),
        actions: [
          TextButtonLink(
            text: 'Informar outro CNPJ',
            onPressed: () {
              Navigator.of(ctx).pop();
              _cnpjController.clear();
            },
          ),
          PrimaryButton(
            text: 'Prosseguir com o cadastro',
            onPressed: () {
              Navigator.of(ctx).pop();
              // Navigate to next registration screen
              // (Implementation would be added when that screen exists)
            },
            width: 220,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ],
      ),
    );
  }
  
  void _showNotFoundModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('CNPJ não encontrado'),
        content: const Text(
          'O CNPJ informado não foi encontrado em nossa base de dados.',
        ),
        actions: [
          TextButtonLink(
            text: 'Ok',
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          PrimaryButton(
            text: 'Cadastrar-se como parceiro',
            onPressed: () {
              Navigator.of(ctx).pop();
              // Navigate to partner registration screen
              // (Implementation would be added when that screen exists)
            },
            width: 220,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final partnerService = Provider.of<PartnerService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Illustration 
                Center(
                  child: Image.asset(
                    'assets/images/search_company.png',
                    width: 180,
                    height: 180,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 180,
                        height: 180,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.business,
                          size: 80,
                          color: AppTheme.primaryColor,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                const Center(
                  child: Text(
                    'Pesquise a sua empresa',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // CNPJ Field
                CustomTextField(
                  controller: _cnpjController,
                  label: 'CNPJ:',
                  hintText: 'Informe seu CNPJ',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    // Format CNPJ as user types
                    final formatted = _formatCNPJ(value);
                    if (formatted != value) {
                      _cnpjController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite o CNPJ';
                    }
                    
                    final cnpj = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (cnpj.length != 14) {
                      return 'CNPJ inválido';
                    }
                    
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Primary Button
                PrimaryButton(
                  text: 'Próximo',
                  isLoading: partnerService.isLoading,
                  onPressed: _searchCNPJ,
                ),
                const SizedBox(height: 16),
                
                // Secondary Button
                SecondaryButton(
                  text: 'Quero me tornar um parceiro',
                  onPressed: () {
                    // Navigate to partner registration screen
                    // (Implementation would be added when that screen exists)
                  },
                ),
                
                // Error message (if any)
                if (partnerService.error != null && !partnerService.error!.contains('não encontrado'))
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      partnerService.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
