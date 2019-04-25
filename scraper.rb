require 'scraperwiki'
require 'nokogiri'
require 'rest-client'

ORG_NAME = 'Business Council of Australia'

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

def save_item(item, type)
  article = {
    'name' => item.at(:title).text,
    'url' => item.at(:link).text,
    'scraped_at' => Time.now.utc.to_s,
    'published_raw' => item.at(:pubDate).text,
    'published' => parse_utc_time_or_nil(item.at(:pubDate).text),
    'author' => item.at(:author)&.text,
    'content' => item.at(:description).text,
    'syndication' => web_archive(item.at(:link).text),
    'org' => ORG_NAME,
    'type' => type
  }
  ScraperWiki.save_sqlite(['url'], article)
end

def save_articles_in_feed(index_page, type)
  items = Nokogiri.parse(index_page.body).search(:item)

  if items.any?
    items.each do |item|
      sleep 1

      item_link = item.at(:link).text
      # Skip if we already have the current version of article
      if (ScraperWiki.select("* FROM data WHERE url='#{item_link}'").last rescue nil)
        puts "Skipping #{item_link}, already saved"
      else
        puts "Saving: #{item_link}"
        save_item(item, type)
      end
    end
  end
end

feeds = [
  ['https://www.bca.com.au/media_releases.rss', 'Media release'],
  ['https://www.bca.com.au/submissions.rss', 'Submission'],
  ['https://www.bca.com.au/transcripts.rss', 'Interview'],
  ['https://www.bca.com.au/speeches.rss', 'Speech'],
  ['https://www.bca.com.au/opinion_articles.rss', 'Opinion piece'],
  ['https://www.bca.com.au/reports_papers.rss', 'Report'],
]

feeds.each do |url, type|
  web_archive(url)
  puts "Collecting items from #{url}"

  save_articles_in_feed(RestClient.get(url), type)
end
