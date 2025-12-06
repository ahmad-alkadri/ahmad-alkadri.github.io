---
title: "There Is No Philosopher's Stone"
date: 2025-12-06T12:58:24+09:00
aliases:
    - /2025/12/06/there-is-no-philosophers-stone/
categories: ["Blog", "Coding"]
description: "Humankind cannot gain anything without first giving something in return. To obtain, something of equal value must be lost"
---

There is a particular kind of frustration that only shows up
after you've spent a few years actually owning a system.

Not the panic of an outage.
Not the annoyance of debugging someone else's five-hundred-line function.

I mean that quiet, stomach-sinking moment in front of a whiteboard when
you realise that **no matter what you choose, it feels wrong**.

You draw the first box: simple, straightforward, almost boring.
You draw the second: distributed, event-driven, "cloud-native."

Both look bad, just in different ways.

It's around that time that a small voice starts whispering in the back of your head:

> _Surely there must be a *better* way than this._

And if you watch enough conference talks, or scroll through enough
blog posts about "internet-scale" architectures, it's very tempting
to believe that there *is* such a way.

Something that's simple *and* fast *and* cheap *and* easy to maintain.
Something that scales effortlessly from one user to a hundred million.

Our own version of a **Philosopher's Stone**.

But over the years, after enough refactors and enough "this time
we'll get it right" projects, I've come to accept a less romantic law:

> To obtain, something of equal value must be lost.

In system design, there is no free lunch.
Every time we "solve" a scaling problem, we are paying with something:
**latency, complexity, or money**.

The question is not *"Can I avoid paying?"*
The question is *"Which currency am I spending, and is that deliberate?"*

This post is my attempt to write down that way of looking at things,
before I forget again and try to perform the engineer's version of
"Human Transmutation."

Because if you follow the old stories,
the Philosopher's Stone is supposed to do the impossible:
turn base metal into gold,
create an elixir of long life,
let you transmute anything into anything else.

Unlimited value, out of almost nothing.

Except even in the stories, it never really works that way.
The stone runs out.
The miracle has a side effect.
Or you eventually discover that the thing powering it
is not "nothing" at all,
but something terrible that was simply hidden from view.

---

## The Engineer's "Human Transmutation"

As I've written in previous posts, 
these days I work mostly in the BIM domain,
as in Building Information Modeling.
Not long ago, we had a problem at work
that I keep circling back to in my head.
I think of it as **the hundred-thousand-walls problem**.

So: imagine a very, very large building model. 
Hundreds of floors.
Each floor with many rooms.
Each floor with more than a thousand wall elements.
Pieces with varying dimensions, shapes, and orientations.
On every wall, there’s a small piece of information you need.
It might be the color, the material,
the fire rating, the acoustic properties, the thickness.
You have to go through the entire building, look at every wall,
do some processing, and then come back with the combined result.

On paper, it sounds straightforward.

Except each wall is actually backed by a database.
Or an upstream API.
Or some "harmless" CSV file on S3 that takes three seconds to read.

And, of course, there might be other building models
we also need to process.

Suddenly, the problem doesn't feel so simple anymore.

Faced with this, there are two temptations.

### The monolith: do it all at once

The first temptation is the kitchen-sink approach.

> "Let's just load everything!"

We write one big job that pulls data for all hundred walls in one go,
does all the processing in a single process, and spits out the result.

The logic is easy to follow.
You can debug it on your laptop with some sample data.
There is one code path, one log file, one place to put a breakpoint.

And then you try it with _real_ data.

Memory starts to climb.
One slow upstream makes the whole job crawl.
One unexpected element structure turns into a fatal error that kills the entire run.

You get a system that *works*--until it doesn't.
When it fails, it fails as a whole. All or nothing.

This is the brute-force transmutation circle drawn with a thick marker.
Simple, bold, and just a little bit reckless.

### The distributed sprawl: break it into pieces

The second temptation comes after the first one hurts you and your ego.

"Clearly, the problem is that it's too monolithic.
We need to break it apart. Make it parallel. Make it *scalable*."

So now each wall gets its own little worker.
Or its own function.
Or its own microservice with its own database and its own queue.

You introduce an orchestrator that decides which wall to process next.
You add a state machine to track which walls have been visited
and which have failed.

You add retries.
You add backoffs.

You add dashboards to try to see whatever the hell's going on.

The original problem was "do a calculation".
The new problem is "coordinate a small country with thousands of people in it each one of them doing hundreds of calculations".

Instead of one big failure mode, you now have many tiny ones that only appear
when three specific services deploy on the same afternoon
and some queue somewhere gets slightly backed up.

The computation didn't go away. You just traded it for coordination.

After a few cycles of this, I found myself asking:

> Why is there no good answer?
> Why do I have to choose between two bad ones?

---

## For Me, Thousands of Years in the Future

There was a manga that I read, a long time ago. Long ago
that I could feel time was bent everytime I tried to remember it.
Was it ten years ago? Twenty? A hundred?
Is there even any difference, at that scale?

I like that manga a lot. You probably know it. It's about bunch of alchemists.

There were moments, too many moments, inside that manga 
where the people--alchemists--very, very skilled and
capable ones by the way, not just side-characters or villains, but even the protagonists--
where they read the old books, read the literal laws of physics in their universe, and still
staring at the transmutation circle and thinks: _"Maybe I can bend the rules. Just this once"_.

They tried to get massive value--effortless scale, 
instant response--without paying the corresponding price.

In engineering, this is where we reach for our own
version of Human Transmutation:

- "What if we just… made it serverless?"
- "What if we just… re-architected into microservices now,
for future scale?"
- "What if we just… ask users to wait a bit longer--
they won't mind, right?"

Every time I've tried to cheat the law, it has come back
to collect, with interest.

In stories, there will be moments where
someone seemingly finally succeeds in making the miracle stone.

It glows. It heals. It gives you immortality.

It lets you ignore the rules of your freaking universe.

For a while.

Then you learn what it's actually made of.
You find the city buried under the capital.
You discover the country-sized transmutation circle
that has been quietly charging for generations.

You realise the price has already been paid--in lives, 
in secrets, in things nobody wanted to look at too closely.

From the outside, it looked like free power.
From the inside, it was just a very well-hidden bill.

So instead of asking, "Where is the perfect design?"
I've started asking a different question:

**What exactly are we paying with here?**

---

## The Threefold Trade

Throughout years of experience, I have found that almost every scaling decision
ends up spending one or more of three currencies:

1. **Latency (time)**
2. **Complexity (cognitive & operational load)**
3. **Direct cost (money)**

You can't get around them. You can only choose your mix.

Here's how they tend to show up.

### 1. Latency -- buying simplicity

This is the trade that feels almost embarrassingly old-fashioned.

"We'll just run it at night."

Or:

"This report doesn't need to be real-time. Tomorrow morning is fine."

When you pay with latency, you're buying **simplicity**.
You keep things in one place.
You don't need elaborate coordination.
You can write your logic as if the world were still small.

Batch jobs. Nightly pipelines. Hourly cron tasks.
All of these are alchemists choosing patience over spectacle.

The price, of course, is responsiveness.
Your users wait.
Your metrics are always a little bit stale.
Someone, somewhere, will ask:

> "Can we make this real-time?"

And the moment you say yes,
you are switching currencies.

### 2. Complexity -- buying capacity and resilience

This is the one that looks most like "real engineering"
in conference talks.

You introduce queues.
You introduce workers.
You introduce multiple databases, caches, regions,
gossip protocols, leader elections.

You're paying heavily in **complexity**.

In return, you get
more **capacity** (you can handle more load),
more **resilience** (some failures can be isolated),
and often better **latency** for the end user.

On paper, it looks like a great deal.

But complexity has a long half-life.

You don't just pay with extra lines of code.
You also pay with onboarding time for new developers,
longer incident calls, and that tired feeling when you open a Mermaid diagram
and realise you have to re-learn the whole system 
just to answer a seemingly simple question.

If latency is the alchemist quietly waiting
for the reaction to finish,
complexity is the alchemist drawing an incredibly intricate
transmutation circle.

Powerful, but unforgiving.

One missing symbol and the whole thing misfires.

### 3. Direct cost -- buying speed and convenience

This is the credit-card option.

You throw money at the problem.

"Let's just get the bigger instance."

"Let's just pay for the managed solution."

"Let's just use the vendor's magic autoscaling thing."

You're buying **speed & simplicity**.
Sometimes this is absolutely the right call.
There's a launch coming.
You have four engineers and no time.
Spinning up yet another internal platform is not the hill
you want to die on.

But every time you do this, you're also paying with
**financial efficiency** and **flexibility**.

You're tying your architecture to a pricing model
and to a vendor's roadmap.

Maybe that's fine today.

Maybe it's not fine when the bill doubles
because a single metric card went viral.

This is the precious catalyst in alchemy:
rare, effective, but not something you can
burn indefinitely without consequence.

---

Interlude: I think, my biggest mistake from early in
my career was for thinking that, and even believing,
that if I'm clever enough, I can avoid paying at all.

I believe this has set me back many times, and
unfortunately, only recently this finally has hit
me, and the impact was so real that I had to stop
and step back to reconsider my whole approaches
at work.

---

## The Engineer as an Alchemist

So what do we do with this, practically?

These days, when I'm in a design discussion,
I try to make the trades explicit.
Not in a spreadsheet (although that can help),
but in the actual language we use.

Instead of:

> "This design is better."

I try to ask:

> "For this feature, which currency are we willing to spend: latency, complexity, or cost?"

The answer is rarely "none".

### Warning signs of Human Transmutation

Over time, I've started to notice certain phrases
that make me nervous in design discussions.
They sound innocuous, but often they're hints that
we're trying to cheat the law.

Things like:

> "We can just make it serverless, and scaling will be free."

Translation: *We're pretending complexity goes away
because we can't see the control plane.*

Or:

> "Let's refactor it into microservices now for future scale."

Translation: *We're about to pay in complexity and cost
for scale we don't actually need yet, and might never reach.*

Or the quiet one:

> "Performance isn't a problem; the users will wait."

Sometimes that's true.
Sometimes it's a way of saying
"We don't want to think about latency,
so we'll pay with user's patience instead."

None of these sentences are inherently wrong.
I've probably said all of them at some point.
Hell, some of my (active) past works
are probably still running based on those things.

What matters is whether we can also say,
out loud, what we're paying with.

---

## The Peace of Giving Up Perfection

I have learned that there is a kind of peace that comes
from giving up on the idea of a perfectly scalable architecture.

Not in a cynical way--"everything is terrible"--but 
in a realistic way:

There is no magic.

There is no _Philosopher's Stone_.

There are only trade-offs. Exchange. Sacrifice.

To borrow a line from a certain story:

> To obtain, something of equal value must be lost.

The Philosopher's Stone--in software terms, that dream system that is infinitely scalable,
infinitely cheap, infinitely simple, and infinitely reliable--does not exist.

Chasing it leads to ruined projects, burned-out teams,
and a long trail of incomplete refactors.

And this is where I realized: an engineer's job is not to produce perfect solution.
As a matter of fact, a good enginer should accept that _there is no perfect solution_.
Instead, an engineer's job should be to lead their teams toward the
**least-bad sacrifice** that fits the goal,
right now, with the people and constraints that they have.

And of course, to write down the cost, so that one day, when future-us 
looks back and wonders, "what on earth were they thinking??", 
there's actually an answer.

---

## So What's Next?

Rather simple: next time you're faced with a 
problem--whether it's a game backend, a humble batch job,
or something in between--try saying the quiet part out loud:

> What are we buying?
> What are we selling?

And point yourself in the mirror and ask this: _what are we willing to pay with?_ 

Is it latency? Or complexity? Or money?

Just naming the currencies doesn't make the trade easy.
But I've found it's the first step away from wishful thinking and toward designs
that might actually survive contact with reality.

And of course, if, one day, someone shows me a true software Philosopher's Stone--
perfectly scalable, perfectly simple, perfectly cheap--I'll be happy to be wrong.

But until then, I'll keep practicing within the law.

