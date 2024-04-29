---
title: "Implementing Game Control, Part 1: Loop Control in Go"
date: 2024-04-20T17:08:53+02:00
categories: ["Coding", "Projects"]
description: How I implemented control on the Game of Life, Part 1 - Controlling
    infinite loop in Go programming language.
hideSummary: false
ShowToc: true
---

# What Is It

Previously, I wrote about my latest weekend project, which is [implementing the Game of
Life in Go](/2024/04/13/making-game-of-life-in-go).

It was honestly fun, perhaps the most enjoyable weekend project I've undertaken in the
past few years. I got to relearn the algorithm, figure out how to work with Terminal, and
navigate Go (a language in which I still feel somewhat like a beginner). In the end, I
enjoyed watching blinkers at the corner of my screen while I worked.

I wasn't planning on further developing the project, all things considered.

*However*, another project with a friend brought me back to it.

So basically, we were working on a project (completely unrelated to the Game of Life) when
we encountered a problem: how to pause a loop in our program based on user input. Here's
the tricky part: usually, we would just insert a `break` and move on with our day, but in
our case, we needed the loop to *not break* at all. We wanted it to simply *pause* when
the user entered a command, or when a certain condition occurred, and then continue again
when the user entered another command.

At that moment, I realized that the functionality we wanted could be fitting for a game:
Pause, Resume, and Stop if we wanted.

# Implementing the Control

## Solution 1: Go to Sleep

Our project was also written in Golang, making it quite an interesting exercise for me.

The first solution that came to mind was simply to go to sleep. This meant creating a
routine that read keyboard input, and if certain keys were pressed, it would send the data
to the running infinite loop.

In the case of "pause", if the "P" button is pressed, it would put the loop into *another
time-sleep infinite loop*, thus making the parent loop appear to be paused.

Here's the simplified example of the solution:

```go
package main

import (
	"fmt"
	"time"

	"github.com/eiannone/keyboard"
)

func main() {
	err := keyboard.Open()
	if err != nil {
		panic(err)
	}
	defer keyboard.Close()

	fmt.Println("Press 'P' to pause the loop, 'R' to resume, 'ESC' to quit.")

	var pause bool
	done := make(chan bool)

	go func() {
		for {
			char, key, err := keyboard.GetKey()
			if err != nil {
				panic(err)
			}
			if char == 'p' || char == 'P' {
				pause = true
				fmt.Println("Loop paused. Press 'R' to resume.")
			} else if char == 'r' || char == 'R' {
				pause = false
				fmt.Println("Loop resumed.")
			} else if key == keyboard.KeyEsc {
				fmt.Println("Exiting loop...")
				pause = false
				done <- true
			}
		}
	}()

	loop := true
	for loop {
		fmt.Println("Loop is running...")
		time.Sleep(200 * time.Millisecond)
		for pause { // Infinite loop of time sleep
			time.Sleep(1 * time.Second) // Go to sleep while loop is paused
		}
		select {
		case <-done:
			loop = false
		default:
		}
	}
}

```

When you run it and try the flow of `run -> pause (P) -> resume (R) -> stop (ESC)` the
control will have an output of the code like the following:

```bash
$ go run main.go
Press 'P' to pause the loop, 'R' to resume, 'ESC' to quit.
Loop is running...
Loop is running...
Loop is running...
Loop is running...
Loop is running...
Loop is running...
Loop paused. Press 'R' to resume.
Loop resumed.
Loop is running...
Loop is running...
Loop is running...
Loop is running...
Loop is running...
Exiting loop...
$

```

Also, when you try it with `run -> pause -> stop`, it will output like:

```bash
$ go run main.go
Press 'P' to pause the loop, 'R' to resume, 'ESC' to quit.
Loop is running...
Loop is running...
Loop is running...
Loop is running...
Loop paused. Press 'R' to resume.
Exiting loop...
$

```

So this solution ran well, but there's one thing that is bugging me: the fact that, inside
the parent loop, there's a child infinite loop that is still running. So we weren't really
*pause* the loop, we simply prevented the continuation of the loop by putting a loop
inside the loop. This makes it appear as though the larger loop is not working, while the
inner loop actually works all the time.

|![](/img/implementing-game-control-in-go/loopception.jpg) | 
| --- | 
| *More or less my expression when I realized* |

## Solution 2: Let It Go, Don't Show

With the understanding that I, in fact, did not manage to pause anything, and that it
would probably be very complicated to stop the entire process of the loop while *still*
making that loop read input, I tried to find other solutions.

Firstly, I realized there's a possibility to break the loop, save its last state, and when
the user gives new input, simply launch a new loop and take its last state as the new
initial state.

This looked promising, so I started pursuing it. I realized doing so would mean creating
the loop in a new routine, and that it would need to save the state in another channel. I
didn't mind that at all, and when I tested it, it could actually work.

However, in the project, the constraint remained: we should not break the loop at all
except when we close the program. Basically, because it's a big simulation, a calculation
tool, restarting a new loop in a new routine every time the user inputs pause/resume would
be costly. I thus tried to look for another solution.

Then I realized: if we can't stop the parent loop, and if it's a bit bugging to see the
loopception, why not just let the parent loop keep looping?

With a catch, though: under the "pause" condition, make the loop not work on the
calculation/processing that it would normally do.

Example of implementation:

```go
package main

import (
	"fmt"
	"time"

	"github.com/eiannone/keyboard"
)

func main() {
	err := keyboard.Open()
	if err != nil {
		panic(err)
	}
	defer keyboard.Close()

	fmt.Println("Press 'P' to pause the loop, 'R' to resume, 'ESC' to quit.")

	pause := false
	done := make(chan bool)

	go func() {
		for {
			char, key, err := keyboard.GetKey()
			if err != nil {
				panic(err)
			}
			switch {
			case char == 'p' || char == 'P':
				pause = true
				fmt.Println("Loop paused. Press 'R' to resume.")
			case char == 'r' || char == 'R':
				pause = false
				fmt.Println("Loop resumed.")
			case key == keyboard.KeyEsc:
				fmt.Println("Exiting loop...")
				done <- true
				return
			}
		}
	}()

	for {
		select {
		case <-done:
			return
		default:
			if !pause {
                // The Process block
				fmt.Println("Loop is running...")
				time.Sleep(200 * time.Millisecond)
			}
		}
	}
}

```

So no more infinite loop of sleeping inside of the parent loop. Instead, on `main()`
there's only one loop now (not counting the routine of course) and it'll keep running even
in `pause` state. Some output:

```bash
$ go run main.go    # flow: run -> exit
Press 'P' to pause the loop, 'R' to resume, 'ESC' to quit.
Loop is running...
Loop is running...
Loop is running...
Loop is running...
Exiting loop...
$ go run main.go    # flow: run -> pause -> resume -> pause -> exit
Press 'P' to pause the loop, 'R' to resume, 'ESC' to quit.
Loop is running...
Loop is running...
Loop is running...
Loop is running...
Loop is running...
Loop is running...
Loop is running...
Loop is running...
Loop is running...
Loop paused. Press 'R' to resume.
Loop resumed.
Loop is running...
Loop is running...
Loop is running...
Loop paused. Press 'R' to resume.
Exiting loop...
$ go run main.go    # flow: run -> pause -> resume -> exit
Press 'P' to pause the loop, 'R' to resume, 'ESC' to quit.
Loop is running...
Loop is running...
Loop is running...
Loop is running...
Loop paused. Press 'R' to resume.
Loop resumed.
Loop is running...
Loop is running...
Loop is running...
Exiting loop...
$

```

The only difference? In the `pause` state, it won't process the block at all. It will skip
over it and not show it to the user.

# Conclusion

In the end, we finally decided to use the second solution because:

1. It doesn't break the main loop,
2. It's simpler to implement.

Sure, it also feels like we're hiding processes from the user, but at our stage, user
experience counts a lot. As long as it appears that there's no process happening (which
isn't, as seen above), there should be no problem.

# Next Part

Part 2 of this subject will be posted later, and it will tell the story of how I
implemented loop control in [LaVieEnGo](https://github.com/ahmad-alkadri/LaVieEnGo),
effectively giving users a greater degree of control over the running of the game. I'll
post it in about a week, so stay tuned!