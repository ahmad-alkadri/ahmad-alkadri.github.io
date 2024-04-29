---
title: "Implementing Game Control, Part 2: On the Game of Life"
date: 2024-04-29T01:38:29+02:00
categories: ["Coding", "Projects"]
description: How I implemented control in the Game of Life, Part 2 - Controlling
    world updates in the Game.
hideSummary: false
ShowToc: true
---

# Previously

Hello! This is the second part of my two-part blog series on implementing game
control functionality in the Game of Life using Go. If you've just discovered my
blog and landed here first, I highly recommend starting with my last two posts:
one is about [how I wrote an implementation of the Game of Life in Go](/posts/making-game-of-life-in-go/), 
and the other one is the post that is the [first part of this series](/posts/implementing-game-control-part-1/).

So, the first part of this blog series provides an insight into my journey. It
details how I decided to add game control functionality to my Game of Life, what
motivated this decision, and how I went about implementing basic loop control in
Go. This served as a foundation and precursor before I moved on to implement the
game control feature in earnest.

Anyway, without further ado, let’s move to this second part of the blog.

# Refactoring

As described in the [original post](/posts/making-game-of-life-in-go/) 
about this Game of Life implementation, the initial setup of this project 
wass very simple. It was straightforward, it had no structure, just a big `main.go` 
file containing the whole code and a folder called `example/` containing, 
well, the example patterns that user can use.

```bash
.
├── examples
│   ├── gliding.txt
│   ├── heart.txt
│   └── toad.txt
├── go.mod
├── LICENSE
├── main.go
└── README.md
```

There was no technical reason for it aside of the fact that I just started the
whole thing as a side weekend project, not something that I was planning to
pursue further.

Well, until approximately ten days ago.

Once I decided to add game control to this Game of Life project, I began to test
different solutions. After [finding a promising approach](/posts/implementing-game-control-part-1/), I
knew it was time to start upgrading the project structure.

This wasn't just for looks - it was a necessary technical step. The upgrade
could make the project more complex and could also open up possibilities for
future growth and enhancements.

Given these factors, it was clear that a more modular approach was needed. The
goal of this restructuring was to make sure different parts of the project were
clearly separated and easy to maintain.

I had a few options in mind, but after some thought, I decided to go with the
[typical (though unofficial) standard Go project layout](https://github.com/golang-standards/project-layout). 
This led to a completely different project structure.

```bash
.
├── examples
│   ├── gliding.txt
│   ├── heart.txt
│   └── toad.txt
├── go.mod
├── go.sum
├── internal
│   ├── app
│   │   ├── control.go
│   │   ├── game.go
│   │   ├── logic.go
│   │   └── parsers.go
│   └── model
│       └── cell.go
├── LICENSE
├── main.go
└── README.md
```

This new arrangement involves moving the core components of our game into the
internal directory, categorizing them under 'app' for the main application logic
and 'model' for the data structures. This cleaner and more structured approach
makes the codebase easier to manage and develop.

# Implementing Control

## Channels and Routines

As you can see on the original post about the implementation of this Game of
Life that I did, the key to understand the whole thing is by seeing the whole
thing—world iteration, cells generation, etc.—as part of big loop. One step of
time happening inside this loop and *everything* will be updated. 

As previously explained in [the first part of this series](/posts/implementing-game-control-part-1/), 
the key to controlling the loop—creating the illusion of a pause—is achieved through the use of
channels and goroutines in Go. Two separate processes, namely the *game* process
and the *control* process, operate concurrently. 

Thus, the concurrency would be facilitated by launching these two processes as
separate goroutines.

Throughout the entire duration of the game, five major operations or events are
likely to occur:
1. the *control* event, which includes actions such as pausing or
resuming the game
2. the *step* event, which refers to advancing by a single step
while the game is paused
3. the *exit* event, which involves quitting the game
entirely
4. the *game over* event, which occurs when the game concludes naturally
without being manually terminated by the user; 
5. the potential *error* event. The error event could be caused by a wide range of issues but
we mostly focus on keyboard event error.

Given these five major events, we will require a minimum of five channels. Each
channel will correspond to a specific event and will be responsible for managing
the flow of information related to that event. This structure allows us to
maintain control over the game's operations and respond appropriately to various
events.

## Implementing on Code

The whole routines and channels would facilitate interactions between three
principal functions of the code: the `main()` , `Game()`, and `Control()`
functions.

### Main.go: Orchestrating Gameplay

```go
package main

import (
	"LaVieEnGo/internal/app"
	"fmt"
	"os"
	"os/signal"

	"github.com/eiannone/keyboard"
)

func main() {
	MaxX, MaxY := 60, 20
	initialCells := app.ReadInitialCoordinates(&MaxX, &MaxY)

	if err := keyboard.Open(); err != nil {
		fmt.Println("Failed to open keyboard:", err)
		return
	}
	defer func() {
		_ = keyboard.Close()
	}()

	controlChan := make(chan bool)
	stepChan := make(chan bool)
	exitChan := make(chan bool)
	gameOverChan := make(chan bool)
	keyErrorChan := make(chan error)

	// Goroutine for the Game() function
	// TO DO: go app.Game(...args)

	// Goroutine for the keyboard's Controller() function
	// TO DO: go app.Controller(...args)
	
	// TO DO: main loop
}
```

In the code above, `main.go` plays a crucial role in setting up the game
environment and managing the control flow of the game state through various
channels. It starts by defining the dimensions of the game world (`MaxX, MaxY :=
60, 20`) and reading the initial cell coordinates.

To handle the keyboard inputs, it leverages the [`keyboard` package](https://github.com/eiannone/keyboard). 
If there's an issue opening the keyboard, the function will cease execution and print the
error message.

Five channels are created (`controlChan`, `stepChan`, `exitChan`,
`gameOverChan`, `keyErrorChan`) each corresponding to a different event the game
needs to handle. The `controlChan` controls the pause and resume functionality,
`stepChan` manages the stepping operation when the game is paused, `exitChan` is
used to signal when the user wants to quit the game, `gameOverChan` indicates
when the game has naturally concluded, and `keyErrorChan` is used to handle any
keyboard errors.

Following this, two goroutines are set to be launched, one for running the game
and another for reading keyboard inputs. These goroutines will be interacting
with the various channels to control the game state and respond to user input.

### Upgrading `Game()` Function

We now set to create the `Game()` function, which is basically the separated,
wrapped version of its initial game logic that were put fully, simply, inside
the `main()` function at its initial version. As we can see, this function now
needs to take into account the control, exit, game over, and step channels
alongside of its cells and maximum coordinates as arguments.

Here’s the current implementation of the `Game()` function:

```go
// internal/app/game.go
package app

import (
	model "LaVieEnGo/internal/model"
	"fmt"
	"time"
)

func Game(
	initialCells map[model.Cell]bool,
	controlChan chan bool,
	exitChan chan bool,
	gameOverChan chan bool,
	stepChan chan bool,
	MaxX *int,
	MaxY *int,
) {
	paused := false
	liveCells := initialCells
	printBoard(liveCells, MaxX, MaxY)
	var anyWithinBoundaries, changed bool

	for {
		select {
		case <-exitChan:
			return
		case <-controlChan:
			paused = !paused
			if paused {
				fmt.Println("Game paused. [Right Arrow] Move forward a step.")
			}
		case <-stepChan:
			if paused {
				liveCells, anyWithinBoundaries, changed = updateWorld(
					liveCells, MaxX, MaxY, gameOverChan, paused)
				if !changed || !anyWithinBoundaries {
					return
				}
			}
		default:
			if !paused {
				liveCells, anyWithinBoundaries, changed = updateWorld(
					liveCells, MaxX, MaxY, gameOverChan, paused)
				if !changed || !anyWithinBoundaries {
					return
				}
			}
		}
	}
}
```

As we can see, the `Game()` function controls the game state, including the
game's pause/resume functionality, progressing the game a single step when
paused, and handling the game's conclusion, either when the user chooses to exit
or when the game naturally ends. It operates in a loop that runs for the
duration of the game, using Go's `select` statement to listen on multiple
channels and react accordingly to received events.

Inside the `Game()` function, the `updateWorld()` as a basically the motor of
the game. It’s principally the upgraded version of the `updateCells()`  function
from [the first version of the
game](/posts/making-game-of-life-in-go/#finalising-the-main--function).
It’s defined as:

```go
// internal/app/game.go

func updateWorld(
	liveCells map[model.Cell]bool,
	MaxX *int, MaxY *int,
	gameOverChan chan bool,
	paused bool,
) (map[model.Cell]bool, bool, bool) {
	printBoard(liveCells, MaxX, MaxY)
	liveCells, anyWithinBoundaries, changed := UpdateCells(liveCells, MaxX, MaxY)
	fmt.Println("[Space] Pause/Resume the game. [Ctrl+C] Exit the game.")
	if paused {
		fmt.Println("Game paused. [Right Arrow] Move forward a step.")
	}

	// Pause the time a bit for visibility
	time.Sleep(150 * time.Millisecond)

	// If there are no more changes or no live cells within the boundaries, stop the game.
	if !changed || !anyWithinBoundaries {
		printBoard(liveCells, MaxX, MaxY)
		if !changed {
			fmt.Println("No more changes, stopping the game.")
		} else {
			fmt.Println("No more live cells within the boundaries, stopping the game.")
		}
		gameOverChan <- true
		return nil, false, false // Return nil map and false to indicate game over.
	}

	return liveCells, anyWithinBoundaries, changed
}
```

The `updateWorld()` function is a crucial part of the game logic, controlling
how the game state updates over time. It takes as arguments the current state of
live cells, the maximum boundaries of the game, the `gameOverChan` channel, and
a `paused` boolean indicating whether the game is paused. In each call, it
updates the world by printing the current state of the game board, updating the
cells, and printing controls for the user. It also incorporates a slight delay
to make the game progress visible to the user.

This function also handles game termination conditions. If there are no more
changes in the cells (indicating a stable state) or if there are no live cells
within the boundaries of the game (indicating all cells have died or moved out
of bounds), the game is stopped. A message is sent over the `gameOverChan`
channel to signal that the game has naturally concluded, and the function
returns a `nil` map and `false` values, indicating game over.

The next part would explain a bit about the second principal function, which is
the `Controller()` function.

### Controlling the Game

```go
// internal/app/control.go

package app

import (
	"fmt"

	"github.com/eiannone/keyboard"
)

func Controller(
	keyErrorChan chan error,
	controlChan chan bool,
	exitChan chan bool,
	stepChan chan bool,
) {
	for {
		char, key, err := keyboard.GetKey()
		if err != nil {
			keyErrorChan <- err
			return
		}

		if key == keyboard.KeySpace {
			controlChan <- true // Toggle pause/resume
		}

		if key == keyboard.KeyArrowRight {
			stepChan <- true // Move forward one step
		}

		if char == 'p' || char == 'P' {
			controlChan <- true // Toggle pause/resume
		}

		if key == keyboard.KeyCtrlC {
			fmt.Println("\nExiting...")
			exitChan <- true
			return
		}
	}
}
```

The `Controller()` function in the code block above plays a crucial role in
accepting and processing user inputs in real-time during the game's execution.
It operates in an infinite loop, continuously listening for keyboard inputs. The
retrieved key or character is then matched against various conditions to
determine the appropriate action.

The keyboard inputs are space (' '), right arrow, 'p' or 'P', and Ctrl+C, each
of which corresponds to a specific game action. The space and 'p'/'P' inputs
toggle the game's pause/resume state, with the corresponding boolean value sent
over the `controlChan` channel. The right arrow input advances the game by one
step when it's paused, sending a true value over the `stepChan` channel. The
Ctrl+C input signals the game to exit, sending a true value over the `exitChan`
channel and terminating the function.

If there's an error retrieving the keyboard input, the error is sent over the
`keyErrorChan` channel and the function is terminated. This allows the main
program to handle the error appropriately, ensuring the game doesn't crash due
to unexpected input problems.

Now, with those two principal functions ready, we can advance towards the
finalization of the `main()` function.

### Finalizing the Main()

```go
package main

import (
	"LaVieEnGo/internal/app"
	"fmt"
	"os"
	"os/signal"

	"github.com/eiannone/keyboard"
)

func main() {
	MaxX, MaxY := 60, 20
	initialCells := app.ReadInitialCoordinates(&MaxX, &MaxY)

	if err := keyboard.Open(); err != nil {
		fmt.Println("Failed to open keyboard:", err)
		return
	}
	defer func() {
		_ = keyboard.Close()
	}()

	controlChan := make(chan bool)
	stepChan := make(chan bool)
	exitChan := make(chan bool)
	gameOverChan := make(chan bool)
	keyErrorChan := make(chan error)

	// Goroutine for the game
	go app.Game(initialCells, controlChan, exitChan, gameOverChan, stepChan, &MaxX, &MaxY)

	// Goroutine to read keyboard inputs
	go app.Controller(keyErrorChan, controlChan, exitChan, stepChan)

	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt) // Listen for Ctrl+C signal

	for {
		select {
		case <-c: // Handle Ctrl+C
			fmt.Println("\nExiting...")
			close(exitChan)
			return
		case <-gameOverChan:
			return
		case <-exitChan:
			return
		case err := <-keyErrorChan:
			fmt.Println("Error reading key:", err)
			os.Exit(1)
		}
	}
}
```

As you can see, other than the launching of the routines and the usage of the
channels, the rest of the `main()` function is simply a loop that listens on those 
multiple channels, using a `select` statement to respond to received events. 
It handles game termination conditions, either when the user sends a Ctrl+C signal 
or when a signal is received on the `gameOverChan` or `exitChan`. 

If there's an error reading the keyboard input (signalled by receiving an error on the
`keyErrorChan`), the error is printed and the program is terminated.

# How it Looks Like

Below is a screen record on how the game was:
1. Launched normally
2. Launched normally, paused, then resumed
3. Launched normally, paused, then moved forward step by step until the game's over.

It used the heart pattern, which is located in the `examples/` folder in the
game's repo.

![](/img/implementing-game-control-in-go/render_game_updated.gif)

# Conclusion

In conclusion, the new control that's been implemented above allows players to pause
and resume the game, advance the game one step at a time, and exit the game
whenever they choose. 

The use of goroutines and channels in Go made it possible
to manage these features effectively, offering a real-time, interactive gaming
experience.

Now, at last: I encourage you to try it out! 
The complete code is available on the github repo 
[here](https://github.com/ahmad-alkadri/LaVieEnGo). 
Feel free to explore, make changes,
and even contribute if you wish. 

Cheers!