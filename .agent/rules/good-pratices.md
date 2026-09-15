---
trigger: always_on
---

# Guia de Boas Práticas do Projeto

> Arquivo mantido com o nome legado `good-pratices.md` porque este nome já existe no repositório.
> Este conteúdo foi ajustado para refletir o `pubspec.yaml`, `analysis_options.yaml` e a estrutura real em `lib/app/modules/features`.

## Princípios

1. O código deve seguir o padrão real do repositório, não exemplos genéricos.
2. Toda regra arquitetural deve ser compatível com Flutter, Dart analyzer, MobX e flutter_modular.
3. Mudanças devem ser pequenas, revisáveis e focadas.
4. Não misturar refactor arquitetural com mudança funcional grande.
5. Preferir componentização por intenção visual e reutilização real.
6. Preferir Store enxuta, UseCase com regra de negócio e Repository com acesso a dados.
7. Não editar arquivos gerados manualmente.

## Stack real do projeto

Antes de sugerir mudança, considerar que o projeto usa:

- Flutter;
- Dart SDK `>=3.4.1 <4.0.0`;
- `flutter_modular`;
- `dio`;
- `dartz`;
- `equatable`;
- `flutter_screenutil`;
- `mobx`;
- `flutter_mobx`;
- `flutter_secure_storage`;
- `shared_preferences`;
- `build_runner`;
- `mobx_codegen`;
- `flutter_lints`.

## Qualidade de código

- Rodar `flutter analyze` antes de aprovar alteração.
- Rodar `flutter test` quando houver teste ou regra de negócio.
- Rodar `dart format .` antes de finalizar.
- Não usar `print` em produção.
- Usar `const` quando o analyzer/lints indicarem.
- Manter imports ordenados.
- Não deixar código morto.
- Não capturar erro genérico sem transformar em mensagem/Failure coerente.
- Não engolir exceção silenciosamente.

## UI

- Page representa tela/rota.
- Widget representa componente visual.
- Store representa estado de apresentação.
- UseCase representa ação/regra de negócio.
- Repository representa contrato de dados.
- DataSource representa acesso a API/storage/plugin.
- Não fazer chamada HTTP direta em Page/Widget.
- Não colocar regra de negócio em `build()`.

## Responsividade

O projeto usa `flutter_screenutil`. Ao criar UI nova:

- seguir padrão já existente da tela/feature;
- evitar hardcode sem motivo;
- preferir tokens/tema/componentes existentes;
- validar telas pequenas e grandes quando a mudança impactar layout.

Exemplo de uso do ScreenUtil:

```dart
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

## Design System

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

### Controle de Acesso por Papel

- **Admin**: Visualiza parceiro e vendedor
- **Gestor**: Visualiza apenas vendedor
- **Vendedor**: Não visualiza informações adicionais

### Status Tags

Sistema de tags coloridas para status:

- **Pendente**: `#0C498E` / `#E0F0FF`
- **Aprovado**: `#0E5210` / `#B6FFAD`
- **Não Aprovado**: `#571414` / `#EEB8B8`
- **Expirado**: `#573502` / `#F1DAB7`
- **Arquivado**: `#FFFFFF` / `#0E3562`

## Configuração de API

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

## Segurança

- Tokens e credenciais devem usar `flutter_secure_storage` ou abstração já existente.
- `shared_preferences` deve ficar restrito a preferências/configurações não sensíveis.
- Não logar token, senha, OTP, CPF, e-mail sensível ou payload de autenticação.
- Não commitar segredo hardcoded.

## Commits e PRs

Usar commits pequenos e claros. Exemplos aceitáveis:

```txt
feat: add drive shared files navigation
fix: avoid duplicated wiki route
refactor: extract budget card status widget
test: add auth store loading state tests
docs: update agent rules
```

## Boas Práticas Específicas

### Componentização

- Criar widgets reutilizáveis em `app/shared/widgets/`
- Cada componente deve ter um único propósito
- Documentar props e callbacks

### Gerenciamento de Estado

- Usar MobX para estado reativo
- Separar lógica de negócio dos widgets
- Implementar loading e error states

### API Integration

- Centralizar configurações no `ApiConfig`
- Usar interceptors para funcionalidades transversais
- Implementar retry logic para requests críticos

### Controle de Acesso

- Verificar `UserRole` antes de exibir informações
- Implementar guards de rota quando necessário
- Manter consistência entre diferentes níveis

### Utilitários e DRY (Don't Repeat Yourself)

- Criar classes utilitárias em `app/shared/utils/` para funcionalidades repetidas
- **Formatação de moeda**: Usar `CurrencyUtils.formatBRL()` ao invés de criar `NumberFormat.currency()` localmente

```dart
// Ruim - Código duplicado em vários arquivos
final formatter = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: 'R\$',
  decimalDigits: 2,
);
return formatter.format(value);

// Bom - Utilitário centralizado
return CurrencyUtils.formatBRL(value);
```

### Entidades com Equatable

- Usar `bool get stringify => true;` ao invés de `toString()` manual
- Equatable gera toString automaticamente baseado nos `props`

```dart
// Ruim - Manual
@override
String toString() => 'Entity(id: $id, name: $name)';

// Bom - Equatable gera automaticamente
@override
bool get stringify => true;
```

### copyWith Pattern

- **Novos arquivos:** Usar `@CopyWith()` annotation com code generation
- Evitar implementação manual para reduzir boilerplate
- Rodar `flutter pub run build_runner build` após mudanças

## Checklist de revisão

- [ ] Seguiu a arquitetura feature-first.
- [ ] Respeitou as camadas.
- [ ] Não adicionou lógica de negócio na UI.
- [ ] Não editou arquivo gerado.
- [ ] MobX usa `@observable`, `@computed` e `@action` corretamente.
- [ ] Rotas não foram duplicadas.
- [ ] Binds estão no módulo correto.
- [ ] Erros são tratados de forma explícita.
- [ ] Código está formatado.
- [ ] `flutter analyze` passa.
- [ ] Testes relevantes foram adicionados/atualizados.
