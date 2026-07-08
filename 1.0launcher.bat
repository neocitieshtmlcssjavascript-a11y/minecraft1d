<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Minecraft 1D Run 1.0</title>
    <style>
        body { background: #111; color: #fff; font-family: sans-serif; text-align: center; padding: 20px; }
        #world { display: flex; justify-content: center; background: #222; border: 4px solid #444; padding: 10px; margin: 20px auto; width: fit-content; }
        .block { width: 25px; height: 25px; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 14px; border: 1px solid #333; }
        .air { background: #87CEEB; } /* Голубое небо */
        .dirt { background: #8B4513; color: #fff; } /* Земля */
        .stone { background: #808080; color: #fff; } /* Камень */
        .bedrock { background: #000; color: #f00; } /* Бедрок */
        .player { background: #ff4757; color: #fff; border-radius: 50%; box-shadow: 0 0 10px #ff4757; }
        .info { margin-top: 15px; font-size: 18px; }
    </style>
</head>
<body>
    <h1>⛏️ Minecraft 1D Run v1.0 🏃</h1>
    <div id="world"></div>
    <div class="info">
        <p>[Инвентарь]: <span id="inv">Пусто</span></p>
        <p><strong>Управление:</strong> A — Влево | D — Вправо | Q — Копать под собой | E — Строить под собой</p>
    </div>

    <script>
        const size = 30;
        let playerPos = 12;
        let inventory = ' ';
        
        // Генерация ландшафта
        let map = new Array(size).fill(' ');
        for(let i=0; i<size; i++) {
            if (i === 0 || i === size - 1) map[i] = 'X'; // Бедрок
            else if (i < 4) map[i] = '#'; // Камень
            else if (i < 8) map[i] = '.'; // Земля
        }

        function render() {
            // Применение гравитации перед отрисовкой
            while (playerPos > 0 && map[playerPos - 1] === ' ') {
                playerPos--;
            }

            const worldDiv = document.getElementById('world');
            worldDiv.innerHTML = '';
            
            for(let i=0; i<size; i++) {
                const block = document.createElement('div');
                block.classList.add('block');
                
                if (i === playerPos) {
                    block.classList.add('player');
                    block.innerText = 'P';
                } else {
                    if (map[i] === ' ') block.classList.add('air');
                    else if (map[i] === '.') block.classList.add('dirt');
                    else if (map[i] === '#') block.classList.add('stone');
                    else if (map[i] === 'X') block.classList.add('bedrock');
                    block.innerText = map[i];
                }
                worldDiv.appendChild(block);
            }

            // Обновление интерфейса инвентаря
            const invNames = {' ': 'Пусто', '.': 'Земля', '#': 'Камень'};
            document.getElementById('inv').innerText = invNames[inventory];
        }

        // Обработка клавиатуры
        window.addEventListener('keydown', (e) => {
            const key = e.key.toLowerCase();
            if (key === 'a' && playerPos > 0 && map[playerPos - 1] === ' ') playerPos--;
            if (key === 'd' && playerPos < size - 1 && map[playerPos + 1] === ' ') playerPos++;
            if (key === 'q' && playerPos > 0 && map[playerPos - 1] !== ' ' && map[playerPos - 1] !== 'X' && inventory === ' ') {
                inventory = map[playerPos - 1];
                map[playerPos - 1] = ' ';
            }
            if (key === 'e' && inventory !== ' ' && playerPos > 1 && map[playerPos - 1] === ' ') {
                map[playerPos - 1] = inventory;
                inventory = ' ';
                playerPos++;
            }
            render();
        });

        render();
    </script>
</body>
</html>
