# Dockerfile para projeto Flutter (desenvolvimento)
FROM ghcr.io/cirruslabs/flutter:latest

# Instala dependências adicionais para SDKs necessários
RUN apt-get update && \
    apt-get install -y git wget unzip xz-utils libglu1-mesa openjdk-17-jdk && \
    flutter config --enable-web

WORKDIR /app

COPY . .

RUN flutter pub get

EXPOSE 9100
EXPOSE 8181

CMD ["bash"]
