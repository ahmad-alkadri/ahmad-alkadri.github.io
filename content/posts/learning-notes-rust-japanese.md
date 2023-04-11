---
title: "Code and Kanji: Small Notes from Learning Rust and Japanese"
date: 2023-04-10T10:01:10+02:00
category: ["learning notes"]
description: A little blog from my recent efforts learning Rust and Japanese language
hideSummary: false
---

Adulthood really has its way of taking up so much of our waking time, doesn’t it? It feels like it was only yesterday I was upset by [the end of Heroku’s free plan](/posts/saying-goodbye-to-heroku). A blink of an eye and suddenly we’re closer to the end of Spring and the beginning of Summer than we are to the snowy days in Luxembourg.

Time flies.

What happened in the meantime for me was a lot. Work stuff, of course, as usual, doing some design and engineering stuff. On the other hand, there are also my recent adventures in learning new things. A couple of those stood out for me: the first is learning Rust using ChatGPT, and the second is my experience with learning Japanese through mobile apps.

Firstly, let’s talk about ChatGPT. I think by now everybody knows what ChatGPT is. Especially with the latest release of its model, in which it has made some great achievements. I’ll admit that I’m probably among the early users of it, for a lot of reasons, but mostly for helping me code. Sure, some people say that it’s terrible for coding, mostly because there are some mismatches between the versioning of the modules it’s using, and bizarrely it also put out some methods or packages that don’t exist, but I think one of its strongest strengths (at least for me) is for teaching new languages.

And that’s basically the majority of my uses of it. Since December last year, I’ve been using this AI-powered language model to learn several programming languages. One of them, the one I’m focusing on most right now, is Rust.

Rust, as many of you may already know, is a systems programming language that focuses on safety, concurrency, and performance. One of its core features is the ownership system, which ensures memory safety without a garbage collector. This, in turn, leads to more predictable performance and efficient memory management. For example, consider the following code snippet:

```rust
fn main() {
    let s1 = String::from("Hello, world!");
    let s2 = s1;
    println!("{}", s1);
}
```

In this example, Rust’s ownership system prevents the use of s1 after transferring ownership to s2. This eliminates the risk of a double-free error, ensuring memory safety.

Another positive aspect of Rust is its strong community support, which has led to the creation of numerous libraries and frameworks, such as Actix for web development or Tokio for asynchronous runtime. Let me tell you this though; I love how Rust handles its async functionality. Having been working with async-await on mostly JavaScript (Node.js), I’ve been getting such a fresh feeling from Rust. Especially with its great compiler, deploying web apps (backend, APIs, etc.) is really a breeze.

Truly, maybe one day I should write a full blog about the whole async functionalities in Rust. It’s going to take more than one post, though, of that I’m sure.

---

On a different note, I’ve been learning Japanese using mobile apps. I started out with only Duolingo, but these days I’m also advancing with Busuu. I like Duolingo’s casualness and more “fun” vibe, but Busuu’s structure has been particularly rewarding, especially in my efforts to learn the grammar. Really, Japanese is surprisingly a grammar-heavy language, with strong underlining and differences between casual vs formal tones and words.

Also, surprisingly, while kanji is very intimidating, after a while, once you get the hang of basic kanji characters, they’re actually super helpful in understanding sentences and phrases way faster. It’s like having a shortcut when you’re reading, without needing to figure out every single hiragana or katakana character.

Take this sentence: “わたしはほんをよみます” (Watashi wa hon wo yomimasu). Now check it out with kanji: “私は本を読みます.” See how the kanji characters 私 (watashi: I), 本 (hon: book), and 読 (yomi: read) give you the key info you need to understand that the sentence means “I read a book”. Pretty neat!

Here’s another longer one: “かのじょはとうきょうにすんでいます” (Kanojo wa Toukyou ni sunde imasu). With kanji, it becomes “彼女は東京に住んでいます.” The kanji characters 彼女 (kanojo: she), 東京 (Toukyou), and 住 (sumu: lives) help you figure out that the sentence is saying “She lives in Tokyo.” Super handy.

However, while these apps–Busuu, Duolingo, and others–offer a convenient and efficient way to learn the language (I literally learn mostly when on the bus haha), the lack of a conversation partner has proven to be a significant disadvantage. It’s one thing being able to understand texts from manga and novels, or even understanding what is being sung or said in J-Pop songs or J-Drama films, but it’s fully different once I tried to express myself in Japanese. Especially when it starts being a back-and-forth conversation.

For that, I think I definitely need some people I can speak and interact with, every day.

I remember eight, seven years ago, when I arrived in France for my Master’s. Even with B1 certification; ultimately it was by immersing myself in the language and using it daily with native speakers that made me become really fluent. This is why these days I’ve been trying to find a Japanese learning community with whom I can practice and grow together.

---

In conclusion, the past few months have been filled with challenges and growth as I’ve dived into the world of Rust and Japanese. Utilizing tools like ChatGPT and mobile apps has given me the opportunity to expand my skill set, but the importance of direct human interaction in learning is still unmatchable. Going forward I think I’ll start sharing more notes from my efforts in learning, be it Rust or other programming languages or frameworks or Japanese.
