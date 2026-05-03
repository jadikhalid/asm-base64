# ASM64 - High-Performance Base64 CLI

![ASM](https://img.shields.io/badge/Language-x86--64_Assembly-red)
![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey)
![License](https://img.shields.io/badge/License-MIT-blue)

Un utilitaire de ligne de commande (CLI) robuste et performant pour l'encodage et le décodage Base64, écrit intégralement en **Assembleur x86-64** pour Linux.

## 🚀 Pourquoi ce projet ?

Contrairement aux utilitaires standards, **ASM64** n'utilise aucune bibliothèque externe (pas même la `libc`). Il communique directement avec le noyau via des appels système (syscalls). Le rendu est plus rapide et plus performant.

### Points forts techniques :

- **Zero-Dependency** : Dépendance directe au Kernel Linux.
- **Bitwise Mastery** : Manipulation fine des registres CPU pour les transformations de bits.
- **Memory Efficiency** : Gestion optimisée des buffers (lecture par blocs de 3 ou 4 octets).
- **Conformité** : Support complet du padding (`=`) selon la norme RFC 4648.

## 🛠 Installation et Utilisation

### 1. Sur Linux (Natif) ou WSL2 (Windows)

C'est la méthode recommandée pour profiter des performances pures de l'assembleur.

**Prérequis :** `nasm` et `ld` (disponibles via `build-essential`).

```bash
# Compiler le projet
make

# Encoder un fichier
./asm64 mon_fichier.txt

# Décoder un fichier (Option -d)
./asm64 -d fichier_encode.txt
```

## 2. Sur Windows (via Docker)

Si vous n'avez pas d'environnement Linux natif, vous pouvez exécuter l'outil via **Docker**. Cela garantit un environnement d'exécution identique quel que soit l'OS.

### Prérequis

- **Docker Desktop** installé et lancé.

### Instructions (Bash)

Ouvrez votre terminal (PowerShell, CMD ou un terminal Bash comme Git Bash) et utilisez les commandes suivantes :

```bash
# Construire l'image Docker
docker build -t asm64 .

# Utiliser l'outil pour encoder
docker run --rm -v $(pwd):/app asm64 input.txt

# Utiliser l'outil pour décoder
docker run --rm -v $(pwd):/app asm64 -d output.txt
```

## 🧪 Tests

Le projet inclut une suite de tests pour vérifier l'intégrité de l'encodage et du décodage par rapport aux outils systèmes standards.

### Exécution des tests (Bash)

Pour lancer la suite de tests automatisés, exécutez la commande suivante dans votre terminal :

```bash
make test
```

## 🏗 Architecture du Projet

- **`asm64.asm`** : Code source principal (logique d'encodage/décodage et syscalls).
- **`Makefile`** : Automatisation de la compilation et des tests.
- **`Dockerfile`** : Environnement de conteneurisation pour la portabilité Windows/macOS.
- **`.github/workflows/ci.yml`** : Intégration continue (CI) pour valider chaque commit.

---

## 👨‍💻 Auteur

**Khalid Jadi** - Ingénieur Logiciel Full Stack & Systèmes.

Ce projet fait partie de mon portfolio technique visant à explorer les limites de l'optimisation logicielle et de l'interaction système.
