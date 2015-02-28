#!/usr/bin/env ruby

require 'net/http'
require 'nokogiri'
require 'yaml'

def usage
    puts 'jvc <command> <forum>'
    exit
end

def is_number(num)
    begin
        !!Integer(num)
    rescue ArgumentError,TypeError
        false
    end
end

def help_topic
    puts 'jvc topic <forum_id> <topic_id>'
    puts 'or jvc topic <forum_id> <topic_id> <page_number>'
end

def help_forum
    puts 'jvc forum <forum_id>'
    exit
end

def help_search
    puts 'jvc search <keyword>'
    exit
end

def help_alias
    puts 'jvc alias <keyword> <forum_id>'
    exit
end

def help_name
    puts 'jvc name <forum_id>'
    exit
end

def search(keyword)
    str = download 'http://ws.jeuxvideo.com/search_forums/' << keyword

    if $config.has_key? keyword
        puts keyword + '|' + $config[keyword].to_s
    else
        xml = Nokogiri::XML str
        xml.xpath('//forum').each do |forum|
            name = forum.children.css('nom').text
            id = forum.children.css('id').text
            puts name << '|' << id
        end
    end
end

def def_alias(list,keyword,id)
    $config[list][keyword] = id
    File.write('data.yml',YAML.dump($config))
end

def download(url)
    uri = URI url
    req = Net::HTTP::Get.new uri
    req.basic_auth 'app_and_gnw','FC?4554?'
    res = Net::HTTP.start(uri.hostname,uri.port) {|http|
        http.request(req)
    }
    return res.body
end

def forum_name(fid)
    str = download 'http://ws.jeuxvideo.com/forums/0-' + fid.to_s + '-0-1-0-1-0-0.xml'
    xml = Nokogiri::XML str
    return xml.xpath('//nom_forum').first.text
end

def name_or_id(list,id)
    if is_number id
        return id
    else
        if $config[list].has_key? id
            return $config[list][id]
        else 
            return $config[list]['default']
        end
    end
end

def topic_list(fid)
    str = download 'http://ws.jeuxvideo.com/forums/0-' + fid.to_s + '-0-1-0-1-0-0.xml'
    xml = Nokogiri::XML str
    topics = []
    authors = []
    ids = []
    xml.xpath('//topic/auteur').each do |author|
        authors.push author
    end
    xml.xpath('//topic/titre').each do |title|
        topics.push title
    end
    xml.xpath('//topic/lien_topic').each do |link|
        id = /^jv\:\/\/forums\/1-\d+-(\d+)-1-0-1-0-0.xml$/.match(link)[1]
        ids.push id
    end
    if topics.length != authors.length 
        topic_list fid 
    else
        topics.zip(authors,ids).each do |arr|
            puts arr.join "|"
        end
    end
end

def read_topic(fid,tid,page)
    str = download 'http://ws.jeuxvideo.com/forums/1-' + fid.to_s + '-' + tid.to_s + '-' + page + '-0-1-0-0.xml'
    xml = Nokogiri::XML str
    html = Nokogiri::HTML xml.xpath('//contenu').first.text
    html.css('ul.m1,ul.m2').each do |msg|
        author = msg.children.css('a.pseudo > text()').text.strip
        text = msg.children.css('p.message').text.gsub!("\n"," ")
        puts author + ":" + text 
    end

end

def last_page(fid,tid)
    str = download 'http://ws.jeuxvideo.com/forums/1-' + fid.to_s + '-' + tid.to_s + '-1-0-1-0-0.xml'
    xml = Nokogiri::XML str
    return xml.xpath('//count_page').first.text
end


if ARGV.length < 2; usage end
$config = YAML.load_file('data.yml')
case ARGV[0]
when 'forum'
    topic_list name_or_id 'forums',ARGV[1]
when 'name'
    puts forum_name ARGV[1]
when 'search'
    search fid
when 'alias'
    if ARGV.length >= 4
        if ARGV[1] == 'topics' || ARGV[1] == 'forums'
            def_alias ARGV[1],ARGV[2],ARGV[3]
        else help_alias
        end
    else help_alias
    end
when 'topic'
    if ARGV.length >= 3
        fid = name_or_id 'forums',ARGV[1]
        tid = name_or_id 'topics',ARGV[2]
        read_topic fid,tid,last_page(fid,tid)
    else help_topic
    end
else usage
end
