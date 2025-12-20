---
title: "Semantic Density: When Some Languages Feel Heavier than Others"
date: 2025-12-20T23:50:00+09:00
aliases:
    - /2025/12/20/semantic-density-when-some-languages-feel-heavier-than-others/
categories: ["Blog", "Programming", "Coding", "Japan"]
description: "On the visual weight of Japanese language and the verbosity (a.k.a. minimalism) of Go."
cover:
    image: "/img/semantic-saturation-or-languages-that-feel-heavy/drugstore.jpg"
    caption: "Original image by [Ejmin Matevousian](https://unsplash.com/photos/a-person-crosses-the-street-at-night-PIhY_0GF2b4)"
---

There is a specific feeling you get when you walk out of a station in Tokyo at night. Let's say you step out of the West Exit of Shinjuku, or maybe you walked out of the Akihabara station and wander its backstreets. The first thing that hits you isn't the noise; it's the *density*. The sheer amount of information crammed into every square inch of your field of vision.

Vertical signs stack on top of each other like Tetris blocks. Neon lights. Banners flouting sales. And on so many surfaces, Kanji.

To a tourist, this visual landscape is just texture. "Cyberpunk aesthetics," they might say. Noise. But after you've lived here for a while, and after you've started learning the language, the noise transforms into a signal. And it is a *heavy* signal.

A single character like 薬 (medicine) on a sign doesn't just mean "drugstore." In the context of a glowing blue sign at 10 PM, it tells you: *here is cough medicine, here is shampoo, here is cheap chocolate, here is a place with baby products.*

Or take the glowing neon text on a parking lot sign: 空 (Empty). If you are driving car through the crowded streets of Shibuya, trying to find a place to park your car, finding this single character feels like finding an oasis in a desert. It doesn't just mean "space available". It means *you can stop, you can rest, you can turn off the engine*. It screams *availability*.

Then there is the yellow sticker slapped on a bento box at 8 PM: 半額 (Half Price). It's just two characters, but to some people, it triggers something else other than "50% Off". It signals the end of the day, a small victory, a lucky find.

Several strokes of color can convey what would take a full sentence in English. This is what I call **Semantic Density**.

It is the ratio of meaning to ink. It is the measure of how much intent, history, and context is packed into a single symbol. High density means you can convey an entire situation in a single glance--but only if the viewer shares the same context.

This concept doesn't just apply to natural languages. It is the defining characteristic of the programming languages we choose to use.

## The Weight of a Symbol

I experience this contrast daily because I live in two very different linguistic worlds.

In my daily life, I am learning Japanese--a language of extreme semantic density. It is a language where context is everything, where the subject of a sentence is often omitted because *you should just know*, and where a single Kanji can have five different readings depending on what sits next to it.

At the same time, in my coding life, however, I gravitate towards Go.

(Actually scratch that, I *love* Go so much that if I ever being asked to choose between Go and some typical popular frameworks for a backend project no matter the scale, I would always choose Go.)

Here's the thing: Go is, by design, a language of *low* semantic density.

If you look at a Go codebase, you see the same words repeated over and over. `if err != nil`. `return nil, err`. `type struct`. The vocabulary is tiny. 

If you want to map an array (or slice) to a new slice of values, you write a `for` loop. You make the slice yourself. You append the items yourself. We don't even have `try-catch`. When something goes wrong--or even might go wrong--we don't wrap it in a block and hope for the best. We handle it. Manually. Explicitly. Ourselves.

The grammar is simple. There is almost no "magic."

Compare this to a "high density" language like Ruby, or even more so, Julia (which I also love, but for different reasons). In those languages, you might write `map!` or use a broadcasting operator like `.`. You might use a macro that generates fifty lines of code from a single annotation.

In Julia, the `+` operator is an incredibly heavy symbol. [It relies on **Multiple Dispatch**](/posts/multiple-dispatch-in-julia/). When you write `a + b`, the language runtime looks at the types of `a` and `b`, searches through a method table (which might contain hundreds of definitions for `+`), finds the most specific one, and executes it. 

That one little `+` is doing a lot of heavy lifting. It is a Kanji. One character, a dozen specific meanings depending on context.

```julia
# Julia: High Density
# The "+" here isn't just addition. It's a method call that looks up 
# types at runtime, dispatches to a specific implementation, 
# and potentially executes SIMD-optimized assembly.
result = dataset_a + dataset_b 
```

In Go, `+` adds numbers. That's about it. If you want to add two "datasets", you don't overload `+`. You write a loop.

```go
// Go: Low Density
// You want to add two datasets? You build it yourself.
result := make([]Data, len(datasetA))
for i, v := range datasetA {
    result[i] = v.Add(datasetB[i])
}
```

The difference is visceral. One feels like magic; the other feels like carpentry.

## The Paradox of Abstraction

Here is the thing that has been bugging me, the paradox that I've been trying to untangle:

**I love the high density of Japanese.** I love the challenge of it. I love how efficient it is once you know it. I love the feeling of "reading the air" (空気を読む), where communication happens in the silence between words.

**But I often resent high density in code.**

I get annoyed when a framework does too much "magic." I get nervous when I can't see exactly where the data is going. In some languages, I even feel haunted by the simplest assignments: if I write `b = a`, am I creating a fresh copy, or just another pointer to the same memory?

I can ramble on this subject for hours, but in short, I find a comfort in the verbosity of Go, in the "make it yourself" spirit where I have to manually wire up *everything* by my own--and how Go enable me to do that.

Why is that, though?

If I love the richness of high-context culture, why do I crave the bluntness of low-context code?

There are possible ways to explain this, but personally, I think it comes down to the difference between **Ownership** and **Participation**.

## The Maker vs. The Traveler

When I am speaking Japanese, or navigating Tokyo, I am a **Traveler**. 

I am stepping into a system that is infinitely bigger and older than me. I don't need to understand *how* the train system schedules its maintenance windows to appreciate that the train is on time. I don't need to know the etymology of every Kanji to appreciate that a Yorushika song is beautiful. I can listen to [**又三郎**](https://www.youtube.com/watch?v=siNFnlqtd8M) and feel it vibrating my soul without knowing the literary history behind those characters. I accept the "magic" of the culture because I am there to participate in it, not to build it.

But when I am coding, I am a **Maker**.

I am the one responsible for the system. If the building shakes, I'm the one who has to know if the dampeners will hold.

When a programming language offers me high-density abstractions--when it says "Don't worry about the loop, just use this method," or "Don't worry about the database connection, just use this function"--it is asking me to trust it. It is acting like a culture that I'm supposed to just "get."

But unlike a culture, code is something that I have to fix at 1 AM when the pager goes off.

In that moment, **Density becomes Debt.**

Every layer of "magic" I didn't build is a layer of fog I have to peer through. When I see a function call that does ten things implicitly, I have to "translate" it. I have to expand the "Kanji" back into its constituent strokes to understand what's actually happening.

This is the "Decompressor Fatigue."

In Japan, especially in Tokyo, the fatigue comes from constantly translating signs and social cues. In code, it comes from constantly translating abstractions back into reality.

## The "Make it Yourselves" Spirit

There is a philosophy in the Go community that often gets criticized as "boilerplate." It's the refusal to add generics for a long time, the refusal to add map/filter/reduce, the insistence on explicit error handling.

It's the "Make It Yourself" spirit.

Critics say it's primitive. They say it wastes time.

But I think there is a profound honesty in it. It feels like carpentry with hand tools rather than a CNC machine. As someone who worked with woodworking long time ago, I have developed biases, and I find it fulfilling to feel the wood grain, to see the knots, to know exactly parts I should avoid to use, to know which part I should cut, to know which part I should sand, to know which part I should varnish, to see them directly with my eye.

When you write a loop yourself, you own the loop. You know exactly when it allocates memory. You know exactly when it breaks. The code is "light" because the meaning is spread out on the surface, visible to the naked eye. There is no hidden Kanji meaning that you need 10 years of study to intuitively grasp.

And because you build it yourself, you have to name it yourself. You can't rely on a framework's standardized conventions like `AbstractFactoryBean` or `from abc import ABC`. You have to look at the variable, at the method, at the class, and ask: *what are you?* [You have to give it a name that matters](/posts/a-variable-by-any-other-name/), a name that clarifies your own thinking, a name that will be communicated to others in the future. And in that act of naming, you stop being a passenger and start being the driver.

## Finding the Balance

Does this mean I think we should all code in Go? Or C? (I love C.) Or maybe just make it even more explicit by writing Assembly?
 
The answer is no. I still use Julia for complex math because, in that domain, density is necessary. The math *is* dense; the code should match it.

And sometimes, high density is exactly what we need for other reasons. We don't always have the luxury to build from scratch. In a fast-paced environment, we *need* the magic. We grant the framework our trust so we can focus on the product.

However, we must be honest about the trade. [There is no free lunch in engineering](/posts/there-is-no-philosophers-stone/). When we choose high-density abstractions--when we import that "do-everything" package--we are buying speed, but paying with control. We are trading the visible "wood grain" of our code for a sleek, black box we cannot open.

The danger lies in *unnecessary* weight.

We often confuse "elegance" with "compression." We write clever one-liners, powerful macros, opaque abstractions. We try to turn our simple Alphabet into complex Kanji, forgetting that every layer of density taxes the reader's mind. We demand they memorize our dialect, our history, our context.

Sometimes, that tax is worth paying.

But when you are building a system that needs to last--not a script, but a *foundation*, something that will still be used in 5, 10, 20 years in the future--the kindest thing you can do for the future is to stop trying to be clever.

Let the space be empty. Let the letters be just letters.

Build a system where the silence isn't heavy with unspoken rules, but is simply... quiet.

Build code that doesn't ask you to "read the air," but simply asks you to read the code.
