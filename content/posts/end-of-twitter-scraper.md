---
title: "So long, and thanks for all the tweets"
date: 2023-07-01T22:23:47+02:00
category: ["blog", "tech"]
description: As of yesterday, and confirmed by Elon Musk himself (kinda), Twitter requires people to be signed in to see tweets, even public ones. End of an era.
---

Yesterday, someone informed me that my Tweet Cloud Maker hadn't been working well for the entire morning until it finally stopped altogether -- it just returned warnings of empty results. At first, this was not surprising to me. I had just finished working on [fixing and rewriting](/posts/fixing-twitter-scrapers/) the backend tweet scraper a couple of weeks back, and I figured it would be just one of those bugs that I would need to fix.

| ![](/assets/img/end-of-twitter-scrapers/ss_0.png) |
| --- |
| *Screenshot of the app when I checked it* |

After almost an hour of debugging and no result, I finally turned to my most trusted aide: Google.
Almost immediately, I got the answer to my question: [Twitter now requires an account to view tweets](https://techcrunch.com/2023/06/30/twitter-now-requires-an-account-to-view-tweets/).

| ![](/assets/img/end-of-twitter-scrapers/ss_1.png) |
| --- |
| *Screenshot from the article* |

After reading the article, I immediately turned to my next most trusted source of news: Twitter itself. Indeed, users have apparently noticed and have been complaining about the changes. Now, everyone has to be registered and logged in to view tweets, even from public Twitter users. But what about the Twitter API, especially v1.1?

Well, I launched my Postman almost immediately to check, expecting at least some success. I assumed they would warn everyone before doing something as impactful as revoking one of the most crucial functionalities of their publicly available API, right? Something as disruptive as this?

I was mistaken. The API v1.1 no longer works for scraping tweets.

| ![](/assets/img/end-of-twitter-scrapers/ss_2.png) | 
| --- |
| *Screenshot of the API call to get the guest token* |

| ![](/assets/img/end-of-twitter-scrapers/ss_3.png) |
| --- |
| *Screenshot of the API call to get the tweets* |

These are truly worldwide changes. They effectively end all Twitter scrapers, even those that have been in use for a long time by many people, like [Nitter](https://github.com/zedeus/nitter/). And yes, the developers of Nitter have realized this too--[the repo has been alight with discussions](https://github.com/zedeus/nitter/issues/919).

Today, Musk finally confirmed the changes that have occurred via Twitter. Well, sort of, because he didn't directly address it; rather, he mentioned something that I think is even worse: all accounts on Twitter are now rate-limited. The newly unverified accounts can only read 300 tweets per day, old unverified accounts can read up to 600 tweets per day, and finally, verified accounts can read up to 6000 tweets per day.

| ![](/assets/img/end-of-twitter-scrapers/ss_4.png) |
| --- |
| *Mind you, to get yourself verified on Twitter, you'll have to pay.* |

Musk is saying that these changes are being implemented to address "extreme levels of data scraping & system manipulation", but honestly, I'm not buying it. Data scraping is practically unavoidable on the open internet; everyone from search engines to hobbyists (like myself) and even government agencies are doing it. There are ways to handle it, to prevent it from overburdening your system. IP limiters, device detection... seriously, you can even implement it easily in your app with [Flask-Limiter](https://flask-limiter.readthedocs.io/en/stable/). I don't see how a company as big as Twitter cannot implement one of these alternative solutions, anything other than what they're doing right now...

Anyway, Musk has gone on to say that these changes are probably "temporary". Well, I don't know if they're going to be temporary or not. I can't really trust the words of "higher-ups" these days, but for now, I've decided to put Tweet Cloud Maker to sleep and put my work on [pytterrator](https://github.com/ahmad-alkadri/pytterrator) on pause. With Nitter also not functioning, I can only say:

> *So long, and thanks for all the tweets*

