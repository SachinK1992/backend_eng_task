# frozen_string_literal: true
require 'open-uri'
require 'uri'
require 'nokogiri'
require 'json'

METADATA_HISTORY_FILE = 'metadata_history.json'
VALID_URL_REGEX = /\A((http|https):\/\/)[a-z0-9-]+(\.[a-z0-9-]+)+([\/?].*)?\z/ix

def parse_arguments!(args)
  @urls = []
  @metadata = false

  args.each do |arg|
    if arg == '--metadata'
      @metadata = true
    elsif valid_url?(arg)
      @urls << arg
    else
      raise "Invalid argument: #{arg}"
    end
  end

  raise 'Must pass a url as argument!' if @urls.length.zero?
end

def process!
  @fetch_times = {}

  fetch_urls_and_save_in_parallel

  print_metadata if @metadata

  update_metadata
end

private

def valid_url?(arg)
  arg =~ VALID_URL_REGEX
end

def fetch_urls_and_save_in_parallel
  @urls.map do |url|
    Thread.new { fetch_url_and_save(url) }
  end.each(&:join)
end

def print_metadata
  @urls.each do |url|
    metadata = build_metadata(url)
    metadata.each { |key, value| puts "#{key}: #{value}" }
  end
end

def update_metadata
  metadata_json = last_metadata
  @fetch_times.each do |host, value|
    metadata_json[host] = value
  end
  File.open(METADATA_HISTORY_FILE, 'w').write(metadata_json.to_json)
end

def fetch_url_and_save(url)
  host = URI.parse(url).host
  filename = "#{File.basename(host)}.html"
  site = URI.open(url)
  @fetch_times[host] = { fetch_time: Time.now.strftime('%a %b %d %Y %H:%M %Z') }
  file = File.open(filename, 'w')
  file.write(site.read)
end

def build_metadata(url)
  host = URI.parse(url).host
  prev_time = last_metadata[host] ? last_metadata[host]['fetch_time'] : 'NA'
  filename = "#{File.basename(host)}.html"
  site = Nokogiri::HTML(File.open(filename).read)
  {
    site: host,
    num_links: site.css('a').length,
    images: site.css('img').length,
    last_fetch: prev_time
  }
end

def last_metadata
  @last_metadata ||= begin
    return {} unless File.exist?(METADATA_HISTORY_FILE)

    metadata_history_file = File.open(METADATA_HISTORY_FILE, 'r')
    metadata_raw_json = metadata_history_file.read
    metadata_raw_json == '' ? {} : JSON.parse(metadata_raw_json)
  end
end
