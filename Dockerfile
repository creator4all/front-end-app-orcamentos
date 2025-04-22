# Dockerfile para projeto Flutter (desenvolvimento)
FROM cirrusci/flutter:latest

# Instala dependências adicionais para devtools e SDKs necessários
RUN apt-get update && \
    apt-get install -y git wget unzip xz-utils libglu1-mesa openjdk-17-jdk && \
    flutter upgrade && \
    flutter config --enable-web && \
    flutter pub global activate devtools

# Define diretório de trabalho
WORKDIR /app

# Copia arquivos do projeto
COPY . .

# Instala dependências do projeto
RUN flutter pub get

# Porta padrão para devtools
EXPOSE 9100
# Porta padrão para web (caso use flutter run -d web-server)
EXPOSE 8080

# Comando padrão (pode ser sobrescrito no docker-compose)
CMD ["bash"]
