---
title: "A Variable by Any Other Name"
date: 2025-12-14T01:03:30+09:00
aliases:
    - /2025/12/14/a-variable-by-any-other-name/
categories: ["Blog", "Programming", "Coding"]
description: "On why naming things in code is actually a linguistic and existential problem, and what our choices reveal."
cover:
    image: "/img/a-variable-by-any-other-name/FromYou2000YearsAgo.jpg"
    caption: "To you, 2000 years from now"

---

There was an engineer named Phil Karlton. 
You probably haven't heard of him, but if you've been around software long enough, 
you've definitely heard his quotes. He worked at Netscape--back when Netscape was *the* browser, 
before Chrome, before Firefox, when the web was still figuring out what it wanted to be. 
This was the mid-'90s. Netscape Navigator reached something like 90% market share at its peak in 1995. 
If you wanted to browse the internet, you used Netscape. Period.

Phil, being the pragmatic engineer he was, had this observation. He said it at conferences, in meetings, to colleagues. Said it enough times that it stuck:

> There are only two hard things in Computer Science: cache invalidation and naming things.

It's a good quote. Memorable. The kind of thing that gets passed around in mailing lists and forums. 
You can debate whether it's actually true--plenty of hard things in computer science, after all--but I think most people who've written production code would at least nod along. 
Yeah, those two are hard.

I certainly have. I've dealt with both. A lot.

Let me tell you about cache invalidation first, since that's the one most people cite when they bring up this quote. I've got a fresh example.

I got an object called "A". Thousands upon thousands of requests coming in for it. The database was getting hammered, so I threw a cache layer in front. I cached an object "A" as "a". Performance skyrocketed. Everyone celebrated.

Then I forgot: there is a scenario where "A" can change to "A.1". I forgot to invalidate
the cache when that happened. So the cache kept serving "a", the old version, 
even after "A" had changed to "A.1". People started getting stale data. Whole features broke. 
P-zero incident. I dropped everything, spent the whole afternoon fixing my stupidity.

See the point is: cache invalidation is hard but it *fails loudly*. You see it. You feel it. 
It's like a tiger ready to pounce--you learn to keep watching. Never turn your back. 
You learn to ask the questions: Have I covered that edge case? What about this one? 
Is there a path where the cache doesn't invalidate when it should?
It's an insidious problem, but it's a **known** one. You can see the tiger watching you.

But after you spend enough time actually working on systems--real systems in production, maintained by teams, constantly being developed--you begin to suspect the real problem is something else entirely. 
Something quieter. Something you can't see until it's too late.

Naming things.

## A Bad Name

A bad name sits in your codebase like a quiet virus. 
It poisons every person who reads it. It compounds over time. 
Five years from now, someone will spend an hour, probably more, trying to understand what `state` really means. 
Or why `handle` is called `handle`, or whether they should call the function `get` or `fetch` or `retrieve`. 

And they will ask around. They will scour the documentations. 
If they're lucky, they'll stumble upon the old grumpy dev, sitting
on his chair in his black sweater (swear to God this guy has been wearing the same thing 
every single day since you joined the company. Like your office's own version of Steve Jobs 
wearing turtleneck and jeans guy), and they'll ask what do those names mean. 
The guy would probably be grumpy but he'll be able to answer. 

All is well. Life is good. 

But other answers can bring a different mood.

"The hell if I know."

"It was years ago."

"You were probably in diapers when I wrote those kiddo."

Or even worse--the dev already left. Documentation's scarce. 
You are left to no other choice than trying to understand the legacy microservice code
bit by bit, line by line, maybe turning up that debugger, open the `All.sln` that was last opened
when Visual Studio still below 2020.

(There's even a worse scenario here--the code was named by an LLM.
The dev wasn't even really sure what those lines were doing. 
*The horror*. Who you gonna call at that point??)

I've been thinking about this a lot lately. 
Perhaps because I work with people from various countries, who speak different languages. 
Or because I'm always translating between English, French, and Japanese in my head, at work, everywhere. 
Or perhaps because I recently remembered a fantasy novel
that I read a long time ago and one that I've been struggling to find again in Japan.

In any case, somewhere along the way, I realized: naming things in code is not actually a technical problem.

It's an existential one.

## The Translation Problem

When I first moved to Europe--to France, specifically--I learned to code in French. 
It was very interesting. The classes were so old school.
The teachers printed leaflets and distributed them to us. Example codes. Instructions. Designs. 
We typed those into our laptops bit by bit. Tried some. Failed. Succeeded some.

One thing I learned over my years studying there was this: C, C++, Fortran, Gibiane, all those guys, 
they don't care if you swear at them in French or English. As long as you write the correct syntax,
you can literally give the variables, functions, any name that you want.

However, when I started collaborating with French engineers, researchers, trying to understand their code
and making code that they too can understand, I had to learn how French engineers *thought* about naming. 
How they approached the problem of giving things names.

See, here's one thing I noticed: English is *precise but verbose*. They value simplicity.
If you wanted to convey that something manages user authentication, you could name it `UserAuthenticationManager`.
It's long, but it's unmistakable. Every word earns its place. 
English culture, in some sense, as far as I have learned, values explicitness--say what you mean, 
mean what you say.

French, on the other hand, values *elegance*. Economy. The same thing might be called `Authentificateur`. 
Or, if they chose to write in English, it would be like `Authentificator`. `Validator`. `Checker`.
You might find [a function named](https://www-cast3m.cea.fr/index.php?page=notices&notice=PASAPAS) `PASAPAS`. 
[Or another called](https://github.com/mistralai/mistral-vibe/blob/661588de0ccee6338de8546749d70513b5b8f837/vibe/core/programmatic.py#L12) `run_programmatic`.
I got the strong impression that French engineers assume that if you're reading their code, you understand the *domain* already.
They don't have the time to explain how `PASAPAS` relates to unsteady-state simulations.
They're not going to spell everything out. It would be redundant, almost insulting.
Would be like, *"Qu'est-ce que tu es un idiot? Stupide ou quoi?"*

(I'm not sure yet about Japanese. Not just because my Japanese is still not good enough, but because I haven't worked long enough
with Japanese engineers. Maybe I'll come back here after I've worked with them for more than two years!)

And here's the thing: *none of these approaches is wrong*. They're just different linguistic choices. Cultural stuff.
But when you sit down to name something in code, you're making one of these choices whether you realize it or not. 
You're encoding a *philosophy of communication* into your naming scheme.

---

**Lots of stuff from here onwards will contain many of my biases. You've been warned!**

---

## Names as Design Decisions

Let's jump into some concrete examples. Start with the following two functions:

```go
getUserData()
fetchUserDataFromAPI()
```

At first glance, they seem to do the same thing. But they don't. Not really.

`getUserData()` hides something. It hides the fact that this is a *network call*. It hides latency. It hides the possibility of failure. 
It pretends that getting user data is as simple as reading from memory. This name feels like a *lie*, in a way. 
A well-intentioned one, but a lie nonetheless. It abstracts away the complexity and, in doing so, it hides the cost.

`fetchUserDataFromAPI()` is honest. It tells you: *I'll go fetch the user data from API*. 
Which API? We don't know yet. But it is already saying: this isn't free at all. This can be costly.
This can fail. This has a side effect. When you call this, you're crossing a boundary.

Which should you use? It depends on what you're trying to communicate. 
If the callers *need to know* that this is a network operation because they need to handle errors, or consider caching, 
or think about retry logic, then the second name is better. 
If you've built an abstraction layer where all data retrieval happens through the same interface, 
and you want to hide the implementation details, then the first name is fine, as long as you've *made a conscious decision* to hide it.

But here's what I see in many codebases: neither. People pick names almost at random. 
They name something `fetchData()` because they thought of it first, then later realize it should be `getData()` because it's cached, 
then later realize it might be `loadData()` because they added another behavior behind it. 
The name never quite settles.

But I think at that point it's still OK. The problem comes when people don't realize they're making a decision at all.

Let me give you another example. Variables:

```go
tempResult := process(data)

accumulator := process(data)
```

`tempResult` is a name that says: "I don't know what this is. I don't know how long it will live. I didn't think hard about this, so I picked the first word that came to mind." 

`accumulator` is more honest. It tells you something about *what the variable does*, about its role in the algorithm. 
It says: "I'm collecting something. I'm building something up. Watch me closely."

The deeper insight here is this: **the name you choose is a bet on what matters about this thing**. 
When you name something `UserAuthenticationManager`, you're betting that what matters is that it manages authentication for users. 
When you name it `Authenticator`, you're betting that the "user" part is implied by context. 
When you name it `auth`, you're betting that anyone reading this code will understand the domain well enough to fill in the blanks.

None of these bets are inherently wrong. But they should be *conscious bets*, not accidents.

## The Ambiguity Problem

Of course, there's another layer of complexity. Sometimes the same name can mean completely different things depending on context.

The word `state`. What does it mean?
- In politics, it means a country.
- In physics, it means the condition of a system at a given time.
- In React, it means component state—data that changes over time.
- In a state machine, it means the current node in the graph.
- In a rendering engine, it might mean rendering state. Textures, shaders, GPU memory.

All of these are `state`. But they're wildly different things. 
If I ask you to refactor a function called `updateState()`, you won't know where to start until you understand which kind of state we're talking about.

The same with `handle`. Is it a handle to a file? A handler for events? A UI element you can grab? 
That word is so overloaded that it can mean almost anything.

Or `run_programmatic`. Does it mean "run something in a programmatic way"? Or "run the programmatic module"? Or something else entirely?

[E.L. Doctorow once said](https://www.smh.com.au/entertainment/books/e-l-doctorow-an-interview-20140206-322pk.html), 
"The nature of good fiction is that it dwells in ambiguity." Characters in literature often misunderstand each other profoundly 
because a word has multiple meanings, and they're each holding a different one in their mind. Readers often misunderstand the author's intent
because they bring their own context to the words. And Readers even misinterpret characters' motivations 
because they project their own experiences onto them.

All of these things work beautifully in fiction. It's *evocative*. It's *realistic*, even.

However, as Alfred Adler said, "All problems are interpersonal relationship problems." 
And many interpersonal problems arise from miscommunication, from ambiguity in language.
In code, ambiguity is a wound. The precision that kills creativity is the same precision that makes code maintainable.

But how is that possible? Why is that the case?

Simple: because a code is not just commands to a machine. When you write code, you're also writing for other people.

## The Hidden Conversation

Here's a simple truth that took me too long to realize: when you name something in code, 
you're not just picking a label. 
You're having a conversation with someone. 

You don't know who. Yet.

Maybe it's your future teammate, six months from now, bleary-eyed at 11 in the evening trying to understand what on God's green earth you were thinking when you wrote the code. 

Maybe it's your Team Lead, trying to make sense of your decisions, because surely you had a reason for choosing that architecture, that pattern, that library, right? Of course you wouldn't just pick something at random, would you? 

Or maybe it's someone else. Maybe it's a newly recruited developer who inherits your code years after you've moved to another country,
after you've been feeling hopeless from years of trying to integrate into the cold unforgiving weather and culture in Europe,
finally crossing continents and leaving your old life behind.

That conversation happens through names. *Only* through names, in many cases. 
The rest of the code is implementation details. 

The names are the *meaning*.

(What about docstrings? Imagine this: you saw someone the first time. You ask them their names. You don't ask for their life story.
You just want to know *who* they are. The name is the first step in building understanding.)

Ultimately, in a way, naming is how you *justify your code's existence*. When you name something well, you're justifying why it exists. 
You're saying: "I thought about this. I made a choice. This is worth your time to understand." 

A bad name is the opposite. It's saying: "I didn't think this mattered enough to explain. I just picked something quick. Deal with it. Or delete it. Change it. I don't care."

And sometimes--this is important--a name *can't* say everything. You can't encode an entire algorithm into a variable name. 
You start digging deeper. You form a relationship with that new person you met. At those moments, you *need* documentation. 
You ask for the life story. You see tests. Their life trials. You realize you need better boundaries between systems. 
You need to refactor the code so that the name can match the reality.

But most of the time, when people say "this code is hard to understand," what they really mean is "the names don't match what the code actually does." 

The names and the reality have drifted apart.

## Practical Implications

Let me be concrete about this, because I know I've been a bit woolgathering. My apologies.

When you rename something in a codebase--when you go back and say "this function is called `parse()` but it really validates and transforms, so let's call it `parseAndValidate()` or better yet, `buildFromRawInput()`"--the code suddenly *makes sense* in a way it didn't before. 
You're not changing the logic. You're not fixing any bugs. You're just having a clearer conversation about what the code does.

I've seen teams adopt naming conventions--camelCase vs snake_case, prefixes like `is_` for booleans, `make_` for constructors. 
These aren't arbitrary. Each convention encodes an *assumption* about the code. `is_active` tells you something is a boolean. 
`get_user_if_exists()` tells you it might be expensive, or might return null. 
These conventions are like grammar rules: they help readers parse the meaning faster.

And domain-driven design works for exactly this reason. When your code's names match the *business language*,
when you call a function `calculateTotalRevenue()` instead of `sum()` or `aggregate()`,
the translation layer between the domain expert and the engineer disappears. 
Everyone is speaking the same language. The ambiguity evaporates.

Of course, again, that only works if you *actually* understand the domain. 
If you force domain language onto code that doesn't match the domain, you just add another layer of confusion.

## The Quiet Realization

Here's something that took me years to really understand: naming isn't something you do *after* you write code. 
It's something you should do *alongside* writing it. 
The act of naming is the act of *clarifying your thinking*. 
If you can't find a good name for something, it's often because you don't fully understand what it does yet.

The name is the clarity checkpoint.

When you reach that point, the names become obvious. They flow naturally from your understanding.

Bad names are a sign that you're still confused. 
They're not a failure of vocabulary. They're a failure to think clearly.

And this is where I think AI tools can both help and hurt us.
Being able to generate code snippets, suggest names, even refactor code automatically is powerful.
But when you don't engage with the naming process yourself, you miss out on that crucial clarity step.

And unfortunately, more and more people seem to be skipping that step lately.

You know what I mean--when people just throw prompts at an LLM, get back a chunk of code, copy-paste it, 
and call it done. It works. It looks cool! But they skip the thinking part. No wrestling with the problem. 
No sitting there staring at a function wondering what to call it because you're unsure what you want it to do yet.

That struggle--that moment of "wait, what should I name this?"--that's not a waste of time. 
That's the moment where you're forced to clarify your thinking. To really understand what you're building. 
When you skip that step, when you let the AI name everything for you, 
you're outsourcing your understanding of the problem to it.

I've seen this firsthand. One example was when I was reviewing a take-home test from a candidate. 
The code was clean, it worked, the tests passed. But when we got on the call and I started asking about choices--"Why did you name this function `processData()`? What does it actually do?"--I got this blank look. 
A long pause. 

I can understand if they needed a moment to think. God knows how slow my brain also works sometimes. 
Especially under pressure and lacking caffeine.
But it irked me a lot if they just said "Uh, I don't know, it just felt right?"

They couldn't explain it. Not because they were bad engineers. 
But because they hadn't actually *thought* about it. 
They'd most likely vibed their way through the problem. 
The LLM had named everything, and they'd never stopped to ask if those names made sense.

That's what worries me. Not that AI tools exist--they're useful, they can be powerful. 
But that they let you skip the hard part. The thinking part. The engineering part.
The part where you clarify what you're actually doing.

## Closing Thought

> As names have power, words have power. Words can light fires in the minds of men. Words can wring tears from the hardest hearts. There are seven words that will make a person love you. There are ten words that will break a strong man's will. But a word is nothing but a painting of a fire. A name is the fire itself.
>
> - *The Name of the Wind*

Words are how we think. They're how we communicate. They're how we build shared understanding. 
When we name things poorly, we're not just being imprecise. We're thinking poorly. 
We're failing to share our understanding with others.

So the next time you're about to name something, pause for a moment. Think about the conversation you're having. Think about what matters about this thing. Think about what someone needs to know to understand it correctly.

The name we choose matters more than we think. It's not a technical problem. 
It's a human one. It's an existential one. 
It's our legacy. 

It's our way to say, "We were here."
