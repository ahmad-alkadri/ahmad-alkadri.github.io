---
title: "Saying Goodbye to Heroku"
date: 2022-12-04T18:47:22+02:00
aliases:
    - /2022/12/04/saying-goodbye-to-heroku/
description: On the end of Heroku's free tier and what it means for me.
---

> So long, and thanks for the free Heroku!
>
> -- <cite>not Douglas Adams (maybe)</cite>

I was thinking of writing this post months ago, ever since the [infamous post](https://blog.heroku.com/next-chapter) by Heroku announcing the end of their free-tier plan, but a severe combination of the workplace’s busyness and homebound procrastination between September and November prevented me from doing so. Of course, I could blame nobody because of it. Now, with me finally returning from my vacation (gonna dedicate a full blog post about it later I think), and things cooling down at work (it actually isn’t, but things are much more ordered now with the arrival of new engineers–again, gonna dedicate a post for it later), I finally got the time to end my Heroku apps, migrate most of them, and of course, write this post.

First thing first: I’ve never been a formally trained developer. People at work–colleagues, clients–asked this from time to time, wondering what on earth a guy with a Bachelor of Forestry doing in one of Luxembourg’s [biggest, fastest-growing startups](https://paperjam.lu/article/je-vois-milliard-ici-cinq-ans) as a [Senior Simulation Engineer](https://www.linkedin.com/in/alkadri/).

Long story short: during my Master’s, specifically, during my internship, realizing that it would take forever to digest the experimental data using Microsoft Excel, I started learning to code in R. It was quite big for me because even though I knew some coding (MATLAB, specifically), it was my first foray into a real, legit open-source programming language. To say it was life-changing was an understatement. Within the span of a couple of months, I learned how to automatize data input, storage, query, analysis, and reporting. Not only that, I managed to build simple statistical models that could predict the acoustic properties of wood from its anatomical characteristics. It got published in a [scientific journal](https://brill.com/view/journals/iawa/39/1/article-p63_6.xml). Life was good.

However, if R opened my eyes to the world of automatization, data science, data engineering, and to a certain degree, machine learning, it was Python that brought me fully into the software development realm. After being introduced to it during my Ph.D., I learned how to build apps for the first time. Mostly command line apps, they helped me to check on my experiments, store and query data, analyze, build and rebuild models, simulate physical phenomena, visualize them, and many others. Then I learned how to package those command line apps into one big app with many endpoints–basically building REST APIs–and I learned how to deploy them.

And this was where Heroku came.

Deploying a web app in Heroku is so easy. It felt, in the beginning, like some cheat codes that people have been hiding from me all this time. I spent so much time learning about server, web server, firewall-ing, and dockerization, and you tell me that I can just heroku push and my app would be deployed? And then I could share and use the link with anyone, from anywhere, in the world? For free?? (important part, because as a student, back then, well, money was tight–and probably the same case for many people as well)

Of course, there are a lot of limitations to using free dynos. The app must be awakened first before being used. There are limits to the free hours it can be used. Limitation in memories also. All those things need to be taken into account. Production-wise, it doesn’t make sense to deploy your app to Heroku’s free-tier dynos.

On the other hand, development-wise, it makes so much sense to use free-tier. And, for someone like me, who literally learned how to code and build apps from scratch through people’s blog posts, YouTube, and free ebooks, Heroku feels like a “safe space” where I can test things I’ve learned. I came to like Heroku so much, that I promoted it to be used for production deployments of some apps that I participated in developing at my workplaces.

---

Yesterday, at last, I managed to migrate all of the apps that I’ve deployed at Heroku and dockerized them, and put them, for now, on my personal server at home. Thanks to the projects that I’ve done at work, dockerizing–especially for Flask apps, the framework I’ve been studying and using the most–feels like breathing for me these days. Some Streamlit apps that I’ve made as a hobby, for example, the [tweet cloud maker](https://ahmadalkadri.com/2021/12/26/weekend-project-tweetcloud-maker/), have been redeployed at [Streamlit Cloud](https://tweetcloudmaker.streamlit.app/). You can even use it now–it feels faster than before when it was hosted on Heroku!

I’m currently looking for alternatives to where to deploy the other apps. There are many of them, of course, and one day perhaps I could list them in a separate, dedicated post. Though, to be honest, now having them on my own, personal server, this could probably become a path for me to learn how to do proper deployment on my own. The security part would certainly be the hardest to overcome, but seeing that most of those apps are just, well, hobby apps, I don’t feel there is any rush.

Finally, as so many people have said–even though I mostly use the free-tier Heroku to study, learn, test new things, and share apps with others (mostly friends and close colleagues), its departure really feels like the end of an era. Heroku free-tier has accompanied me throughout the learning phase of my coding life, and I’m very thankful for it. Here’s hoping the next generation of developers–especially the self-taught ones like me–can find a good alternative for their development path!
