---
title: "Crashing This (Go) App"
date: 2024-05-13T19:20:03+02:00
description: "In which I transform a meme into a practical \
	guide for crashing simulation services in nested virtual machines, ensuring no survivors."
---

It started out innocently from the well-known meme, but
at the end this whole thing ended up very useful for my work,
so I was thinking that it'd be great to share it here.

I'll save you from the pain of hearing the backstory of
meme exchanges between me and my friends, but instead I'll
tell you the conditions where this code finally be useful.

So basically one of the simulation services I had was running
really well. It ran inside a VM that was nested inside another
VM that was nested inside a big server. In my line of work,
simulations mean calculations, and from my part, whenever
we do calculations, ofte times it could be ranging from light
structural calculation to long-running, parallel, asynchronous
finite element simulations.

The simulation services were spread through several instances
on several VMs. We used a pretty well-established and battle-tested
frameworks. Still, from time to time, there were cases where,
because of such extensive and demanding calculations, the app
would ran out of memory and practically crashed. It was tolerable
at first, until one day, the whole container froze and affected
the VM. I couldn't stop, pause, restart, or do anything to fix them.
I had to practically turned off whole VM and restarted them.
Luckily all containers were auto-self-restart, but it still sucked
losing some precious hours struggling on this.

Through little discussion I offered, "Why don't we crash it before
it ran out of memory?" to my colleague. We laughed at that idea
for a while, but almost immediately we started thinking seriously
about it.

| ![](/img/crashing-this-app/me-fr.png) |
| --- |
| */meirl* |

We tried some things for a while, and I finally found out
that it was a bit easier than I thought.

Taking advantage of `goroutine`, I simply made a function
that'll run continuously alongside the main function,
monitoring the memory consumption all the time. The
function was made so that it ran every second, and 
when it detected that the memory has passed certain
limit (defined in environmental variable `APP_MEMORY_LIMIT`
and, if such variable isn't defined, it'll use a default
value defined in-code).

The function's definition:

```go
// app/internal/watcher/memwatcher.go
package memwatch

import (
	"log"
	"os"
	"runtime"
	"strconv"
	"time"
)

func CheckMemoryUsage() {
	var memStats runtime.MemStats

	limitStr := os.Getenv("APP_MEMORY_LIMIT")
	var maxMemory uint64
	if limitStr != "" {
		limit, err := strconv.ParseUint(limitStr, 10, 64)
		if err != nil {
			log.Printf("Invalid APP_MEMORY_LIMIT value, defaulting to 5MB: %v\n", err)
			maxMemory = 5 * 1024 * 1024 // Default to 5 MB for this example.
		} else {
			maxMemory = limit * 1024 * 1024 // Convert MB to bytes.
		}
	} else {
		maxMemory = 5 * 1024 * 1024 // Default to 5 MB for this example.
	}

	for {
		runtime.ReadMemStats(&memStats)
		if memStats.Alloc > maxMemory {
			log.Printf("Memory usage exceeded %v bytes, shutting down\n", maxMemory)
			os.Exit(1)
		}
		time.Sleep(1 * time.Second)
	}
}
```

You can see and test this function in action on the
[example repo](https://github.com/ahmad-alkadri/crashing-this-fibo) 
that I've put on my github. In short though, the function
would be called from the `main()` as follows:

```go
package main

import (
  // The app name is 'crashing-this-fibo' btw
	"github.com/ahmad-alkadri/crashing-this-fibo/internal/api"
	memwatch "github.com/ahmad-alkadri/crashing-this-fibo/internal/watcher"

	"log"
	"net/http"
)

func main() {
	go memwatch.CheckMemoryUsage() // Start memory monitoring

	mux := api.NewRouter() // Setup routes using the built-in HTTP routing
	log.Println("Server is running on port 8080...")
	log.Fatal(http.ListenAndServe(":8080", mux))
} 
```

The example application that I use here is a simple REST API app
that accepts request to the `/fib` endpoint with query `'n'`
in which `'n'` is an integer and it'll calculate, and return,
the fibonacci number of that `'n'`.

Also, for demo purpose, I've included in the repo, a 
[bash script](https://github.com/ahmad-alkadri/crashing-this-fibo/blob/main/scripts/load_test.sh)
that basically called the [`vegeta`](https://github.com/tsenart/vegeta) 
tool to do self-DDoS (jk, it's a heavy-duty load testing tool, 
pretty cool because of its capabilities truly) and send the endpoint 
above like 200 requests per second (or even more). With that
script you can test sending so many requests to the endpoint of the
go REST API app above, and if things work correctly, the memory
watcher will terminate the app once the load is bigger than the limit.

You're welcome to clone, launch the app, test it, modify it
as you wish, take or use the memory watcher function, etc.

## Remember Though

One thing to remember from all of the above though (in
case it wasn't clear): this method is not fit
for long term use. At best it's a band-aid. If your
app, in production, could be out of memory because of
too much requests, either:

1. Implement some kind of queue system
2. Implement some kind of rate limiter
3. etc.

instead of purposefully crashing the app. Especially
if many people (customers, clients, etc.) depend
on your app. Treat it as a tech debt to be paid.

And yes, from my side, the simulation app was
finally fixed and of course the ~~big guy~~ function
above is no longer used. Still, there could be 
some cases or situations where it could be helpful.

So, to close this short blog: You're welcome to clone the repo, 
launch the app, test it, modify it
as you wish, take or use the memory watcher function, etc.

If you have any questions, feel free to ask!
