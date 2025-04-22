import 'package:flutter/foundation.dart';
import '../models/partner.dart';

class PartnerService with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Partner? _foundPartner;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Partner? get foundPartner => _foundPartner;

  // Mock database with sample partners
  final List<Partner> _partners = [
    Partner(
      cnpj: '12345678000190',
      fantasyName: 'Empresa Exemplo',
      companyName: 'Empresa Exemplo LTDA',
    ),
    Partner(
      cnpj: '98765432000121',
      fantasyName: 'Outra Empresa',
      companyName: 'Outra Empresa S.A.',
    ),
  ];

  // Validates CNPJ format
  bool isValidCNPJ(String cnpj) {
    // Remove non-numeric characters
    cnpj = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Basic validation (real implementation would include check digit validation)
    return cnpj.length == 14;
  }

  // Search partner by CNPJ
  Future<bool> searchPartnerByCNPJ(String cnpj) async {
    _isLoading = true;
    _error = null;
    _foundPartner = null;
    notifyListeners();

    try {
      // Remove non-numeric characters
      cnpj = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
      
      // Simulating network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Find partner with matching CNPJ
      _foundPartner = _partners.firstWhere(
        (partner) => partner.cnpj == cnpj,
        orElse: () => throw Exception('CNPJ não encontrado'),
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
