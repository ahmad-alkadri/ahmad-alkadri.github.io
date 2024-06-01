---
title: "Go, Dino, Run!"
date: 2024-05-08T00:39:57+02:00
aliases:
    - /2024/05/08/microblog-dino-run-game-with-go/
categories: ["Microblog", "Coding", "Projects"]
description: "A Terminal Game; implementation of Chrome's offline Dino run game written in pure Golang."
weight: 1
cover:
    image: "/img/dino-run/dino-run-terminal.gif"
    caption: "\"You better not be a 🦖 running on terminal!\""
---

Started out as a kind of joke out of complete boredom.

Ended up probably another one of my long weekend projects.

Written in Go, playable in Terminal. Honestly not know yet how to realize it fully but feature list so far:

1. ~~A T-rex~~ ✅
2. ~~A T-rex that looks like it's running~~ ✅
3. ~~A T-rex that looks like it's running and, when the space bar's clicked, it can jump~~ ✅
4. ~~The ground that looks like it's moving and always changing~~ ✅
5. ~~Cactuses, appearing with random but jumpable spacing~~
6. ~~Cactuses, appearing with random but jumpable spacing that can render the game over if hit by the T-rex~~
7. ~~Some flying dino (pterodactyls) appearing with random but avoidable spacing that can hit you too~~

**UPDATE: June 2nd, 2024**

Game's fully playable and installable with the dinosaur, cactuses, and flying dinosaurs/pteranodons.

To install it, make sure firstly that you have Go installed in your machine. 
Refer to [Go's official website](https://go.dev/doc/install) on how to do that.

Afterwards, simply open a terminal and type in:

```bash
go install github.com/ahmad-alkadri/go-dinorun@latest
```

If all goes well, it'll install the game on your machine, which then
you can start playing by typing in:

```bash
go-dinorun
```

---

Questions? Bugs? Feel free to raise them as Issues on the code's
[repository](https://github.com/ahmad-alkadri/go-dinorun)!