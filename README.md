# uefn-verse-lab
Testing ground for the Verse language in Unreal Engine for Fortnite

## Memory Game
Based on the popular children's game played with a set of cards. Cards are represented as buttons using the Verse UI API. Players can press a button to reveal the number on the card behind it. Player can open up to N cards, and if all N cards have identical numbers, the player gets to keep the cards revealed. If any of the N cards has a different number, the cards are hidden again. Once the player reveals all cards, they win.

N is configurable, so is the number of cards per row and column. Best to configure these numbers within the UEFN editor. Game start is configured to wait for the player to press a button in the level by default.

Notable tricks used to make this game work are:
DynamicRace/RecursiveRace in ConcurrencyExtensions (rng_structures.verse) - Allows you to use a variable amount of expressions in a Verse race statement
ArrangeGrid in GUIExtensions (gui_extensions.verse) - Creates a relatively responsive UI by placing vertical stack boxes in a horizontal stack box to occupy most of the screen with rows and columns of buttons
IsAllEqual in Extensions (extensions.verse) - Uses the higher-level Reduce function to check if all members of the array are equal to each other, Reduce is an analog of Fold in Haskell