import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/index.dart';

class PartnerRegistrationScreen extends StatefulWidget {
  const PartnerRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<PartnerRegistrationScreen> createState() => _PartnerRegistrationScreenState();
}

class _PartnerRegistrationScreenState extends State<PartnerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _cnpjController = TextEditingController();
  String _publicSectorExperience = 'Não, nunca atuei';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }

  // Format phone number as user types ((XX) XXXXX-XXXX)
  String _formatPhone(String value) {
    // Remove all non-numeric characters
    value = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (value.length > 0) {
      value = '(' + value;
    }
    if (value.length > 3) {
      value = value.substring(0, 3) + ') ' + value.substring(3);
    }
    if (value.length > 10) {
      value = value.substring(0, 10) + '-' + value.substring(10);
    }
    
    return value;
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

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Here you would typically send the data to your backend
      // For now, just show a success dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Solicitação enviada'),
          content: const Text(
            'Sua solicitação para se tornar parceiro foi enviada com sucesso. Entraremos em contato em breve.',
          ),
          actions: [
            TextButtonLink(
              text: 'Ok',
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(); // Return to previous screen
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seja parceiro'),
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
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.business,
                          size: 40,
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
                    'Seja nosso parceiro!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Step 1 - Watch Video
                const Text(
                  '1- Assista ao vídeo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Video Placeholder
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Step 2 - Fill Form
                const Text(
                  '2- Caso você tenha interesse em ser parceiro, preencha os dados abaixo. Entraremos em contato.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Name Field
                CustomTextField(
                  controller: _nameController,
                  label: 'Nome:',
                  hintText: 'Informe seu nome',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite seu nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Email Field
                CustomTextField(
                  controller: _emailController,
                  label: 'E-mail:',
                  hintText: 'Informe seu e-mail',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite seu e-mail';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Por favor, digite um e-mail válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Phone Field
                CustomTextField(
                  controller: _phoneController,
                  label: 'Telefone:',
                  hintText: 'Informe seu telefone',
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    // Format phone as user types
                    final formatted = _formatPhone(value);
                    if (formatted != value) {
                      _phoneController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite seu telefone';
                    }
                    final phone = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (phone.length < 10 || phone.length > 11) {
                      return 'Telefone inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Company Field
                CustomTextField(
                  controller: _companyController,
                  label: 'Empresa:',
                  hintText: 'Informe sua empresa',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite o nome da empresa';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // CNPJ Field
                CustomTextField(
                  controller: _cnpjController,
                  label: 'Cnpj:',
                  hintText: 'Informe seu Cnpj',
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
                
                // Public Sector Experience
                const Text(
                  'Você atua ou já atuou com vendas na área pública?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Radio Options
                RadioListTile<String>(
                  title: const Text('Não, nunca atuei'),
                  value: 'Não, nunca atuei',
                  groupValue: _publicSectorExperience,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _publicSectorExperience = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Sim, atuei no passado'),
                  value: 'Sim, atuei no passado',
                  groupValue: _publicSectorExperience,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _publicSectorExperience = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Sim, estou atuando'),
                  value: 'Sim, estou atuando',
                  groupValue: _publicSectorExperience,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _publicSectorExperience = value!;
                    });
                  },
                ),
                const SizedBox(height: 32),
                
                // Submit Button
                PrimaryButton(
                  text: 'Quero ser parceiro',
                  onPressed: _submitForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
