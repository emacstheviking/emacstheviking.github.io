----
title: PHP Screwed Me Again
tags: php, programming, wordpress
----

# PHP Screwed Me Again

<img src="/images/porridge_fletch.jpg" align="left" style="padding: 0 10px 10px 0"/>

I was writing a WordPress plugin this time, and as the venerable
Fletcher might have said, "You wanna stay away from nonces Gobber, bad
news they are."  My code had created a meta-box to allow me to tick /
untick a simple check-box against pages and posts so that I could
restrict content to registered users.

Every time I hit the "update" button I got the lovely little error box
telling me there was a problem saving my post and to try again. Thanks
WP, very helpful.

Anyway, I tracked the problem to a piece of code that I had
transcribed incorrectly from the WP codex page, don't ask me why I
hadn't cut and pasted it directly from the page as I normally do, but
here's what I had and what I should have have had...


<div style="clear:both; padding-left:20px;">
<div class="row">
<div class="col-sm-5">
BAD CODE
```{.php .numberLines}
wp_nonce_field
  plugin_basename(
    __FILE__, 'tnjpay_restricted_nonce'
  ),
);
```
</div>
<div class="col-sm-7">
GOOD CODE
```{.php .numberLines}
wp_nonce_field(
  plugin_basename(__FILE__),
  'tnjpay_restricted_nonce'
);
```
</div>
</div>
</div>

Simple, and subtle, but in the cut-and-thrust I just couldn't see that
one little mistake; that I had accidentally put the nonce identifier
inside the call to `plugin_basename` instead of as the second
parameter to `wp_nonce_field`.

And PHP never said a mumbling word.
	
Thanks PHP.

Admittedly the `wp_nonce_field` takes four parameters and they are all
optional so that function I will forgive, but plugin_basename takes
one and exactly one parameter but because of the incredibly slack (and
useful) way in which PHP lets you pass arguments around, it never
complained. Is there some kind of configuration file setting that
would have moaned at me for having given it too much to eat? That
would have at least saved some head-scratching!

If I was being very strict then I would insist that all functions that
are not variadic should do this as the first line of code inside the
stack frame:
```{.php}
assert(count(func_get_args(), N));
```
It's a shame that PHP doesn't have a pre-processor. I have used m4
with PHP in the past but on production sites not everybody knows how
to use m4 or why it's even useful! Whatever.

I will not make that particular mistake again, at least not today with
the WP API.

