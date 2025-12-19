---
trigger: always_on
---

# Regras para Uso da Arquitetura Proposta

## Estrutura de Pastas

A estrutura de pastas deve seguir o padrão abaixo, com separação clara entre camadas de domínio, dados e apresentação:

```
lib/
  app/
    modules/
      features/
        <nome_da_feature>/
          domain/              # Regras de negócio abstratas
            entities/          # Modelos puros de negócio
            repositories/      # Interfaces abstratas (seu "logic")
            usecases/          # Casos de uso / Lógica de negócio
          data/               # Implementação concreta
            datasources/      # Chamadas de API e storage local
            models/           # DTOs para parsing JSON
            repositories/     # Implementação dos contratos
          presentation/       # Interface do usuário
            pages/           # Telas completas
            stores/          # MobX Stores (gerenciamento de estado)
            widgets/         # Widgets específicos da feature
    shared/
      widgets/               # Widgets compartilhados (ex: custom_top_bar)
      constants/
      utils/
    core/
      di/                    # Injeção de dependências
      errors/                # Exceptions e Failures
```

## Camadas e Responsabilidades

### Domain Layer (Camada de Domínio)
- **entities/**: Modelos puros de negócio.
- **repositories/**: Contratos abstratos que definem o que pode ser feito.
- **usecases/**: Classes que encapsulam uma única ação de negócio.

### Data Layer (Camada de Dados)
- **models/**: DTOs para conversão de JSON e entidades.
- **datasources/**: Implementação de chamadas de API e storage local.
- **repositories/**: Implementação concreta dos contratos definidos na camada de domínio.

### Presentation Layer (Camada de Apresentação)
- **stores/**: MobX Stores para gerenciamento de estado.
- **pages/**: Telas completas da aplicação.
- **widgets/**: Componentes de UI específicos da feature.

## Fluxo de Dados

1. **Presentation Layer**: A interação do usuário inicia na camada de apresentação (ex.: clique em um botão).
2. **Stores**: A Store chama um caso de uso da camada de domínio.
3. **Use Cases**: O caso de uso valida e chama o repositório abstrato.
4. **Repositories**: O repositório abstrato é implementado na camada de dados, que coordena os data sources.
5. **Data Sources**: Os data sources realizam chamadas de API ou acessam o armazenamento local.
6. **DTOs e Entities**: Os dados retornados são convertidos de DTOs para Entities.
7. **Resposta**: O resultado é retornado como um `Either<Failure, Success>`.
8. **Atualização de Estado**: A Store atualiza o estado observável.
9. **UI Reativa**: A interface do usuário é reconstruída automaticamente com base no novo estado.

## Regras de Dependência

- **Presentation → Domain ← Data**
- A camada de domínio nunca depende das camadas de dados ou apresentação.
- A camada de dados nunca depende da camada de apresentação.
- Use Cases chamam apenas repositórios abstratos.
- Stores chamam apenas Use Cases.
- Repositórios concretos chamam apenas Data Sources.

## Tecnologias Utilizadas

- **Dartz**: Para tratamento funcional de erros com `Either<Failure, Success>`.
- **Dio**: Cliente HTTP para chamadas de API.
- **flutter_modular**: Para injeção de dependências e navegação.
- **flutter_screenutil**: Para design responsivo.
- **Equatable**: Para comparação de igualdade em entidades.
- **MobX + flutter_mobx**: Para gerenciamento de estado reativo.

## Comandos Importantes

- Gerar arquivos MobX:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  flutter pub run build_runner watch --delete-conflicting-outputs
  ```

## Benefícios da Arquitetura

- Separação clara de responsabilidades.
- Testabilidade isolada de cada camada.
- Manutenibilidade e escalabilidade.
- Reutilização de código com Use Cases.
- Tratamento explícito de erros com `Either`.
- Código limpo e organizado.

