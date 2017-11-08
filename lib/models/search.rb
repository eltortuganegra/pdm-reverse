class Search < ActiveRecord::Base

  def self.get_query_with_older_last_search
    search = Search.order(last_search_at: :asc).first
  end

end