# My Blog at Github Pages

There are many reasons for blogging with Github Pages, but number one reason is its simplicity.
I was trying to start blogging again in Wordpress, but the complex nature of its interface
got in the way of me who's just trying to find a simple way to blog. Thus, *here and back again*.

# Development

You're free to clone and try to adapt my blog as a template for your own. Just make sure
you have Hugo installed. See their official website on [how to install](https://gohugo.io/installation/) and
[get started](https://gohugo.io/getting-started/quick-start/) with it.

Once you clone this repository, firstly make sure that the theme submodule is properly updated:

```bash
git submodule update --init --recursive
```

Next, to make a new post, simply use the `hugo new post` command, such as:

```bash
hugo new posts/my-first-post.md
```

And to preview the site:

```bash
hugo serve -D
```

Let me know or raise an issue if you have any question.
