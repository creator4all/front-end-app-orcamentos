---
trigger: always_on
---

# 📊 Front-End App Orçamentos - Guia de Desenvolvimento

Este documento apresenta as instruções, boas práticas e padrões específicos para o projeto **Front-End App Orçamentos**, uma aplicação Flutter B2B para gestão de orçamentos da Multimídia.

## 🏗️ Arquitetura do Projeto

### Clean Architecture + Modular
O projeto segue **Clean Architecture** com **flutter_modular** para organização modular:

```
lib/
├── app/
│   ├── modules/
│   │   ├── auth/                    # Módulo de autenticação
│   │   │   ├── domain/
│   │   │   ├── infra/
│   │   │   ├── external/
│   │   │   └── presentation/
│   │   │       ├── controllers/     # MobX controllers
│   │   │       └── pages/          # Telas
│   │   ├── budget/                  # Módulo de orçamentos
│   │   │   └── presentation/
│   │   │       └── pages/
│   │   └── profile/                 # Módulo de perfil
│   └── shared/
│       ├── core/                    # Configurações centrais
│       │   └── http/               # Cliente HTTP (Dio)
│       └── widgets/                # Componentes reutilizáveis
├── config/                         # Configurações da API
├── controllers/                    # Controllers globais
├── entities/                       # Entidades de negócio
├── logics/                        # Lógicas de negócio
├── models/                        # Modelos de dados
├── screens/                       # Telas principais
├── services/                      # Serviços da aplicação
├── stores/                        # Stores MobX
├── theme/                         # Tema da aplicação
└── widgets/                       # Widgets globais
```

## 🎯 Stack Tecnológica Principal

### Core Libraries
- **flutter_modular (^5.0.3)**: Injeção de dependência e roteamento
- **mobx (^2.3.3)** + **flutter_mobx (^2.2.1)**: Gerenciamento de estado reativo
- **dio (^5.4.1)**: Cliente HTTP para APIs
- **flutter_screenutil (^5.9.3)**: Design responsivo
- **flutter_svg (^2.0.10)**: Suporte a ícones SVG

### Segurança e Persistência
- **flutter_secure_storage (^9.2.2)**: Armazenamento seguro de tokens
- **shared_preferences (^2.2.2)**: Persistência de configurações

### UI/UX
- **Material Design 3**: Design system padrão
- **Responsive Design**: Adaptação para diferentes tamanhos de tela
- **SVG Assets**: Ícones e logos vetoriais

## 🔐 Módulo de Autenticação

### Estrutura do Auth Module
```
lib/app/modules/auth/
├── domain/
│   ├── entities/         # User, AuthToken
│   ├── repositories/     # AuthRepository (abstract)
│   └── usecases/        # LoginUseCase, LogoutUseCase
├── infra/
│   ├── datasources/     # AuthDataSource (abstract)
│   └── repositories/    # AuthRepositoryImpl
├── external/
│   └── datasources/     # AuthApiDataSource
└── presentation/
    ├── controllers/     # AuthController (MobX)
    └── pages/          # LoginPage
```

### Fluxo de Autenticação
1. **Login Screen**: Validação de email/senha
2. **API Authentication**: Integração com backend
3. **Token Storage**: Armazenamento seguro de tokens
4. **Session Management**: Controle de sessão ativa
5. **Auto-logout**: Logout automático por expiração

### Stores MobX
```dart
// auth_store.dart
class AuthStore = _AuthStoreBase with _$AuthStore;

abstract class _AuthStoreBase with Store {
  @observable
  bool isAuthenticated = false;

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @action
  Future<void> login(String email, String password) async {
    isLoading = true;
    error = null;
    // Lógica de login
    isLoading = false;
  }
}
```

## 📊 Módulo de Orçamentos

### Componentes Principais

#### BudgetCardWidget
Componente principal para exibição de cards de orçamento:

```dart
BudgetCardWidget(
  title: 'Projeto Centro Comercial',
  partner: 'XPTO',                    // Apenas para Admin
  seller: 'Pedro Penha',              // Admin e Gestor
  budgetCode: 'D-4202107-119',
  dueDate: DateTime(2024, 3, 15),
  totalValue: 45282630.80,
  daysRemaining: 10,
  status: BudgetStatus.pending,
  userRole: UserRole.admin,
  isArchived: false,
  onTap: () => navigateToBudgetDetails(),
)
```

#### Controle de Acesso por Papel
- **Admin**: Visualiza parceiro e vendedor
- **Gestor**: Visualiza apenas vendedor
- **Vendedor**: Não visualiza informações adicionais

#### Status Tags
Sistema de tags coloridas para status:
- **Pendente**: `#0C498E` / `#E0F0FF`
- **Aprovado**: `#0E5210` / `#B6FFAD`
- **Não Aprovado**: `#571414` / `#EEB8B8`
- **Expirado**: `#573502` / `#F1DAB7`
- **Arquivado**: `#FFFFFF` / `#0E3562`

## 🎨 Design System

### Cores Principais
```dart
// theme/app_theme.dart
class AppTheme {
  static const Color primaryColor = Color(0xFF0E3562);
  static const Color secondaryColor = Color(0xFF1C94DF);
  
  // Text Colors
  static const Color titleColor = Color(0xFF484848);
  static const Color subtitleColor = Color(0xFF828282);
  static const Color valueColor = Color(0xFF000000);
  
  // Card Colors
  static const Color cardBackground = Color(0xFFF9F9F9);
  static const Color cardBorder = Color(0xFFD9D9D9);
}
```

### Componentes Reutilizáveis
- **StatusTagWidget**: Tags de status com cores específicas
- **DaysRemainingWidget**: Indicador de dias restantes
- **BudgetCardWidget**: Card principal de orçamentos

### Responsividade
```dart
// Uso do ScreenUtil
Container(
  width: 100.w,           // 100% da largura da tela
  height: 90.h,           // 90 pixels de altura
  padding: EdgeInsets.all(16.w),
  child: Text(
    'Título',
    style: TextStyle(fontSize: 14.sp),  // Fonte responsiva
  ),
)
```

## 🌐 Configuração de API

### API Config
```dart
// config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://api.multimidia.com';
  static const String authEndpoint = '/auth/login';
  static const String budgetsEndpoint = '/budgets';
  
  static const Duration timeoutDuration = Duration(seconds: 30);
}
```

### Dio Client Setup
```dart
// app/shared/core/http/dio_client.dart
class DioClient {
  static Dio createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.timeoutDuration,
      receiveTimeout: ApiConfig.timeoutDuration,
    ));
    
    // Interceptors para autenticação, logs, etc.
    dio.interceptors.addAll([
      AuthInterceptor(),
      LogInterceptor(),
    ]);
    
    return dio;
  }
}
```

## 🧪 Testes

### Estrutura de Testes
```
test/
├── app/
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── domain/usecases/
│   │   │   ├── infra/repositories/
│   │   │   └── presentation/controllers/
│   │   └── budget/
│   └── shared/widgets/
└── widget_test.dart
```

### Exemplo de Teste de Widget
```dart
// test/app/shared/widgets/budget_card_widget_test.dart
testWidgets('BudgetCardWidget should display correct information', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BudgetCardWidget(
        title: 'Test Budget',
        budgetCode: 'D-123',
        dueDate: DateTime(2024, 12, 31),
        totalValue: 1000.0,
        daysRemaining: 5,
        status: BudgetStatus.pending,
        userRole: UserRole.admin,
      ),
    ),
  );

  expect(find.text('Test Budget'), findsOneWidget);
  expect(find.text('D-123'), findsOneWidget);
  expect(find.text('R\$1.000,00'), findsOneWidget);
});
```

## 🚀 Fluxo de Desenvolvimento

### 1. Git Flow
```bash
# Feature branches
git flow feature start nova-funcionalidade

# Commit pattern
git commit -m "feat: implement budget card component"
git commit -m "fix: correct date formatting in budget list"
git commit -m "refactor: optimize API service performance"
```

### 2. Build Commands
```bash
# MobX code generation
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch mode para desenvolvimento
flutter packages pub run build_runner watch

# Build para produção
flutter build appbundle --release
```

### 3. Code Review Checklist
- [ ] Seguiu a Clean Architecture
- [ ] Implementou testes unitários
- [ ] Documentou APIs públicas
- [ ] Verificou responsividade
- [ ] Testou em diferentes roles de usuário
- [ ] Validou tratamento de erros

## 📱 Navegação e Roteamento

### Rotas Principais
```dart
// app_module.dart
List<ModularRoute> get routes => [
  ChildRoute('/', child: (context, args) => const LoginScreen()),
  ChildRoute('/budget_list', child: (context, args) => const BudgetListPage()),
  ChildRoute('/profile', child: (context, args) => const ProfilePage()),
  ChildRoute('/cnpj-search', child: (context, args) => const CNPJSearchScreen()),
];
```

### Navegação Condicional
```dart
// Navegação baseada em autenticação
if (authStore.isAuthenticated) {
  Navigator.pushReplacementNamed(context, '/budget_list');
} else {
  Navigator.pushReplacementNamed(context, '/');
}
```

## 🔧 Configuração de Ambiente

### Dependências Principais
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_modular: ^5.0.3
  mobx: ^2.3.3
  flutter_mobx: ^2.2.1
  dio: ^5.4.1
  flutter_screenutil: ^5.9.3
  flutter_svg: ^2.0.10
  flutter_secure_storage: ^9.2.2

dev_dependencies:
  build_runner: ^2.4.9
  mobx_codegen: ^2.6.1
  flutter_test:
    sdk: flutter
```

### Assets Configuration
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
  
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
```

## 🎯 Boas Práticas Específicas

### 1. **Componentização**
- Criar widgets reutilizáveis em `app/shared/widgets/`
- Cada componente deve ter um único propósito
- Documentar props e callbacks

### 2. **Gerenciamento de Estado**
- Usar MobX para estado reativo
- Separar lógica de negócio dos widgets
- Implementar loading e error states

### 3. **API Integration**
- Centralizar configurações no `ApiConfig`
- Usar interceptors para funcionalidades transversais
- Implementar retry logic para requests críticos

### 4. **Responsividade**
- Sempre usar `ScreenUtil` para dimensões
- Testar em diferentes tamanhos de tela
- Implementar overflow protection

### 5. **Controle de Acesso**
- Verificar `UserRole` antes de exibir informações
- Implementar guards de rota quando necessário
- Manter consistência entre diferentes níveis

---
