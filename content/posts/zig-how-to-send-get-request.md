---
title: "Learning Zig: How to Send GET Request and Parse the JSON Response"
date: 2026-01-17T18:48:18+09:00
aliases:
    - /2026/01/17/zig-how-to-send-get-request-and-parse-json
categories: ["Blog", "Programming", "Coding", "Zig"]
description: "A self-note, honestly, that I believe I'll revisit quite often"
cover:
    image: "/img/zig-how-to-send-get-request-and-parse-json/stay-with-me-ditto.jpg"
    caption: "Ditto!"
---

I started learning Zig recently.

I've heard of Zig before. It's been showing up a lot in developer forums as "The Modern Replacement of C!"

I know, I know—eyeroll.

I also know `bun` of course; I've used it before, but it wasn't until I read about [Anthropic acquiring it in December](https://www.anthropic.com/news/anthropic-acquires-bun-as-claude-code-reaches-usd1b-milestone) that it really piqued my interest to find out more about it. 

So I did the usual: went to the official `bun` repo,
cloned it, started looking at it locally,
and fell down the rabbit hole:
"Wait, this thing is written mostly in Zig?"

## When the learning started

Zig looked oddly familiar. It reminded me of Go and C at the same time:
a small, opinionated standard library, easy cross-platform binaries, 
and just enough low‑level control to feel a bit nostalgic. It felt like opening an
old C book again, except the tools, compiler, and even the language itself 
are actually trying to help me this time.

So naturally, the first thing I wanted to do was send a simple GET request.

How hard could it be, right?

Turns out: *a little bit* harder than I expected.

---

## When docs, LLMs, and versions don't line up

The first surprise was how sparse the documentation felt.

Zig does have docs, but compared to languages that have been around for decades (Python, Go, etc.), 
it felt like there were more gaps. Many examples I found were either out of date or relied on older
APIs that no longer exist.

LLMs didn't help much either. I tried asking them for "Zig http client
example" and got back some code that were:

- seemingly based on an older Zig version,
- or used types that had moved,
- or just confidently referenced functions that didn't exist anymore.

Typical, right?

On my Fedora Linux machine, I'm currently on Zig **0.15.2**. That is the key detail: a lot
of answers out there are for older versions, and the standard library API
changed a bit over time.

After enough trial and error, many `zig build run` failures, and a few
"wait, why is this type not here anymore" moments, I finally found a
small, consistent snippet that:

- makes an HTTP GET request,
- reads the entire response body into memory,
- parses the JSON into a struct,
- and lets me print out some of the fields.

This post is mostly a note to my future self so I don't forget how I set this
up. If it helps someone else who's running Zig 0.15.2 and just wants a
working example, even better.

I originally used the GitHub API, but the unauthenticated requests-per-hour limit
(which is apparently inconsistent--some people say it's 60 rph, but I got
rate-limited far, far below that!) made testing annoying. 
I switched to the PokeAPI instead: it's public, has simple JSON, and
doesn't require tokens. So far, I haven't hit any rate limits either. (Thank you PokeAPI!!)

---

## Creating the project

I'll start from the very beginning here. Feel free to skip this section if
you already have a Zig project and just want the HTTP bits.

In an empty folder somewhere:

```bash
mkdir zig-pokeapi-client
cd zig-pokeapi-client
zig init
```

That command creates a small Zig executable project with a `src/main.zig`
file and a build script. You can try building and running it right away:

```bash
zig build run
```

You should see this:

```bash
All your codebase are belong to us.
Run `zig build test` to run the tests.
```

Once it works, open `src/main.zig` and replace the contents with something minimal
just to be sure everything is wired correctly:

```zig
const std = @import("std");

pub fn main() !void {
    std.debug.print("Hello from Zig!\n", .{});
}
```

Run it again:

```bash
zig build run
```

If that prints `Hello from Zig!`, we're ready to start gradually turning
this into an HTTP client.

---

## Setting up memory and the HTTP client

The thing that tripped me up the most in the beginning wasn't HTTP itself,
but memory management.

An honest admission: it's been a long, long time since I used C in production.
A long time since I had to build stuff with manual memory management.

Coming from Go, Python, and C# .NET, when I started learning Zig, I realized that
I've been quite spoiled by garbage collectors. Even with Rust, I mostly never have
to manage memory myself. I'm used to not thinking about allocators explicitly. In
Zig, you do. At first it felt annoying, but after a while it became kind of
refreshing. Nostalgic, even. You can see exactly *who* allocates *what*,
and *when* it gets freed.

For this program, I chose the general-purpose allocator:

- it's flexible enough for variable‑sized HTTP responses,
- performance is not critical here,
- and I mostly care about not leaking memory and not crashing.

Once you have an allocator, you hand it to the HTTP client and anything
else that needs to reserve memory. That includes the response body buffer
and the JSON parser.

The rough flow looks like this:

1. Create a general‑purpose allocator.
2. Create an `std.http.Client` with that allocator.
3. Create a writer that will grow as the response body comes in.
4. Tell the client to `fetch` the URL and stream the body into that
    writer.
5. Once the fetch is done, grab the full body as a slice of bytes.

After that, it's "just" JSON.

Let's translate that into code gradually.

First, we add the allocator to our `main` function. 
For this small example I picked `std.heap.GeneralPurposeAllocator`.
It's not a magical grow-forever pool, but it is a good default when:

- you have a mix of allocations with unknown sizes/lifetimes,
- you just want something safe and convenient,
- and performance tuning is not the main goal yet.

The actual "growing" in this program is done by the writer that uses the
allocator under the hood; the allocator itself just serves whatever
allocation and reallocation requests it gets and returns memory when we
`deinit` things.

```zig
const std = @import("std");

pub fn main() !void {
    // 1. Setup Allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    _ = allocator; // Temporary

    std.debug.print("Allocator ready!\n", .{});
}
```

If you run `zig build run` now, it should just print `Allocator ready!`.
Nothing interesting yet, but we know the allocator is in place and will be
cleaned up at the end of `main`.

Next, we attach an HTTP client to that allocator:

```zig
const std = @import("std");

pub fn main() !void {
    // 1. Setup Allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 2. Setup Client
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    std.debug.print("Client ready!\n", .{});
}
```

Again, still no network call, but now we have:

- an allocator,
- an HTTP client tied to that allocator,
- and both are properly cleaned up at the end of the function.

The last piece on the "plumbing" side is a buffer where we can store the
response body.

```zig
const std = @import("std");

pub fn main() !void {
    // 1. Setup Allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 2. Setup Client
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    // 3. Prepare result buffer
    var result_body = std.io.Writer.Allocating.init(allocator);
    defer result_body.deinit();

    std.debug.print("Plumbing ready!\n", .{});
}
```

If this still builds and runs, we are ready to actually hit the PokeAPI
in the next step.

---

## Describing the JSON we expect

The PokeAPI returns a fairly big JSON object for a Pokémon. We don't need
everything. In Zig, instead of parsing the whole thing into some generic
map, we can describe just the fields we care about in a struct.

Here's the struct I used for a Pokémon entry:

- `name`,
- `id`,
- `base_experience`,
- `height`,
- `weight`,
- `order`.

One nice thing in Zig's JSON: you can ask it to ignore unknown
fields. So even if the API adds more keys in the future, the program keeps
working as long as the fields we care about are still there.

Once we have the response body as `[]u8`, we pass it to
`std.json.parseFromSlice`, telling it to parse into `Pokemon` and to
ignore whatever else it sees.

At the end, we get a typed value with proper fields we can print.

Let's drop that struct and a placeholder variable near the top of our
`main.zig` file so the compiler knows about it:

```zig
const std = @import("std");

const Pokemon = struct {
    name: []const u8,
    id: u32,
    base_experience: u32,
    height: u32,
    weight: u32,
    order: u32,
};

pub fn main() !void {
    // allocator + client + result_body from previous section...
}
```

Now we can finally connect everything: perform the HTTP GET request, grab
the body, parse it into `Pokemon`, and print something.

Continuing from the previous `main` body:

```zig
    const headers = &[_]std.http.Header{
        .{ .name = "Accept", .value = "application/json" },
    };

    // 4. Perform the Fetch
    _ = try client.fetch(.{
        .location = .{ .url = "https://pokeapi.co/api/v2/pokemon/ditto" },
        .method = .GET,
        .extra_headers = headers,
        .response_writer = &result_body.writer,
    });

    // 5. Access the result
    const body_slice = result_body.written();

    const parsed = try std.json.parseFromSlice(Pokemon, allocator, body_slice, .{
        .ignore_unknown_fields = true,
    });
    defer parsed.deinit();

    const pokemonData = parsed.value;

    std.debug.print("Body length: {d}\n", .{body_slice.len});
    std.debug.print("Pokémon: {s}\n", .{pokemonData.name});
    std.debug.print("Height: {d}, Weight: {d}, Base XP: {d}\n", .{
        pokemonData.height,
        pokemonData.weight,
        pokemonData.base_experience,
    });
```

At this point, your `src/main.zig` should look very close to the final
version below.

---

## Final Code

```zig
const std = @import("std");

const Pokemon = struct {
    name: []const u8,
    id: u32,
    base_experience: u32,
    height: u32,
    weight: u32,
    order: u32,
};

pub fn main() !void {
    // 1. Setup Allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 2. Setup Client
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    // 3. Prepare result buffer (ArrayList)
    var result_body = std.io.Writer.Allocating.init(allocator);
    defer result_body.deinit();

    const headers = &[_]std.http.Header{
        .{ .name = "Accept", .value = "application/json" },
    };

    // 4. Perform the Fetch
    _ = try client.fetch(.{
        .location = .{ .url = "https://pokeapi.co/api/v2/pokemon/ditto" },
        .method = .GET,
        .extra_headers = headers,
        .response_writer = &result_body.writer,
    });

    // 5. Access the result
    const body_slice = result_body.written();

    const parsed = try std.json.parseFromSlice(Pokemon, allocator, body_slice, .{
        .ignore_unknown_fields = true,
    });
    defer parsed.deinit();

    const pokemonData = parsed.value;

    std.debug.print("Body length: {d}\n", .{body_slice.len});
    std.debug.print("Pokémon: {s}\n", .{pokemonData.name});
    std.debug.print("Height: {d}, Weight: {d}, Base XP: {d}\n", .{
        pokemonData.height,
        pokemonData.weight,
        pokemonData.base_experience,
    });
}
```

If we run it, it'll show:

```bash
Body length: 24909
Pokémon: ditto
Height: 3, Weight: 40, Base XP: 101
```

That's it!

## Closing

What I like about Zig so far is that it doesn't try to hide too much from
you. You see the allocator, you see the client, you see where the bytes go,
you see where they get turned into structured data. It feels very similar
to the things I enjoyed in C and Go.

Again, though, I'll probably forget these exact calls in a few months, 
so this post is mainly a bookmark for myself.

For now, this PokeAPI request is enough to keep me exploring.
If you know of good Zig HTTP or networking resources (especially ones that work
well with 0.15.2), please share them in the comments below or reach out to me on LinkedIn!

Thanks for reading!
