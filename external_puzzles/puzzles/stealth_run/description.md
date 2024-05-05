# TODO
1. textures for obstacles

# original description
```
9) "Мыфь кродётъся"

В стелс режиме, который представляет собой поле размером 15х20 клеток(на крайней левой клетке по центру находиться гг, а на крайней правой находиться награда,
 которая автоматически попадает к игроку в инвентарь, когда он наступает на клетку с наградой). На поле случайным образом расположены 10 врагов, которые смотрят 
влево, либо вправо, но каждые 7 секунд их спрайт меняется и они смотрят в противоположную сторону. Перемещение на WASD. Если расстояние между игроком и врагом 
менее 1 клетки, он сражается с 5 врагами(если врагов осталось меньше 5, то сражается с N оставшимися на поле). У врагов есть слепая зона расположенная за 
их спиной(противоположная клетка той, куда они смотрят). На эту клетку можно ступать и находиться вплотную к врагу (клетка к клетке).
В этот момент нажав на клавишу(Space), можно сделать скрытое убийство.
//Награда хз какая(у Андрея спросить) либо оставить без награды, но это как-то не очень
```
# Idea

### main cycle
1. Generate camp
2. Set enemies 
3. Generate reward
4. Start the puzzle

### generation

1. Gererate campfire

On the center tile. 3 enemies sit 2 away from the campfire in static mode

2. Gererate tents

Select 2 points on a circle, gen 2 rand floats. Those sill be polar coords of tents
tents look towards x=8 always. tents have 1 enemy in static mode.

3. Generate thees
	
gen 3 random `Vector2i` v such that v and v + (1, 1) are no closer that 3 towards any tent's or camfire's center and no closer that 1 tile from border


4. Select reward tent and put treasure (`EPWinCondition`) there

5. Assign states

Select a random enemy and put them to sleep
Select a random enemy and set them to pee mode.

### Enemies

##### states

1. sleep mode

 - no vision
 - no movement
 - wakes up if any noice is made

2. static mode
 - vision
 - no movement
 - can randomly go to pee

3. pee mode
 - vision
 - moves towards the tree, that is the furthest from the campfire
 - when reached it, sleeps for 5 seconds and goes back to original position, after which return to static mode

4. panic mode
 - vision
 - random movement (toward a random point)
 - when a corpse is seen every enemy goes into the panic mode

##### vision

enemies see by raycasing for lenght of 3 in 60 degree arc.

When player is seen puzzle is failed and player must fight surviving enemies.

When dead enemy is seen, panic mode is triggered

##### movement 

A* pathfinding on walkable tiles.

speed is 1 tile per 2 seconds in normal mode and 1 tile per 1 second in panic mode.

### Player

Wasd player extended.
On spacebar kills enemy within one tile.

### Win condiiton

player wins if treasure is taken and border is reached.

