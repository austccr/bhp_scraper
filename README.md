# Archive of BPH Reports and presentation posts

These publications are important documents of the public record and should be archived for future analysis.

For each item published in the BHP's feed of posts at `https://www.bhp.com/media-and-insights/reports-and-presentations/`, this scraper collects:

* title as `name`
* web address as `url`
* date and time it was collected in UTC, as `scraped_at`
* date and time published in UTC, as `published`
* main body html as `content`
* description as `summary`
* another place where this article is available, archive.org for example, as `syndication`
* the name of the organisation publishing as `org`

These attribute names are loosely based on [the Microformat
h-entry](http://microformats.org/wiki/h-entry) and [h-card](http://microformats.org/wiki/h-card) for `org`.

This scraper runs on the magnificent [morph.io](https:/morph.io).
