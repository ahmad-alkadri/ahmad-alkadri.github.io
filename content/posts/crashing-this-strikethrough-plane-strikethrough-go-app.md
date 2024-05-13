---
title: "Crashing This (Go) App"
date: 2024-05-13T19:20:03+02:00
draft: true
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
| /meirl |

