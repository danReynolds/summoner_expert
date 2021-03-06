class DataController < ApplicationController
  def similarity
    champion_ids = Cache.get_collection(:champions).keys
    similarities = champion_ids.inject({}) do |acc, champion_id|
      acc.tap do
        acc[champion_id] = Cache.get_champion_similarity(champion_id)
      end
    end
    render json: {
      data: similarities
    }
  end

  def champions
    render json: {
      data: Cache.get_collection(:champions).inject({}) do |acc, (id, name)|
        acc.tap do
          acc[id] = Cache.get_collection_entry(:champion, name).slice(:name, :key)
        end
      end
    }
  end
end
