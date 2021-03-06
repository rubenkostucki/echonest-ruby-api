require "rubygems"
require "bundler/setup"
require_relative 'base'
require_relative 'blog'
require_relative 'biography'
require_relative 'foreign_id'

module Echonest

  class Artist < Echonest::Base

    attr_accessor :id, :name, :foreign_ids

    def initialize(api_key, name = nil, foreign_ids = nil)
      @name = name
      @api_key = api_key
      @foreign_ids = ForeignId.parse_array(foreign_ids) if foreign_ids
    end

    def biographies(options = { results: 1 })
      response = get_response(results: options[:results], name: @name)

      response[:biographies].collect do |b|
        Biography.new(text: b[:text], site: b[:site], url: b[:url])
      end
    end

    def blogs(options = { results: 1 })
      response = get_response(results: options[:results], name: @name)

      response[:blogs].collect do |b|
        Blog.new(name: b[:name], site: b[:site], url: b[:url])
      end
    end

    def familiarity
      response = get_response(name: @name)
      response[entity_name.to_sym][__method__.to_sym]
    end

    def hotttnesss
      response = get_response(name: @name)
      response[entity_name.to_sym][__method__.to_sym]
    end

    def images
      response = get_response(name: @name)
      images = []
      response[:images].each do |i|
        images << i[:url]
      end
      images
    end

    def list_genres
      get_response[:genres]
    end

    def search(options = {})
      options = {name: @name}.merge(options)
      artists = []
      get_response(options)[:artists].each do |a|
        artists << Artist.new(@api_key, a[:name], a[:foreign_ids])
      end
      artists
    end

    def songs
      songs = []
      get_response(name: @name)[:songs].each do |s|
        songs << { s[:id] => s[:title] }
      end
      songs
    end

  end
end
