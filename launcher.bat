@echo off
setlocal enabledelayedexpansion
title Minecraft 1.1 Pure Batch Edition
color 0A
mode con: cols=60 lines=15

:: 1. ИНИЦИАЛИЗАЦИЯ ПАРАМЕТРОВ
set "WIDTH=40"
set "PLAYER=12"
set "INV= "

:: Генерация начального ландшафта (0-3 камень, 4-7 земля, дальше воздух)
for /l %%i in (0,1,%WIDTH%) do (
    if %%i equ 0 ( set "MAP_%%i=X" ) else (
    if %%i equ %WIDTH% ( set "MAP_%%i=X" ) else (
    if %%i lss 4 ( set "MAP_%%i=#" ) else (
    if %%i lss 8 ( set "MAP_%%i=." ) else (
    set "MAP_%%i= "
    ))))
)

:GAME_LOOP
:: 2. ФИЗИКА ГРАВИТАЦИИ (падаем, если под ногами воздух)
set /a "DOWN=PLAYER - 1"
if "!MAP_%DOWN%!" equ " " (
    set /a "PLAYER-=1"
    goto GAME_LOOP
)

:: 3. ОТРИСОВКА ЭКРАНА В КОНСОЛИ
cls
echo === MINECRAFT 1D v1.1 (PURE BATCH) ===
echo.

set "LINE="
for /l %%i in (0,1,%WIDTH%) do (
    set "CELL=!MAP_%%i!"
    if %%i equ %PLAYER% set "CELL=P"
    set "LINE=!LINE!!CELL!"
)
echo %LINE%
echo.

:: Отображение инвентаря
set "INV_NAME=Пусто"
if "%INV%" equ "." set "INV_NAME=Земля"
if "%INV%" equ "#" set "INV_NAME=Камень"

echo [Инвентарь]: %INV_NAME%
echo [Управление]: A (Влево) ^| D (Вправо) ^| Q (Копать) ^| E (Строить) ^| X (Выход)
echo.

:: 4. ЧТЕНИЕ И ОБРАБОТКА КОМАНД
set "KEY="
set /p "KEY=Действие: "
if /i "%KEY%" equ "x" goto EXIT

set /a "L=PLAYER - 1"
set /a "R=PLAYER + 1"

:: Движение влево и вправо
if /i "%KEY%" equ "a" if "!MAP_%L%!" equ " " set /a "PLAYER-=1"
if /i "%KEY%" equ "d" if "!MAP_%R%!" equ " " set /a "PLAYER+=1"

:: Механика Q — Копать блок под собой
if /i "%KEY%" equ "q" if "!MAP_%L%!" neq " " if "!MAP_%L%!" neq "X" if "%INV%" equ " " (
    set "INV=!MAP_%L%!"
    set "MAP_%L%= "
)

:: Механика E — Строить блок под себя
if /i "%KEY%" equ "e" if "%INV%" neq " " if "!MAP_%L%!" equ " " (
    set "MAP_%L%=%INV%"
    set "INV= "
    set /a "PLAYER+=1"
)

goto GAME_LOOP

:EXIT
echo.
echo Спасибо за игру!
pause
