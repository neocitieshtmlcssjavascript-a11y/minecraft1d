@echo off
title Minecraft 1.1 Go compiler loader
color 0A
mode con: cols=60 lines=15

:: Проверяем, установлен ли Go на компьютере
where go >nul 2>nul
if %errorlevel% neq 0 (
    color 0C
    echo [ОШИБКА] Компилятор Go не найден в системе!
    echo Пожалуйста, установите Go с официального сайта (golang.org).
    pause
    exit
)

:: Записываем исходный код на Go во временный файл
echo package main > temp.go
echo import ( >> temp.go
echo 	"fmt" >> temp.go
echo 	"os" >> temp.go
echo 	"os/exec" >> temp.go
echo 	"runtime" >> temp.go
echo 	"strings" >> temp.go
echo ) >> temp.go
echo func main() { >> temp.go
echo 	size := 40; playerPos := 12; var inventory rune = ' ' >> temp.go
echo 	world := make([]rune, size) >> temp.go
echo 	for i := 0; i ^< size; i++ { >> temp.go
echo 		if i == 0 ^|^| i == size-1 { world[i] = 'X' } else if i ^< 4 { world[i] = '#' } else if i ^< 8 { world[i] = '.' } else { world[i] = ' ' } >> temp.go
echo 	} >> temp.go
echo 	for { >> temp.go
echo 		for playerPos ^> 0 ^&& world[playerPos-1] == ' ' { playerPos-- } >> temp.go
echo 		var cmd *exec.Cmd >> temp.go
echo 		if runtime.GOOS == "windows" { cmd = exec.Command("cmd", "/c", "cls") } else { cmd = exec.Command("clear") } >> temp.go
echo 		cmd.Stdout = os.Stdout; cmd.Run() >> temp.go
echo 		fmt.Println("=== MINECRAFT 1D RUN v1.1 (GO ENGINE) ===") >> temp.go
echo 		fmt.Println() >> temp.go
echo 		for i, block := range world { >> temp.go
echo 			if i == playerPos { fmt.Print("P") } else { fmt.Printf("%%c", block) } >> temp.go
echo 		} >> temp.go
echo 		fmt.Println() >> temp.go
echo 		invStr := "Пусто" >> temp.go
echo 		if inventory == '.' { invStr = "Земля" } else if inventory == '#' { invStr = "Камень" } >> temp.go
echo 		fmt.Printf("\n[Инвентарь]: %%s\n", invStr) >> temp.go
echo 		fmt.Println("[Управление]: A (Влево) | D (Вправо) | Q (Копать) | E (Строить) | X (Выход)") >> temp.go
echo 		fmt.Print("Действие: ") >> temp.go
echo 		var input string >> temp.go
echo 		fmt.Scanln(&input) >> temp.go
echo 		if len(input) == 0 { continue } >> temp.go
echo 		action := strings.ToLower(input) >> temp.go
echo 		if action == "x" { break } >> temp.go
echo 		left := playerPos - 1 >> temp.go
echo 		right := playerPos + 1 >> temp.go
echo 		if action == "a" ^&& playerPos ^> 0 ^&& world[left] == ' ' { playerPos-- } >> temp.go
echo 		if action == "d" ^&& playerPos ^< size-1 ^&& world[right] == ' ' { playerPos++ } >> temp.go
echo 		if action == "q" ^&& playerPos ^> 0 { >> temp.go
echo 			target := world[left] >> temp.go
echo 			if target != ' ' ^&& target != 'X' ^&& inventory == ' ' { >> temp.go
echo 				inventory = target; world[left] = ' ' >> temp.go
echo 			} >> temp.go
echo 		} >> temp.go
echo 		if action == "e" { >> temp.go
echo 			if inventory != ' ' ^&& playerPos ^> 1 ^&& world[left] == ' ' { >> temp.go
echo 				world[left] = inventory; inventory = ' '; playerPos++ >> temp.go
echo 			} >> temp.go
echo 		} >> temp.go
echo 	} >> temp.go
echo } >> temp.go

echo [УСПЕХ] Исходный код подготовлен.
echo Компиляция бинарного файла через Go...
go build -o minecraft_1_1.exe temp.go
del temp.go

if not exist "minecraft_1_1.exe" (
    color 0C
    echo [ОШИБКА] Не удалось скомпилировать игровой EXE файл.
    pause
    exit
)

echo [УСПЕХ] Игра успешно скомпилирована в чистый машинный код!
echo Запуск...
timeout /t 1 >nul
minecraft_1_1.exe

echo.
echo Спасибо за игру! Скрипт завершен.
pause
