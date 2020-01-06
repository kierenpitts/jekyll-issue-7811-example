# UPDATE - read first!

It turns out that this was **not** a bug related to issue [#7811](https://github.com/jekyll/jekyll/issues/7811).

The problem turned out to be the fact that the two subclasses did not set a `relative_path`. Jekyll 4's Liquid cache uses the `relative_path` (the path to the content source file on the file system) as the key in the cache. As this plugin generates pages that do not have a corresponding file on the file system I did not set a `relative_path` and this defaults to an empty string. As a result, the key for the `NewsListingsPage` matched the entry in the cache that was created when pages of the `NewsItemPage` subclass were created. Consequently the original Liquid layout from the cache was used instead.

The current code in this **example** addresses this by explicitly setting a `relative_path` in each subclass so that the key clash does not occur. The code in its original form can be found using the tag: `pre-fix`

Many thanks to [@ashmaroli](https://github.com/ashmaroli) for help with this issue and for making suggestions on how to improve the plugin code - for example, this plugin could be improved by caching the layout as a class constant and not reading it each time.

The code in this repository was just an example and should not be used but the cache discussion and solution to the problem *may* help others.


# Original README text - Possible Jekyll bug related to #7811

This is an example Jekyll site to help investigate a bug that is possibly related to issue [#7811](https://github.com/jekyll/jekyll/issues/7811)

When the Jekyll site is created the page at /news/browse.html should list the months that have news items. In this example site it should just list December 2019 and January 2020 in a bulleted list. These items should then link through to the month listings - one page each for for December 2019 and January 2020 (these in turn have links to the individual news posts).

The /news/browse.html page and the two month pages (/news/122019.html and /news/012020.html) are generated by a custom plugin: _plugins/news-month-listings.rb

However, the /news/browse.html page is created using an incorrect _layout by the custom plugin. Instead of using _layouts/news_browse.html as specified in the custom plugin it's using _layouts/news_by_month.html

Further information can be found on the root index.html page of the generated site.
