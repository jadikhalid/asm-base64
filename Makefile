# Variables
ASM = nasm
ASM_FLAGS = -f elf64
LD = ld
TARGET = asm64
SRC = asm64.asm
OBJ = asm64.o

# Règle par défaut
all: $(TARGET)

# Compilation et Edition de liens
$(TARGET): $(OBJ)
	$(LD) $(OBJ) -o $(TARGET)

$(OBJ): $(SRC)
	$(ASM) $(ASM_FLAGS) $(SRC) -o $(OBJ)

# Nettoyage
clean:
	rm -f $(OBJ) $(TARGET)

# Test rapide
test: $(TARGET)
	@echo "Test Encodage..."
	@echo -n "Khalid" > input.tmp
	@./$(TARGET) input.tmp > output.tmp
	@echo "Résultat: $$(cat output.tmp)"
	@echo "Test Décodage..."
	@./$(TARGET) -d output.tmp > final.tmp
	@echo "Retour à l'original: $$(cat final.tmp)"
	@rm input.tmp output.tmp final.tmp