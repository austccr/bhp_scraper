require 'scraperwiki'
require 'nokogiri'
require 'rest-client'
require 'json'

ORG_NAME = 'BHP'
BASE_URL = 'https://www.bhp.com'
# TODO:
# Add /media-and-insights/prospects
# Add /media-and-insights/news-releases
# to params
INDEX_URL = 'https://www.bhp.com/api/search/GetSearchResults?searchTerm=&sortByDate=false&path=/media-and-insights/reports-and-presentations&language=en&page='

def web_archive(page_url)
  url = "https://web.archive.org/save/#{page_url}"

  begin
    archive_request_response = RestClient.get(url)

    if archive_request_response.headers[:content_location]
      "https://web.archive.org" + archive_request_response.headers[:content_location]
    else
      URI.extract(archive_request_response.headers[:link]).last
    end
  rescue RestClient::BadGateway => e
    puts "archive.org ping returned error response for #{url}: " + e.to_s
  end
end

def parse_utc_time_or_nil(string)
  Time.parse(string).utc.to_s if string
end

def save_item(item)
  article = {
    'name' => item['title'],
    'url' => BASE_URL + item['url'],
    'scraped_at' => Time.now.utc.to_s,
    'published_raw' => item['dateTime'],
    'published' => parse_utc_time_or_nil(item['dateTime']),
    'author' => nil,
    'content' => nil,
    'summary' => item['description'],
    'syndication' => web_archive(BASE_URL + item['url']),
    'org' => ORG_NAME
  }

  page = Nokogiri.parse(RestClient.get(article['url']))

  unless article['url'] =~ /\.pdf$/
    article['content'] = page.at(:article).inner_html
  end

  ScraperWiki.save_sqlite(['url'], article)
end

def save_articles_in_feed(index_page, current_page)
  data = JSON.parse(index_page.body)

  items = data['searchResults']

  if items.any?
    items.each do |item|
      item_link = BASE_URL + item['url']
      # Skip if we already have the current version of article
      if (ScraperWiki.select("* FROM data WHERE url='#{item_link}'").last rescue nil)
        puts "Skipping #{item_link}, already saved"
      else
        puts "Saving: #{item_link}"
        save_item(item)
        sleep 1
      end
    end
  end

  # if page count x current page is less that total results, get the next page
  unless data['totalSearchCount'] < data['searchCountOnPage'] * current_page
    sleep 1
    next_page = current_page + 1
    save_articles_in_feed(
      RestClient.get(INDEX_URL + next_page.to_s), next_page
    )
  end
end

page_number = 0

save_articles_in_feed(
  RestClient.get(INDEX_URL + page_number.to_s), page_number
)
