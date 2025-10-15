# New Drive Module (Multi Drive)

Módulo responsável pela gestão e visualização de arquivos do drive compartilhado.

## 📁 Estrutura de Pastas

```
new_drive/
├── domain/                     # Camada de Domínio (Regras de Negócio)
│   ├── entities/              # Entidades puras de negócio
│   │   ├── drive_item.dart
│   │   └── drive_category.dart
│   ├── repositories/          # Contratos abstratos
│   │   └── drive_repository.dart
│   └── usecases/             # Casos de uso
│       ├── get_recent_items_usecase.dart
│       ├── get_categories_usecase.dart
│       └── search_files_usecase.dart
│
├── data/                      # Camada de Dados (Implementação)
│   ├── models/               # DTOs para conversão JSON
│   │   ├── drive_item_model.dart
│   │   └── drive_category_model.dart
│   ├── datasources/          # Contratos de fontes de dados
│   │   └── drive_remote_datasource.dart
│   └── repositories/         # Implementação dos repositórios
│       └── drive_repository_impl.dart
│
├── external/                  # Camada Externa (APIs e Serviços)
│   └── drive_remote_datasource_impl.dart
│
├── presentation/             # Camada de Apresentação (UI)
│   ├── pages/               # Telas completas
│   │   └── new_drive_page.dart
│   ├── stores/              # MobX Stores
│   │   ├── new_drive_store.dart
│   │   └── new_drive_store.g.dart (gerado)
│   └── widgets/             # Widgets específicos
│       ├── item_card_doc.dart
│       └── category_card.dart
│
├── new_drive_module.dart     # Módulo Modular (DI e Rotas)
└── new_drive_failure.dart    # Classes de erro
```

## 🎯 Arquitetura

Este módulo segue **Clean Architecture** com separação em três camadas:

### 1. Domain Layer (Núcleo de Negócio)
- **Entidades**: Modelos puros sem dependências externas
- **Repositórios**: Interfaces abstratas (contratos)
- **Use Cases**: Lógica de negócio isolada

### 2. Data Layer (Implementação de Dados)
- **Models**: DTOs para serialização JSON
- **DataSources**: Contratos de fontes de dados
- **Repositories**: Implementação dos contratos de domínio

### 3. Presentation Layer (Interface do Usuário)
- **Pages**: Telas completas
- **Stores**: Gerenciamento de estado com MobX
- **Widgets**: Componentes reutilizáveis

### 4. External Layer (Serviços Externos)
- Implementações concretas de APIs
- Integração com serviços externos

## 🔄 Fluxo de Dados

```
UI (Page) → Store → UseCase → Repository (Abstract) → Repository (Impl) → DataSource → API
                                                                                ↓
UI (Page) ← Store ← Either<Failure, Success> ← Repository ← DTO → Entity
```

## 🎨 Componentes Principais

### ItemCardDoc
Componente reutilizável para exibir arquivos/pastas do drive.

**Variantes:**
- **Icon-based**: Ícone colorido com informações
- **Image-based**: Thumbnail de imagem

**Props:**
```dart
ItemCardDoc(
  itemName: String,
  itemSize: String,
  itemDate: String,
  itemType: DriveItemType,
  thumbnailUrl: String?,
  onTap: VoidCallback?,
  onMenuTap: VoidCallback?,
  showDate: bool = true,
)
```

**Cores por Tipo:**
- Documento: `#2830F2` / `#EBEDFF`
- Vídeo: `#800019` / `#FFEBEF`
- Imagem: `#103323` / `#EFFAF5`
- Pasta: `#402F00` / `#FFD932`

### CategoryCard
Card simplificado para exibir categorias.

**Props:**
```dart
CategoryCard(
  categoryName: String,
  categoryType: DriveItemType,
  itemCount: int,
  totalSize: String,
  onTap: VoidCallback?,
)
```

## 🎨 Design System

### Cores
```dart
// Primárias
Primary: #2830F2
Background Page: #F3F4F6
Card Background: #FFFFFF

// Textos
Text Primary: #171A1F
Text Secondary: #565E6C
Separator: #DEE1E6
```

### Espaçamentos
- Padding horizontal da tela: `10.w`
- Espaçamento entre cards: `12.w`
- Espaçamento entre seções: `24.h`

### Tipografia
- Título de seção: `16.sp`, FontWeight.w600
- Nome de arquivo: `14.sp`, FontWeight.w600
- Metadata: `12.sp`, FontWeight.normal

## 🚀 Uso

### Navegação
```dart
Modular.to.pushNamed('/new_drive/');
```

### Inicialização no App Module
```dart
import 'modules/features/new_drive/new_drive_module.dart';

@override
List<ModularRoute> get routes => [
  ModuleRoute('/new_drive', module: NewDriveModule()),
  // ...
];
```

## 🔧 Desenvolvimento

### Gerar arquivos MobX
```bash
flutter pub run build_runner build --delete-conflicting-outputs
# ou para watch mode:
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Adicionar ao app_module.dart
```dart
ModuleRoute('/new_drive', module: NewDriveModule()),
```

## ✅ Checklist de Implementação

- [x] Estrutura de pastas Clean Architecture
- [x] Domain: Entities (DriveItem, DriveCategory)
- [x] Domain: Repository interface
- [x] Domain: Use Cases (GetRecent, GetCategories, Search)
- [x] Data: Models (DTOs)
- [x] Data: DataSource interface
- [x] Data: Repository implementation
- [x] External: DataSource implementation
- [x] Presentation: ItemCardDoc widget
- [x] Presentation: CategoryCard widget
- [x] Presentation: NewDriveStore (MobX)
- [x] Presentation: NewDrivePage
- [x] Module: Configuração Modular
- [x] Failure: Classes de erro

## 🔜 Próximos Passos

### Backend Integration
- [ ] Conectar com API real (substituir endpoints mockados)
- [ ] Implementar autenticação nos headers
- [ ] Adicionar tratamento de erros específicos da API

### Funcionalidades
- [ ] Implementar busca em tempo real
- [ ] Adicionar filtros de categoria
- [ ] Implementar paginação
- [ ] Adicionar pull-to-refresh
- [ ] Implementar visualização de arquivos
- [ ] Adicionar download de arquivos
- [ ] Implementar compartilhamento

### Melhorias
- [ ] Adicionar cache local (Hive)
- [ ] Implementar modo offline
- [ ] Adicionar skeletons de loading
- [ ] Implementar infinite scroll
- [ ] Adicionar animações de transição
- [ ] Implementar testes unitários
- [ ] Implementar testes de widget

## 📝 Regras de Negócio

### Formatação de Data
- "visto hoje" → arquivo visualizado hoje
- "visto ontem" → arquivo visualizado ontem
- "visto em DD/MM" → outras datas

### Categorias Fixas
- Documentos
- Imagens
- Vídeos
- Pastas

### Validações
- Query de busca não pode ser vazia
- Todos os campos obrigatórios devem ser preenchidos

## 🎯 Dependências

```yaml
dependencies:
  flutter_modular: ^5.0.3
  mobx: ^2.2.0
  flutter_mobx: ^2.0.6+5
  flutter_screenutil: ^5.7.0
  dio: ^5.0.0
  dartz: ^0.10.1
  equatable: ^2.0.5

dev_dependencies:
  build_runner: (latest)
  mobx_codegen: ^2.4.0
```

## 📚 Referências

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Modular](https://pub.dev/packages/flutter_modular)
- [MobX](https://pub.dev/packages/mobx)
- [Dartz (Functional Programming)](https://pub.dev/packages/dartz)
