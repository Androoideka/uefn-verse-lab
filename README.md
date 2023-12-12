# uefn-verse-lab
Testing ground for the Verse language in Unreal Engine for Fortnite

## Memory Game
Based on the popular children's game played with a set of cards. Cards are represented as buttons using the Verse UI API. Players can press a button to reveal the number on the card behind it. Player can open up to N cards, and if all N cards have identical numbers, the player gets to keep the cards revealed. If any of the N cards has a different number, the cards are hidden again. Once the player reveals all cards, they win.

N is configurable, so is the number of cards per row and column. Best to configure these numbers within the UEFN editor. Game start is configured to wait for the player to press a button in the level by default.

### Notable tricks used to make this game work are:

- DynamicRace/RecursiveRace in ConcurrencyExtensions (rng_structures.verse) - Allows you to use a variable amount of expressions in a Verse race statement

- ArrangeGrid in GUIExtensions (gui_extensions.verse) - Creates a relatively responsive UI by placing vertical stack boxes in a horizontal stack box to occupy most of the screen with rows and columns of buttons

- IsAllEqual in Extensions (extensions.verse) - Uses the higher-level Reduce function to check if all members of the array are equal to each other, Reduce is an analog of Fold in Haskell

## Teleportation
Allows the player to designate a home spot and then teleport to it at a later time. The player is given a signal device, with the primary signal setting the home spot and the secondary signal initiating the teleport. The primary signal has 2 implementations for determining the home spot, one uses the player's current location as the new home spot, one uses the intersection of the player's aiming direction with the closest object as the new home spot.

The directional teleport implementation requires you to add a few prop movers + props into the level and connect them in order with the hearth device. The number does not matter much after 3-4 as the prop movers are added to a reusable pool and will be deposited back to the pool once they have determined the home spot.

There is currently a limitation where a prop mover might not return to the pool if it never hits an object such as if it's sent into the sky or off the map. This is easily fixable by adding a timeout.

There is another limitation that the prop mover only registers collisions with other props, so you will only be able to teleport on props. This shouldn't be an issue in most cases as floors are generally classed as props.

### Notable tricks used to make this mechanic work are:

- teleporter.Start/teleporter.Flow (hearth.verse) - starts an independent teleportation flow for each player and uses the result of the race expression to determine whether a new home spot was set or the player initiated teleportation

- raycaster.DeterminePosition (hearth.verse) - Uses a prop mover + prop to move an invisible prop from the player's viewpoint to the first obstacle in front of them, and uses the location of the prop once it hits the obstacle as the home spot

- raycasting_pool (hearth.verse) - Creates a pool of objects that requires users to return the object before another user can take it. Uses a static block to initialize the pool with the objects set to available. I wanted to make this a class with a parametric type but unfortunately Verse does not currently support mutable members in parametric classes (seems to be planned for the future)

## Conway's Game of Life
An implementation of the popular cellular automaton using colours on floor tiles to depict whether cells are alive or dead. Players can bring new cells to life by shooting tiles with a gun. They can also pause the simulation to prepare more intricate patterns and reset the board to have a clean slate. Follows the standard rules where:

- neighbours of a tile include tiles that are diagonally adjacent to it

- cells that have 2 or 3 living neighbours stay alive

- tiles that have 3 living neighbours become living cells

You can try this out in Fortnite using the island code: 2798-0145-6557

### Notable tricks used to make this mechanic work are:

- Monitorable/Tile (game_of_life_device.verse) - Uses Sleep(0.0), which sleeps until the next tick, to check whether a tile has been shot