import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/core/errors/api_error_message.dart';
import 'package:multimidiaapp/app/shared/core/errors/http_exceptions.dart';

void main() {
  const fallback = 'Não foi possível salvar os dados. Tente novamente.';

  group('ApiErrorMessage', () {
    test('should surface the per-field errors of a 422', () {
      const error = UnprocessableEntityException(
        message: 'Dados inválidos',
        validationErrors: {
          'status': 'erro',
          'mensagem': 'Dados inválidos',
          'erros': {
            'par_url': {
              'URL': 'URL deve ser uma URL válida, incluindo http:// ou https://'
            },
          },
        },
      );

      expect(
        ApiErrorMessage.from(error, fallback: fallback),
        'URL deve ser uma URL válida, incluindo http:// ou https://',
      );
    });

    test('should join multiple field errors', () {
      const error = UnprocessableEntityException(
        validationErrors: {
          'erros': {
            'par_phone': {'Telefone': 'Telefone deve ter entre 10 e 11 caracteres'},
            'par_cnpj': {'CPF/CNPJ': 'CPF/CNPJ deve ser um CNPJ válido'},
          },
        },
      );

      expect(
        ApiErrorMessage.from(error, fallback: fallback),
        'Telefone deve ter entre 10 e 11 caracteres\n'
        'CPF/CNPJ deve ser um CNPJ válido',
      );
    });

    test('should use the API message when there are no field errors', () {
      const error = HttpException(
        message: 'Email ja cadastrado',
        statusCode: 409,
      );

      expect(
        ApiErrorMessage.from(error, fallback: fallback),
        'Email ja cadastrado',
      );
    });

    test('should hide server details behind a generic message', () {
      const error = InternalServerException(
        message: 'SQLSTATE[22003]: Numeric value out of range',
      );

      expect(
        ApiErrorMessage.from(error, fallback: fallback),
        ApiErrorMessage.serverFailure,
      );
    });

    test('should hide database details sent with a 4xx status', () {
      const error = BadRequestException(
        message: "SQLSTATE[22001]: Data too long for column 'orc_nome'",
      );

      expect(
        ApiErrorMessage.from(error, fallback: fallback),
        ApiErrorMessage.serverFailure,
      );
    });

    test('should fall back for errors that are not from the API', () {
      expect(
        ApiErrorMessage.from(Exception('boom'), fallback: fallback),
        fallback,
      );
    });
  });
}
