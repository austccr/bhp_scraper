# Archive of Business Council of Australia web posts

These publications are important documents of the public record and should be archived for future analysis.

For each item published in the BCA's RSS feeds, this scraper collects:

* title as `name`
* web address as `url`
* date and time it was collected in UTC, as `scraped_at`
* date and time published in UTC, as `published`
* the listed author as `author`
* main body html as `content`
* another place where this article is available, archive.org for example, as `syndication`
* the name of the organisation publishing as `org`
* the type of item as `type`, e.g. 'Media release' or 'Submission'

These attribute names are loosely based on [the Microformat
h-entry](http://microformats.org/wiki/h-entry) and [h-card](http://microformats.org/wiki/h-card) for `org`.

This scraper runs on the magnificent [morph.io](https:/morph.io).
