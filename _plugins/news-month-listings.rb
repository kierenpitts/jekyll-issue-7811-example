module Jekyll
  class NewsItemsListings < Jekyll::Generator
    safe true

    def generate(site)
      @site = site
      # Filter by News category
      @posts = site.categories['news']

      @archives = []
      @post_listings = {}
      @good_date = {}
      @news_pages = []

      # Process all the dates and assign posts to years/months
      read_dates

      # Loop through each key in post_listings
      @archives.each do |monthyear|
        monthposts = @post_listings[monthyear]
        nice_date = monthposts[0][0].data["date"].strftime("%B %Y")
        @good_date[monthyear] = nice_date
        outfile = '/news/' + monthyear.to_s + '.html'
        @news_pages << NewsItemPage.new(@site, outfile, nice_date, monthposts)
      end

      # Create overall listings page (/news.browse.html)
      @news_pages << NewsListingsPage.new(@site, @good_date)

      @site.pages.concat(@news_pages)
    end

    def read_dates
      """
      Read the dates of the posts and assign them to a month/year combination
      """
      years.each do |year, posts|
        months(posts).each do |month, posts|
          monthyear = month.to_s + year.to_s
          @archives << monthyear

          # Assign posts to the monthyear key
          if @post_listings.key?(monthyear)
            @post_listings[monthyear] << posts
          else
            @post_listings[monthyear] = [posts]
          end
        end
      end
    end

    def years
      # Loop through years
      # https://github.com/jekyll/jekyll-archives/blob/master/lib/jekyll-archives.rb
      hash = Hash.new { |h, key| h[key] = [] }
      @posts.each { |p| hash[p.date.strftime("%Y")] << p }
      hash.each_value { |posts| posts.sort!.reverse! }
      hash
    end

    def months(year_posts)
      # Loop through months
      # https://github.com/jekyll/jekyll-archives/blob/master/lib/jekyll-archives.rb
      hash = Hash.new { |h, key| h[key] = [] }
      year_posts.each { |p| hash[p.date.strftime("%m")] << p }
      hash.each_value { |posts| posts.sort!.reverse! }
      hash
    end
  end

  class NewsItemPage < Page
    def initialize(site, outfile, listingdate, monthposts)
      """
      Create an individual page for each month of news
      """
      @site = site
      @outfile  = outfile

      self.process(@outfile)
      self.read_yaml(File.join(@site.source, '_layouts'), 'news_by_month.html')
      self.data['title'] = listingdate + " news archive"
      self.data['monthdate'] = listingdate
      self.data['monthposts'] =  monthposts[0]
    end
  end

  class NewsListingsPage < Page
    def initialize(site, nice_dates)
      """
      Create a page containing a list of months for which there are news items
      """
      @site = site
      @nice_dates = nice_dates

      self.process('/news/browse.html')
      self.read_yaml(File.join(@site.source, '_layouts'), 'news_browse.html')
      self.data['title'] = "Browse news archive"
      self.data['monthlist'] = nice_dates
    end
  end
end
