title: "On Spaces in Code"
date: 2026-01-17T01:42:01+09:00
categories: ["Blog", "Coding"]
description: "On the pauses in songs, cities, and code – and why whitespace matters more than we think."
draft: true
---

I think I started really listening to blues during my early years in France.
Still young, still restless, trying to prove that I deserved to be there. Days spent in cramped labs and classrooms, nights stretching a bit too long in winter, headphones on in the small dormitory room.

Man, those old records felt like they were leaking out of a bar somewhere in a city I'd never see. Guitars that didn't rush. Basses that lumbered slowly underneath. A harmonica somewhere in the distance, not always in tune, but honest. The band played like they were tired, but still showed up.

What I liked in those songs wasn't just the melody. It was the **spaces**.

The way the guitar would bend a note and then leave it hanging. The way the drummer would skip a hit and just let the room ring. Whole pockets of air between phrases, as if the music was giving you permission to sit with whatever you were carrying that day.

Those songs didn't feel crowded. They felt lonely, but in a strangely gentle way. Like there was enough room inside them for you to put down your own thoughts for a while, without bumping into anybody else's.

## When Code Has No Place to Breathe

There is a concept in Japanese culture called **Ma (間)**. Roughly translated, it means "gap," "space," or "pause." But it's not just empty void. In music, it's the silence between notes that gives the rhythm its shape. In a Japanese room, it's the empty tatami space that allows the few objects there to exist with dignity.

It is the negative space that defines the positive.

I didn't think much about that when I started writing code professionally. I was more worried about being "good enough". Of "making it work".

So I wrote functions the way I talk when I'm afraid people will stop listening in a scientific conference: quickly, densely, trying to prove that every line matters. No pauses. No breathing room.

At some point during my past couple of years, though, other developers--people from the same team as mine, or from others--started telling me very gently:

> "Your code works, but… it's kind of hard to read."

Or:

> "It feels like it jumps around a lot. I get lost."

That stung more than a crashing service at 3AM caused by me forgetting to invalidate some caches. Because underneath it was a quieter message: *"I can't follow you."* 

And they were right. I wasn't leaving them anywhere to rest. I was playing solos over my own solos.

We talk a lot about syntax, naming, architecture. We rarely talk about the most common line in the entire codebase:

The empty newline.

## The Wall of Text

Code without space is like music without silence. All notes, no rests.

```go
func processUserOrder(u User, items []Item) error {
    if !u.IsActive { return errors.New("inactive user") }
    total := 0.0
    for _, item := range items {
        if item.Stock < 1 { return fmt.Errorf("item %s out of stock", item.ID) }
        total += item.Price
    }
    bill := createBill(u, total)
    if err := saveBill(bill); err != nil { return err }
    emailService.SendReceipt(u, bill)
    return nil
}
```

Technically, this is fine. It compiles. It runs. Everything is there.

But reading it feels like holding your breath. You have to keep the *entire* function in your head at once. There is no place for your eyes to land, no natural stopping point where you can say, "Okay, I understand this part. Next."

It's a monologue delivered without commas.

## Letting the Function Breathe

Now we add a little *Ma*. We don't change any variable names. We don't change the logic. We just change the rhythm.

```go
func processUserOrder(u User, items []Item) error {
    // 1. Validation
    if !u.IsActive {
        return errors.New("inactive user")
    }

    // 2. Calculation
    total := 0.0
    for _, item := range items {
        if item.Stock < 1 {
            return fmt.Errorf("item %s out of stock", item.ID)
        }
        total += item.Price
    }

    // 3. Persistence
    bill := createBill(u, total)
    if err := saveBill(bill); err != nil {
        return err
    }

    // 4. Notification
    emailService.SendReceipt(u, bill)

    return nil
}
```

Same song. Different arrangement.

The whitespace is quietly doing what the drummer does in a slow blues: marking sections, signalling transitions.
It tells the reader:

> "Here we check if the user is allowed. Stop.
>
> Here we figure out the money. Stop.
>
> Here we save. Stop.
>
> Now we notify."

It turns a single block of instructions into four small scenes.

I used to think this kind of formatting was just "style." Nice-to-have. Optional. Something you worry about once the real work is done.

Now I think of it the way I think of those empty bars in a song: **without them, the meaning changes.**

## Whitespace as Rhythm

I've come to believe that **vertical whitespace is part of the language**, just as much as keywords and braces.

When we format code, we're not only making it "pretty". We're deciding how fast someone else is forced to think.

- Tight, compact groups say: "These lines belong together. Read them in one breath."
- A blank line says: "Pause here. Let this settle before you move on."

If you strip out all the pauses, the code might still be correct, but it becomes emotionally exhausting to read. Like a conversation with someone who never lets silence exist because they're terrified of what might surface if the room goes quiet.

The melancholy thing about this is that we usually do it out of fear. Fear of taking up too much space. Fear of looking "wasteful" with lines. Fear that someone will judge our code as too simple if we spread it out.

The truth is: almost nobody will complain that a function was *too easy* to follow.

## Practical Ways to Add Ma

This is the part I wish someone had told me earlier, back when teammates started saying my code was dense and hard to follow.

When you finish writing a function, before you push it, try this:

- **Group by purpose.** Put a blank line between validation, calculation, persistence, and side effects.
- **Separate setup from work.** Declarations and configuration at the top, then a blank line, then the main logic.
- **Give early returns their own space.** Guard clauses at the beginning, then a blank line before the "happy path."
- **Mirror the music.** If a block feels like a verse, give it room. If it's a chorus you'll repeat elsewhere, let it stand on its own.

None of this changes performance. It doesn't impress anyone in a conference talk. But in a quiet, unremarkable afternoon six months from now, someone will open your file and feel a little less tired than they could have been.

In another post, I wrote about [how naming is an existential problem](/posts/a-variable-by-any-other-name/): we don't just write for machines, we write for whoever comes after us, including the future version of ourselves. Spacing is the same conversation, just in a different channel. The blanks between lines are a small act of kindness that says, *"I was thinking of you when I wrote this. I wanted you to understand it without hurting your head."*

Maybe that person will be you.

## Closing

These days, working from home at night in Tokyo, it's often Yorushika in my ears instead of those old blues records. Sometimes Zutomayo. Different instruments, different language, different city--but the same respect for timing. There is always a moment where everything drops out for a breath: the drums soften, the guitar hangs back, the vocals float for a few seconds over almost nothing.

That little gap is where the song finally hits.

I think code can be like that too. 

The logic, the algorithms, the clever tricks--they matter. But the spaces around them decide how it feels to live with that code day after day.

So the next time you send a pull request, before you reach for a new abstraction or a smarter pattern, maybe just do one simple thing:

Press Enter.

Leave a little room for someone else to breathe.
