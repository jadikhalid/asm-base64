# Utiliser une image légère avec NASM et GCC
FROM ubuntu:latest

RUN apt-get update && apt-get install -y nasm build-essential

WORKDIR /app
COPY . .

RUN make

# Commande par défaut
ENTRYPOINT ["./asm64"]