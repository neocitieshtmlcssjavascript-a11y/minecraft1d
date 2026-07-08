package main

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strings"
)

// Константы типов блоков
const (
	AIR     = ' '
	DIRT    = '.'
	STONE   = '#'
	BEDROCK = 'X'
	PLAYER  = 'P'
)

// Структура мира игры
type World struct {
	Blocks []rune
	Size   int
}

// Создание и генерация ландшафта
func NewWorld(size int) *World {
	w := &World{
		Blocks: make([]rune, size),
		Size:   size,
	}
	w.generateTerrain()
	return w
}

func (w *World) generateTerrain() {
	for i := 0; i < w.Size; i++ {
		if i == 0 || i == w.Size-1 {
			w.Blocks[i] = BEDROCK
		} else if i < 4 {
			w.Blocks[i] = STONE
		} else if i < 8 {
			w.Blocks[i] = DIRT
		} else {
			w.Blocks[i] = AIR
		}
	}
}

// Очистка экрана консоли (кроссплатформенная)
func clearScreen() {
	var cmd *exec.Cmd
	if runtime.GOOS == "windows" {
		cmd = exec.Command("cmd", "/c", "cls")
	} else {
		cmd = exec.Command("clear")
	}
	cmd.Stdout = os.Stdout
	cmd.Run()
}

// Отрисовка кадра
func (w *World) Render(playerPos int, inventory rune) {
	clearScreen()
	fmt.Println("=== 1D MINECRAFT НА GO ===")
	fmt.Println()

	// Вывод игрового поля
	for i := 0; i < w.Size; i++ {
		if i == playerPos {
			fmt.Printf("%c", PLAYER)
		} else {
			fmt.Printf("%c", w.Blocks[i])
		}
	}
	fmt.Println()

	// Состояние инвентаря
	invStr := "Пусто"
	if inventory != AIR {
		invStr = string(inventory)
	}
	fmt.Printf("\n[Инвентарь]: %s\n", invStr)
	fmt.Println("[Управление]: A (Влево) | D (Вправо) | Q (Копать под собой) | E (Строить под собой) | X (Выход)")
	fmt.Print("Ввод: ")
}

func main() {
	worldSize := 40
	world := NewWorld(worldSize)

	playerPos := 12
	var inventory rune = AIR
	running := true

	for running {
		// Физика гравитации: падаем, пока под ногами воздух
		for playerPos > 0 && world.Blocks[playerPos-1] == AIR {
			playerPos--
		}

		world.Render(playerPos, inventory)

		var input string
		fmt.Scanln(&input)
		if len(input) == 0 {
			continue
		}

		action := strings.ToLower(input)[0]

		switch action {
		case 'x':
			running = false

		case 'a': // Движение влево
			if playerPos > 0 && world.Blocks[playerPos-1] == AIR {
				playerPos--
			}

		case 'd': // Движение вправо
			if playerPos < worldSize-1 && world.Blocks[playerPos+1] == AIR {
				playerPos++
			}

		case 'q': // Разрушение блока под собой
			if playerPos > 0 {
				target := world.Blocks[playerPos-1]
				if target != AIR && target != BEDROCK && inventory == AIR {
					inventory = target
					world.Blocks[playerPos-1] = AIR
				}
			}

		case 'e': // Строительство под себя
			if inventory != AIR && playerPos > 1 && world.Blocks[playerPos-1] == AIR {
				world.Blocks[playerPos-1] = inventory
				inventory = AIR
				playerPos++ // Поднимаем игрока на новый блок
			}
		}
	}

	fmt.Println("Игра завершена!")
}
