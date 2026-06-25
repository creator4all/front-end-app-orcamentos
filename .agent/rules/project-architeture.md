---
trigger: always_on
---

# Arquitetura do Projeto

> Arquivo mantido com o nome legado `project-architeture.md` porque este nome já existe no repositório.
> O conteúdo abaixo substitui a regra anterior e remove conflitos com padrões antigos.

## Arquitetura adotada

Este projeto deve seguir uma organização **feature-first**, com separação por camadas dentro de cada feature.

Estrutura preferencial para features novas ou refatoradas:

```txt
lib/
  app/
    modules/
      features/
        <nome_da_feature>/
          <nome_da_feature>_module.dart
          domain/
            entities/
            repositories/
            usecases/
          data/
            datasources/
            models/
            repositories/
          external/
            *_datasource_impl.dart
          presentation/
            pages/
            stores/
            widgets/
    shared/
      core/
      widgets/
      constants/
      utils/
config/
services/
stores/
theme/
widgets/
```

## Responsabilidades por camada

### Domain

Contém regra de negócio e contratos abstratos.

Permitido:

- entities;
- value objects;
- repository contracts;
- usecases;
- failures abstratos, quando já existirem no domínio.

Evitar:

- imports de Flutter;
- imports de Dio;
- imports de Modular;
- imports de Widgets;
- implementação concreta de API;
- acesso direto a storage;
- parsing JSON específico de API.

### Data

Contém implementação de contratos e modelos de dados.

Permitido:

- DTOs/models;
- conversão JSON;
- implementação de repository contracts;
- coordenação de datasources.

Evitar:

- Widgets;
- Pages;
- Stores;
- navegação;
- lógica visual.

### External

Contém implementações concretas que conversam com o mundo externo.

Permitido:

- datasource de API;
- adaptação de plugins;
- acesso a HTTP/storage quando isso já for padrão da feature.

Evitar:

- regra de negócio;
- Widgets;
- estado de UI.

### Presentation

Contém UI e estado de apresentação.

Permitido:

- pages;
- widgets;
- stores MobX;
- formatação visual;
- navegação de tela.

Evitar:

- chamada HTTP direta;
- parsing JSON direto;
- regra de negócio complexa;
- duplicação de lógica de usecase.

## Fluxo de dependência

Fluxo preferencial:

```txt
Page/Widget -> Store -> UseCase -> Repository contract -> Repository impl -> DataSource -> API/Storage
```

Regras:

- Domain não depende de Data nem Presentation.
- Data não depende de Presentation.
- Presentation pode depender de Domain.
- UseCase chama contrato de Repository, não implementação concreta.
- Repository concreto chama DataSource.
- Store coordena estado e chama UseCase; quando a feature legada ainda chama Repository/Service direto, preferir não piorar e planejar migração gradual.

## Fluxo de dados

1. **Presentation Layer**: A interação do usuário inicia na camada de apresentação (ex.: clique em um botão).
2. **Stores**: A Store chama um caso de uso da camada de domínio.
3. **Use Cases**: O caso de uso valida e chama o repositório abstrato.
4. **Repositories**: O repositório abstrato é implementado na camada de dados, que coordena os data sources.
5. **Data Sources**: Os data sources realizam chamadas de API ou acessam o armazenamento local.
6. **DTOs e Entities**: Os dados retornados são convertidos de DTOs para Entities.
7. **Resposta**: O resultado é retornado como um `Either<Failure, Success>`.
8. **Atualização de Estado**: A Store atualiza o estado observável.
9. **UI Reativa**: A interface do usuário é reconstruída automaticamente com base no novo estado.

## Tecnologias Utilizadas

- **Dartz**: Para tratamento funcional de erros com `Either<Failure, Success>`.
- **Dio**: Cliente HTTP para chamadas de API.
- **flutter_modular**: Para injeção de dependências e navegação.
- **flutter_screenutil**: Para design responsivo.
- **Equatable**: Para comparação de igualdade em entidades.
- **MobX + flutter_mobx**: Para gerenciamento de estado reativo.

## Regras para features novas

Toda feature nova deve criar, no mínimo:

```txt
lib/app/modules/features/<feature>/
  <feature>_module.dart
  domain/
  data/
  external/
  presentation/
```

A feature só deve criar subpastas que forem realmente usadas.

## Regras para código legado

O repositório ainda possui pastas globais como `services`, `stores`, `widgets`, `models`, `entities` e `screens`.

Ao mexer nelas:

- não mover tudo sem necessidade;
- não fazer refactor gigante misturado com feature;
- preferir migração incremental;
- manter compatibilidade;
- criar PR separado para migração arquitetural quando necessário.

## Comandos Importantes

- Gerar arquivos MobX:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  flutter pub run build_runner watch --delete-conflicting-outputs
  ```

## Critério de aprovação

Uma alteração deve ser bloqueada se:

- adiciona lógica de negócio em Widget/Page;
- faz API call direta em Widget/Page;
- adiciona dependência Flutter/Dio/Modular no Domain;
- edita arquivo gerado manualmente;
- duplica rota sem necessidade;
- cria pasta fora do padrão sem justificar com exemplo real do repo.
