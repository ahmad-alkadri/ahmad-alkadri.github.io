---
title: "Fixing My Twitter Scrapers and Getting New Hobby?"
date: 2023-06-16T23:17:14+02:00
draft: true
category: ["blog", "coding", "personal project"]
description: Or how I finally decided to stop procrastinating and just simply wrote my own Python module to scrape tweets and use it for another personal projet of mine.
hideSummary: false
---

Weekend, finally! Past weeks have been so intense both at work at home. It feels good being able to finally breathe a little bit. I hope everybody who's reading this are having great time!

Speaking of great time, honestly, there used to be such time period in my life where weekends mean full days on the road, traveling, visiting quiet picturesque villages in Southern France with my wife. Or perhaps go to a bookstore to find some new Murakami books. Or maybe visit that café that looks so cozy, enjoying matcha or a bit of Boba tea.

Well, those days are gone. Lately weekends are filled more with staying at home, resting ourselves after full week of work, watching TV, and maybe reading a little bit. Basically cozying up. Some friends told me it's called "getting old", and at this point, maybe I should be agreeing with him.

On the other hand, I also picked up a new hobby since couple months ago. That is learning game development. It's still a bit too early for me to show anything, I've been doing basically nothing except following a lot of tutorials on YouTube to get hands-on learning (note: if you're learning Pygame and looking for some excellent tutorials, I would recommend this channel called [Clear Code](https://www.youtube.com/@ClearCode) wholeheartedly. Hands down the best Pygame tutorials I've ever seen. Practically teaching me about game dev workflow from zero). Nevertheless, I really aim to create my own game one day--maybe I should blog about it more later.

Anyway, this blog shouldn't be about my painful but so far satisfying process of learning game. Not really. What happened was that while I was tidying up my github repo a little bit (so many abandoned weekend projects, *gosh*), I suddenly found my old Tweet Cloud Maker repo again. It was archived, and I remember that it was archived because, after some changes in Twitter API (I believe it was some time early this year), the `snscrape` module--the primary module that I used to scrape tweets from Twitter--stopped working for me. 

I remember myself not having too much time back then, and decided to take it down, promising myself to fix it one day.

Well I unarchived the repo and started working on it again. Immediately, I still found myself having the primary module not working for me. I opened up their repo, browsing for their Issues and started reading, and basically got stopped at the following phrase on their [README](https://github.com/JustAnotherArchivist/snscrape/blob/master/README.md):

> It is also possible to use snscrape as a library in Python, but this is currently undocumented.

That was kind of unfortunate. I was thinking of probably being a contributor to the repo, study it and write some documentations while trying to find out the issue for me, when I realized that it would take a bit more time and that it'd probably be faster for me to write a simple module for scraping tweets myself.

## Enter the `pytterrator`

