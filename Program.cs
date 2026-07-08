using System;

namespace OneDMinecraft
{
    // Определение типов блоков
    enum BlockType
    {
        Air,
        Dirt,
        Stone,
        Bedrock
    }

    class World
    {
        private BlockType[] blocks;
        public int Size { get; }

        public World(int size)
        {
            Size = size;
            blocks = new BlockType[size];
            GenerateTerrain();
        }

        private void GenerateTerrain()
        {
            for (int i = 0; i < Size; i++)
            {
                if (i == 0 || i == Size - 1) blocks[i] = BlockType::Bedrock;
                else if (i < 4)             blocks[i] = BlockType::Stone;
                else if (i < 8)             blocks[i] = BlockType::Dirt;
                else                        blocks[i] = BlockType::Air;
            }
        }

        public BlockType GetBlock(int pos)
        {
            if (pos >= 0 && pos < Size) return blocks[pos];
            return BlockType::Bedrock;
        }

        public void SetBlock(int pos, BlockType type)
        {
            if (pos > 0 && pos < Size - 1 && blocks[pos] != BlockType::Bedrock)
            {
                blocks[pos] = type;
            }
        }

        public char GetBlockChar(BlockType type)
        {
            return type switch
            {
                BlockType.Air => ' ',
                BlockType.Dirt => '.',
                BlockType.Stone => '#',
                BlockType.Bedrock => 'X',
                _ => ' '
            };
        }

        public void Render(int playerPos, BlockType inventory)
        {
            Console.Clear();
            Console.WriteLine("=== 1D MINECRAFT НА C# ===\n");

            // Отрисовка одномерного мира
            for (int i = 0; i < Size; i++)
            {
                if (i == playerPos)
                {
                    Console.Write('P');
                }
                else
                {
                    Console.Write(GetBlockChar(blocks[i]));
                }
            }
            Console.WriteLine();

            // Вывод интерфейса
            string invStr = inventory == BlockType.Air ? "Пусто" : inventory.ToString();
            Console.WriteLine($"\n[Инвентарь]: {invStr}");
            Console.WriteLine("[Управление]: A (Влево) | D (Вправо) | Q (Копать под собой) | E (Строить под собой) | X (Выход)");
            Console.Write("Ввод: ");
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            const int worldSize = 40;
            World world = new World(worldSize);

            int playerPos = 12;
            BlockType inventory = BlockType.Air;
            bool isRunning = true;

            while (isRunning)
            {
                // Физика гравитации: падаем, пока под ногами воздух
                while (playerPos > 0 && world.GetBlock(playerPos - 1) == BlockType.Air)
                {
                    playerPos--;
                }

                world.Render(playerPos, inventory);

                string input = Console.ReadLine()?.Trim().ToLower() ?? "";
                if (string.IsNullOrEmpty(input)) continue;

                char action = input[0];

                if (action == 'x')
                {
                    isRunning = false;
                }
                else if (action == 'a') // Влево
                {
                    if (playerPos > 0 && world.GetBlock(playerPos - 1) == BlockType.Air)
                    {
                        playerPos--;
                    }
                }
                else if (action == 'd') // Вправо
                {
                    if (playerPos < worldSize - 1 && world.GetBlock(playerPos + 1) == BlockType.Air)
                    {
                        playerPos++;
                    }
                }
                else if (action == 'q') // Разрушить блок под собой
                {
                    if (playerPos > 0)
                    {
                        BlockType target = world.GetBlock(playerPos - 1);
                        if (target != BlockType.Air && target != BlockType.Bedrock && inventory == BlockType.Air)
                        {
                            inventory = target;
                            world.SetBlock(playerPos - 1, BlockType.Air);
                        }
                    }
                }
                else if (action == 'e') // Поставить блок под себя
                {
                    if (inventory != BlockType.Air && playerPos > 1 && world.GetBlock(playerPos - 1) == BlockType.Air)
                    {
                        world.SetBlock(playerPos - 1, inventory);
                        inventory = BlockType.Air;
                        playerPos++; // Поднимаем игрока на новый блок
                    }
                }
            }

            Console.WriteLine("Игра завершена!");
        }
    }
}
