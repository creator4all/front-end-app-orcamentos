---
trigger: always_on
---

# Regras para Comentários de Código

## Princípio

Comentários devem explicar **por que** algo existe, não repetir **como** o código funciona.
O código deve explicar o "o quê" por meio de:

- nomes claros;
- funções pequenas;
- tipos explícitos;
- separação de responsabilidades.

## O que comentar

### Decisão não óbvia

```dart
// Usamos cache local aqui porque a API de pastas é chamada novamente ao voltar na navegação.
folderCache[folderId] = folderItem;
```

### Regra de negócio

```dart
// Regra: vendedor não visualiza dados do parceiro no card de orçamento.
```

### Workaround

```dart
// WORKAROUND: API retorna null em `children` para pasta vazia.
final children = response.children ?? [];
```

### Limitação externa

```dart
// A permissão de mída no Android depende da versão do SDK.
```

### API pública

Usar docstring em classes/funções públicas quando o propósito não for óbvio:

```dart
/// Carrega os arquivos próprios do usuário autenticado.
Future<void> loadOwnFiles();
```

Docstrings completas em APIs públicas devem explicar:

- Propósito
- Parâmetros
- Retorno
- Exceções (se aplicável)

```dart
/// Calcula o total do orçamento com impostos.
///
/// [includeShipping] - Se true, inclui frete no cálculo.
/// Retorna o valor total formatado.
double calculateTotal({bool includeShipping = false})
```

## O que não comentar

### Óbvio

Evitar:

```dart
// Soma a + b
final total = a + b;
```

### Código ruim

Não usar comentário para justificar função confusa. Refatorar.
Evitar:

```dart
// Esta função valida, salva, chama API e atualiza tela.
void processEverything() {}
```

Preferir separar responsabilidades.

### Comentário desatualizável

Evitar comentário que repete nome de classe, parâmetro ou rota e pode ficar desatualizado.

## TODO/FIXME

Todo `TODO` ou `FIXME` deve ter contexto.

Preferir:

```dart
// TODO(#123): remover fallback quando a API padronizar `children: []`.
```

Evitar:

```dart
// TODO: arrumar depois
```

## Regras para IA

- Não adicionar comentários redundantes.
- Antes de comentar, tentar melhorar nome/estrutura.
- Atualizar comentários quando alterar comportamento.
- Remover comentários mentirosos/desatualizados.
- Comentar decisão técnica não óbvia.
- Documentar regra de negócio que não está clara no código.
- Não inserir comentário alegando fonte inexistente.

## Checklist Rápido

Antes de adicionar um comentário, pergunte:

1. O código pode ser mais claro com melhores nomes?
2. O comentário explica "por quê" e não "como"?
3. O comentário será útil daqui a 6 meses?
4. O comentário ficar desatualizado facilmente?
5. Existe uma regra de negócio que precisa ser documentada?
