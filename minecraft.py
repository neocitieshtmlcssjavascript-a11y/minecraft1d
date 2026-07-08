import os
import platform

# Константы для отображения блоков
AIR = ' '
DIRT = '.'
STONE = '#'
BEDROCK = 'X'
PLAYER = 'P'

class World:
    def __init__(self, size):
        self.size = size
        self.blocks = [AIR] * size
        self.generate_terrain()

    def generate_terrain(self):
        """Генерация слоев одномерного ландшафта"""
        for i in range(self.size):
            if i == 0 or i == self.size - 1:
                self.blocks[i] = BEDROCK
            elif i < 4:
                self.blocks[i] = STONE
            elif i < 8:
                self.blocks[i] = DIRT
            else:
                self.blocks[i] = AIR

    def render(self, player_pos, inventory):
        """Очистка экрана и отрисовка игрового поля"""
        # Кроссплатформенная очистка консоли
        if platform.system() == "Windows":
            os.system('cls')
        else:
            os.system('clear')

        print("=== 1D MINECRAFT НА PYTHON ===")
        print()

        # Отрисовка мира
        display_world = []
        for i in range(self.size):
            if i == player_pos:
                display_world.append(PLAYER)
            else:
                display_world.append(self.blocks[i])
        
        print("".join(display_world))

        # Вывод интерфейса
        inv_str = "Пусто" if inventory == AIR else inventory
        print(f"\n[Инвентарь]: {inv_str}")
        print("[Управление]: A (Влево) | D (Вправо) | Q (Копать под собой) | E (Строить под собой) | X (Выход)")
        
def main():
    world_size = 40
    world = World(world_size)
    
    player_pos = 12
    inventory = AIR
    running = True

    while running:
        # Физика гравитации: персонаж падает, пока внизу воздух
        while player_pos > 0 and world.blocks[player_pos - 1] == AIR:
            player_pos -= 1

        world.render(player_pos, inventory)
        
        # Получение ввода пользователя
        try:
            user_input = input("Ввод: ").strip().lower()
        except (KeyboardInterrupt, EOFError):
            break

        if not user_input:
            continue

        action = user_input[0]

        if action == 'x':
            running = False

        elif action == 'a':  # Движение влево
            if player_pos > 0 and world.blocks[player_pos - 1] == AIR:
                player_pos -= 1

        elif action == 'd':  # Движение вправо
            if player_pos < world_size - 1 and world.blocks[player_pos + 1] == AIR:
                player_pos += 1

        elif action == 'q':  # Разрушение блока под собой
            if player_pos > 0:
                target = world.blocks[player_pos - 1]
                if target != AIR and target != BEDROCK and inventory == AIR:
                    inventory = target
                    world.blocks[player_pos - 1] = AIR

        elif action == 'e':  # Строительство блока под собой
            if inventory != AIR and player_pos > 1 and world.blocks[player_pos - 1] == AIR:
                world.blocks[player_pos - 1] = inventory
                inventory = AIR
                player_pos += 1  # Смещаем игрока вверх на построенный блок

    print("Игра завершена!")

if __name__ == "__main__":
    main()
