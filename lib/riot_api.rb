require './lib/matcher.rb'

module RiotApi
  class RiotApi < ExternalApi
    include Matcher

    @api_key = ENV['RIOT_API_KEY']
    @api = load_api('riot_api')

    # Limited to 500 requests per 10 seconds, 30000 requests per 10 minutes
    RIOT_API_RATE_LIMIT = 500

    # Default tags to use for requesting champions
    DEFAULT_TAGS = [:allytips, :blurb, :enemytips, :info, :spells, :stats, :tags, :lore]

    # Current season as defined by season indicated in matches API
    ACTIVE_SEASON = 9

    # Matches are based off of Ranked Solo Queue
    RANKED_QUEUE_ID = 420

    # API Error Codes
    RATE_LIMIT_EXCEEDED = 429
    INTERNAL_SERVER_ERROR = 500
    SERVICE_UNAVAILABLE = 503
    BAD_REQUEST = 400
    FORBIDDEN = 403
    ERROR_CODES = [
      RATE_LIMIT_EXCEEDED,
      INTERNAL_SERVER_ERROR,
      SERVICE_UNAVAILABLE,
      BAD_REQUEST,
      FORBIDDEN
    ]

    # Constants related to the Riot Api
    TOP = 'Top'.freeze
    JUNGLE = 'Jungle'.freeze
    SUPPORT = 'Support'.freeze
    ADC = 'ADC'.freeze
    MIDDLE = 'Middle'.freeze
    ROLES = [TOP, JUNGLE, SUPPORT, ADC, MIDDLE]

    REGIONS = %w(br1 eun1 euw1 jp1 kr la1 la2 na1 oc1 ru tr1)

    STATS = {
      armor: 'armor',
      attackdamage: 'attack damage',
      attackrange: 'attack range',
      crit: 'critical chance',
      hp: 'health',
      hpregen: 'health regeneration',
      movespeed: 'movement speed',
      mp: 'mana',
      mpregen: 'mana regeneration',
      spellblock: 'magic resist'
    }.freeze

    class << self
      def get_champions
        args[:tags] ||= DEFAULT_TAGS.map do |tag|
          "&tags=#{tag}"
        end.join('')

        url = replace_url(@api[:champions], args)
        fetch_response(url)
      end

      def get_items
        fetch_response(@api[:items])
      end

      def get_match(args)
        url = replace_url(@api[:match], args)
        fetch_response(url, ERROR_CODES)
      end

      def get_recent_matches(args)
        url = replace_url(@api[:summoner][:recent_matches], args)
        fetch_response(url, ERROR_CODES)
      end

      def get_matchups(args)
        url = replace_url(@api[:summoner][:matchups], args)
        fetch_response(url)
      end

      def get_summoner_queues(args)
        url = replace_url(@api[:summoner][:queues], args)
        return unless queue_stats = fetch_response(url)

        queue_stats.inject({}) do |queues, queue_stat|
          queues.tap do
            queues[queue_stat['queueType']] = queue_stat.slice(
              'leaguePoints', 'wins', 'losses', 'rank', 'hotStreak', 'inactive',
              'tier', 'queueType'
            ).with_indifferent_access
          end
        end
      end

      def get_summoner_id(args)
        name = URI.encode(args[:name])
        url = "#{replace_url(@api[:summoner][:id], args)}/#{name}"
        return unless response = fetch_response(url)
        response['id']
      end
    end
  end
end
