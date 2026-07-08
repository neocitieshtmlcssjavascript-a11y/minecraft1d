@echo off
setlocal enabledelayedexpansion
title 1D Minecraft Sword 1.0
color 0A
mode con: cols=65 lines=15

:: --- ИНИЦИАЛИЗАЦИЯ ИГРЫ ---
set "WORLD_SIZE=40"
set "PLAYER_POS=12"
set "INVENTORY= "
set "HAS_SWORD=0"

:: Спавн Зомби (Z) на 25-м блоке ландшафта
set "ZOMBIE_POS=25"
set "ZOMBIE_HP=3"
set "ZOMBIE_ALIVE=1"

:: Генерация слоев одномерного мира
:: 0..3 - Камень (#), 4..7 - Земля (.), остальные - Воздух ( )
for /l %%i in (0,1,%WORLD_SIZE%) do (
    if %%i equ 0 ( set "WORLD_%%i=X" ) else (
    if %%i equ %WORLD_SIZE% ( set "WORLD_%%i=X" ) else (
    if %%i lss 4 ( set "WORLD_%%i=#" ) else (
    if %%i lss 8 ( set "WORLD_%%i=." ) else (
    set "WORLD_%%i= "
    ))))
)

:: --- ОСНОВНОЙ ИГРОВОЙ ЦИКЛ ---
:GAME_LOOP
:: 1. Физика гравитации (игрок падает, если под ногами воздух)
:GRAVITY_LOOP
set /a "UNDER_PLAYER=PLAYER_POS - 1"
if "!WORLD_%UNDER_PLAYER%!" equ " " (
    set /a "PLAYER_POS-=1"
    goto GRAVITY_LOOP
)

:: 2. Физика зомби (падает, если под ним воздух)
:ZOMBIE_GRAVITY
if %ZOMBIE_ALIVE% equ 1 (
    set /a "UNDER_ZOMBIE=ZOMBIE_POS - 1"
    if "!WORLD_%UNDER_ZOMBIE%!" equ " " (
        set /a "ZOMBIE_POS-=1"
        goto ZOMBIE_GRAVITY
    )
)

:: 3. Отрисовка кадра
cls
echo =============================================================
echo               1D MINECRAFT SWORD v1.0 (PURE BATCH)          
echo =============================================================
echo.

:: Сборка строки мира для вывода
set "RENDER_LINE="
for /l %%i in (0,1,%WORLD_SIZE%) do (
    set "CHAR=!WORLD_%%i!"
    if %%i equ %PLAYER_POS% (
        set "CHAR=P"
    ) else (
        if %ZOMBIE_ALIVE% equ 1 (
            if %%i equ %ZOMBIE_POS% set "CHAR=Z"
        )
    )
    set "RENDER_LINE=!RENDER_LINE!!CHAR!"
)
echo %RENDER_LINE%
echo.

:: Вывод интерфейса
if %HAS_SWORD% equ 1 ( set "SWORD_STATUS=Железный Меч" ) else ( set "SWORD_STATUS=Нет" )
if "%INVENTORY%" equ " " ( set "INV_STATUS=Пусто" ) else ( set "INV_STATUS=%INVENTORY%" )

echo [Инвентарь]: %INV_STATUS%    [Оружие]: %SWORD_STATUS%
if %ZOMBIE_ALIVE% equ 1 ( echo [Враг]: Зомби (HP: %ZOMBIE_HP%^) на позиции %ZOMBIE_POS% ) else ( echo [Враг]: Зомби повержен! )
echo -------------------------------------------------------------
echo [Управление]: A (Влево) ^| D (Вправо) ^| Q (Копать) ^| E (Строить)
echo               F (Ударить мечом) ^| R (Скрафтить меч) ^| X (Выход)
echo -------------------------------------------------------------

:: 4. Обработка ввода игрока
set "INPUT="
set /p "INPUT=Действие: "
if /i "%INPUT%" equ "x" goto END_GAME

:: Поведение Зомби (шаг навстречу игроку после каждого действия)
if %ZOMBIE_ALIVE% equ 1 (
    set /a "Z_NEXT_RIGHT=ZOMBIE_POS + 1"
    set /a "Z_NEXT_LEFT=ZOMBIE_POS - 1"
    if %ZOMBIE_POS% gtr %PLAYER_POS% (
        if "!WORLD_%Z_NEXT_LEFT%!" equ " " set /a "ZOMBIE_POS-=1"
    ) else (
        if %ZOMBIE_POS% lss %PLAYER_POS% (
            if "!WORLD_%Z_NEXT_RIGHT%!" equ " " set /a "ZOMBIE_POS+=1"
        )
    )
)

:: Проверка гибели от Зомби (если зашел на клетку игрока)
if %ZOMBIE_ALIVE% equ 1 (
    if %PLAYER_POS% equ %ZOMBIE_POS% (
        cls
        echo =============================================================
        echo                       ИГРА ОКОНЧЕНА                          
        echo =============================================================
        echo.
        echo           Вас съел Зомби! Вы возродились в меню.
        echo.
        pause
        goto END_GAME
    )
)

:: Движение
set /a "NEXT_LEFT=PLAYER_POS - 1"
set /a "NEXT_RIGHT=PLAYER_POS + 1"
if /i "%INPUT%" equ "a" if "!WORLD_%NEXT_LEFT%!" equ " " set /a "PLAYER_POS-=1"
if /i "%INPUT%" equ "d" if "!WORLD_%NEXT_RIGHT%!" equ " " set /a "PLAYER_POS+=1"

:: Копать блок под собой
if /i "%INPUT%" equ "q" (
    if "!WORLD_%NEXT_LEFT%!" neq " " if "!WORLD_%NEXT_LEFT%!" neq "X" (
        if "%INVENTORY%" equ " " (
            set "INVENTORY=!WORLD_%NEXT_LEFT%!"
            set "WORLD_%NEXT_LEFT%= "
        )
    )
)

:: Строить блок под собой
if /i "%INPUT%" equ "e" (
    if "%INVENTORY%" neq " " if "!WORLD_%NEXT_LEFT%!" equ " " (
        set "WORLD_%NEXT_LEFT%=%INVENTORY%"
        set "INVENTORY= "
        set /a "PLAYER_POS+=1"
    )
)

:: Крафт меча (R) - требует 1 камень (#) в инвентаре
if /i "%INPUT%" equ "r" (
    if "%INVENTORY%" equ "#" (
        set "HAS_SWORD=1"
        set "INVENTORY= "
        echo Вы скрафтили Меч!
        timeout /t 1 >nul
    )
)

:: Атака мечом (F) - бьет по соседним клеткам, если есть меч
if /i "%INPUT%" equ "f" (
    if %HAS_SWORD% equ 1 (
        set /a "DIST=PLAYER_POS - ZOMBIE_POS"
        if !DIST! lss 0 set /a "DIST=-DIST"
        if !DIST! lss 3 (
            if %ZOMBIE_ALIVE% equ 1 (
                set /a "ZOMBIE_HP-=1"
                if !ZOMBIE_HP! lss 1 set "ZOMBIE_ALIVE=0"
            )
        )
    )
)

goto GAME_LOOP

:END_GAME
echo.
echo Спасибо за игру в 1D Minecraft Sword 1.0!
pause

