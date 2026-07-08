#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

// Определение типов блоков через перечисление
typedef enum {
    AIR,
    DIRT,
    STONE,
    BEDROCK
} BlockType;

// Структура игрового мира
typedef struct {
    BlockType *blocks;
    int size;
} World;

// Преобразование перечисления в символ для отрисовки
char blockToChar(BlockType type) {
    switch (type) {
        case AIR:     return ' ';
        case DIRT:    return '.';
        case STONE:   return '#';
        case BEDROCK: return 'X';
        default:      return ' ';
    }
}

// Преобразование типа блока в строку для интерфейса
const char* blockToString(BlockType type) {
    switch (type) {
        case DIRT:    return "Земля";
        case STONE:   return "Камень";
        default:      return "Пусто";
    }
}

// Очистка экрана консоли
void clearScreen() {
    #ifdef _WIN32
        system("cls");
    #else
        system("clear");
    #endif
}

int main() {
    const int worldSize = 40;
    
    // Выделение памяти под карту
    BlockType *map = (BlockType*)malloc(worldSize * sizeof(BlockType));
    if (map == NULL) {
        printf("Ошибка выделения памяти!\n");
        return 1;
    }

    // Генерация ландшафта
    for (int i = 0; i < worldSize; i++) {
        if (i == 0 || i == worldSize - 1) map[i] = BEDROCK;
        else if (i < 4)                  map[i] = STONE;
        else if (i < 8)                  map[i] = DIRT;
        else                             map[i] = AIR;
    }

    int playerPos = 12;
    BlockType inventory = AIR;
    int isRunning = 1;

    while (isRunning) {
        // Физика гравитации: падаем, пока под ногами воздух
        while (playerPos > 0 && map[playerPos - 1] == AIR) {
            playerPos--;
        }

        // Отрисовка кадра
        clearScreen();
        printf("=== 1D MINECRAFT НА ЧИСТОМ СИ (C) ===\n\n");

        for (int i = 0; i < worldSize; i++) {
            if (i == playerPos) {
                printf("P");
            } else {
                printf("%c", blockToChar(map[i]));
            }
        }
        printf("\n");

        // Интерфейс управления
        printf("\n[Инвентарь]: %s\n", blockToString(inventory));
        printf("[Управление]: A (Влево) | D (Вправо) | Q (Копать под собой) | E (Строить под собой) | X (Выход)\n");
        printf("Ввод: ");

        // Безопасное чтение ввода символа
        char inputBuffer[10];
        if (fgets(inputBuffer, sizeof(inputBuffer), stdin) == NULL) {
            continue;
        }
        
        char action = tolower(inputBuffer[0]);

        if (action == 'x') {
            isRunning = 0;
        }
        else if (action == 'a') { // Движение влево
            if (playerPos > 0 && map[playerPos - 1] == AIR) {
                playerPos--;
            }
        }
        else if (action == 'd') { // Движение вправо
            if (playerPos < worldSize - 1 && map[playerPos + 1] == AIR) {
                playerPos++;
            }
        }
        else if (action == 'q') { // Разрушить блок под собой
            if (playerPos > 0) {
                BlockType target = map[playerPos - 1];
                if (target != AIR && target != BEDROCK && inventory == AIR) {
                    inventory = target;
                    map[playerPos - 1] = AIR;
                }
            }
        }
        else if (action == 'e') { // Поставить блок под себя
            if (inventory != AIR && playerPos > 1 && map[playerPos - 1] == AIR) {
                map[playerPos - 1] = inventory;
                inventory = AIR;
                playerPos++; // Сдвигаем игрока вверх
            }
        }
    }

    // Освобождение динамической памяти
    free(map);
    printf("Игра завершена!\n");
    return 0;
}
