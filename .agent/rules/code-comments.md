---
trigger: always_on
---

# Regras para Comentários de Código

## Princípio Fundamental: "O QUÊ" e "POR QUÊ", não "COMO"

O código deve explicar **o que** faz através de nomes claros. Os comentários devem explicar **por que** algo foi feito de determinada forma.

---

## ✅ O QUE COMENTAR

### 1. Intenção e Propósito (O "Por Quê")
```dart
// Usamos cache local porque a API tem rate limit de 100 req/min
final cache = LocalCache();
```

### 2. Decisões de Design
```dart
// Optamos por BLoC ao invés de Provider aqui devido à complexidade
// do estado compartilhado entre múltiplas telas
```

### 3. Lógica Complexa ou Não-Óbvia
```dart
// Algoritmo de Luhn para validação de cartão de crédito
// Referência: https://en.wikipedia.org/wiki/Luhn_algorithm
```

### 4. Workarounds e Bugs Conhecidos
```dart
// WORKAROUND: API retorna null em vez de lista vazia (bug #1234)
final items = response['items'] ?? [];
```

### 5. Regras de Negócio
```dart
// Regra: Desconto de 10% para compras acima de R$500
// conforme definido pelo time de produto em 2024-01
```

### 6. APIs Públicas (Docstrings)
```dart
/// Calcula o total do orçamento com impostos.
/// 
/// [includeShipping] - Se true, inclui frete no cálculo.
/// Retorna o valor total formatado.
double calculateTotal({bool includeShipping = false})
```

### 7. TODOs e FIXMEs
```dart
// TODO: Implementar paginação quando API suportar
// FIXME: Corrigir memory leak no dispose
```

---

## ❌ O QUE NÃO COMENTAR

### 1. O Óbvio
```dart
// ❌ RUIM - Redundante
int sum = a + b; // Soma a e b

// ✅ BOM - Código auto-explicativo
int total = precoBase + taxas;
```

### 2. Código Ruim com Comentário Explicativo
```dart
// ❌ RUIM - Comentário não conserta código ruim
// Esta função faz muitas coisas: valida, salva e notifica
void processarTudo() { ... }

// ✅ BOM - Refatora em funções menores
void validarDados() { ... }
void salvarNoBanco() { ... }
void notificarUsuario() { ... }
```

### 3. Detalhes de Implementação Triviais
```dart
// ❌ RUIM
for (int i = 0; i < items.length; i++) { // Itera sobre items
  
// ✅ BOM - Nome descritivo, sem comentário
for (final product in selectedProducts) {
```

---

## 📝 CÓDIGO AUTO-DOCUMENTADO

Prefira código que se explica sozinho:

### Nomes Descritivos
```dart
// ❌ RUIM
int d; // dias restantes

// ✅ BOM
int diasRestantes;
```

### Funções Pequenas e Focadas
```dart
// ❌ RUIM - Função faz muitas coisas
void processarOrcamento() {
  // 50 linhas de código...
}

// ✅ BOM - Funções focadas
void validarOrcamento() { ... }
void calcularTotais() { ... }
void salvarOrcamento() { ... }
```

### Extrair Condições Complexas
```dart
// ❌ RUIM
if (user.age >= 18 && user.verified && !user.blocked) {

// ✅ BOM
bool podeAcessar = user.age >= 18 && user.verified && !user.blocked;
if (podeAcessar) {
```

---

## 🤖 REGRAS PARA IA

### 1. Não Gerar Comentários Redundantes
A IA nunca deve adicionar comentários que apenas repetem o que o código faz.

### 2. Explicar Decisões Não-Óbvias
Se a IA fizer uma escolha de implementação específica, deve comentar o motivo.

### 3. Priorizar Código Limpo
Antes de adicionar um comentário, a IA deve considerar se o código pode ser refatorado para ser mais claro.

### 4. Manter Comentários Atualizados
Ao modificar código, a IA deve atualizar ou remover comentários relacionados.

### 5. Usar Docstrings para APIs
Todas as funções e classes públicas devem ter docstrings explicando:
- Propósito
- Parâmetros
- Retorno
- Exceções (se aplicável)

---

## 🎯 Checklist Rápido

Antes de adicionar um comentário, pergunte:

1. ⬜ O código pode ser mais claro com melhores nomes?
2. ⬜ O comentário explica "por quê" e não "como"?
3. ⬜ O comentário será útil daqui a 6 meses?
4. ⬜ O comentário ficará desatualizado facilmente?
5. ⬜ Existe uma regra de negócio que precisa ser documentada?
