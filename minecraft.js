const readline = require('readline');

// Константы блоков
const AIR = ' ';
const DIRT = '.';
const STONE = '#';
const BEDROCK = 'X';
const PLAYER = 'P';

class World {
    constructor(size) {
        this.size = size;
        this.blocks = new Array(size).fill(AIR);
        this.generateTerrain();
    }

    generateTerrain() {
        for (let i = 0; i < this.size; i++) {
            if (i === 0 || i === this.size - 1) this.blocks[i] = BEDROCK;
            else if (i < 4) this.blocks[i] = STONE;
            else if (i < 8) this.blocks[i] = DIRT;
            else this.blocks[i] = AIR;
        }
    }

    render(playerPos, inventory) {
        // Очистка экрана консоли
        console.clear();

        console.log("=== 1D MINECRAFT НА JAVASCRIPT (Node.js) ===");
        console.log();

        // Отрисовка мира
        let displayLine = "";
        for (let i = 0; i < this.size; i++) {
            if (i === playerPos) {
                displayLine += PLAYER;
            } else {
                displayLine += this.blocks[i];
            }
        }
        console.log(displayLine);

        // Интерфейс
        const invStr = inventory === AIR ? "Пусто" : inventory;
        console.log(`\n[Инвентарь]: ${invStr}`);
        console.log("[Управление]: A (Влево) | D (Вправо) | Q (Копать под собой) | E (Строить под собой) | X (Выход)");
        process.stdout.write("Ввод: ");
    }
}

function main() {
    const worldSize = 40;
    const world = new World(worldSize);

    let playerPos = 12;
    let inventory = AIR;

    // Настройка интерфейса чтения ввода из консоли
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });

    const gameLoop = () => {
        // Гравитация
        while (playerPos > 0 && world.blocks[playerPos - 1] === AIR) {
            playerPos--;
        }

        world.render(playerPos, inventory);
    };

    // Запускаем первый кадр
    gameLoop();

    rl.on('line', (line) => {
        const action = line.trim().toLowerCase();

        if (action === 'x') {
            console.log("Игра завершена!");
            rl.close();
            process.exit(0);
        }

        switch (action) {
            case 'a': // Влево
                if (playerPos > 0 && world.blocks[playerPos - 1] === AIR) {
                    playerPos--;
                }
                break;
            case 'd': // Вправо
                if (playerPos < worldSize - 1 && world.blocks[playerPos + 1] === AIR) {
                    playerPos++;
                }
                break;
            case 'q': // Копать под собой
                if (playerPos > 0) {
                    const target = world.blocks[playerPos - 1];
                    if (target !== AIR && target !== BEDROCK && inventory === AIR) {
                        inventory = target;
                        world.blocks[playerPos - 1] = AIR;
                    }
                }
                break;
            case 'e': // Строить под собой
                if (inventory !== AIR && playerPos > 1 && world.blocks[playerPos - 1] === AIR) {
                    world.blocks[playerPos - 1] = inventory;
                    inventory = AIR;
                    playerPos++;
                }
                break;
        }

        // Обновляем состояние после хода
        gameLoop();
    });
}

main();
