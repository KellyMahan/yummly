# This class is the primary mechanism to execute Yummly API calls.
#
# Currently Yummly only has two public API calls: one for searching recipes and the other to retrieve a specific recipe.
#
# @example
#   Yummly::Api.find('French-Onion-Soup-The-Pioneer-Woman-Cooks-_-Ree-Drummond-41364')
# @example
#   Yummly::Api.search('Onion soup')

module Yummly
  class Api

    # Retrieves a single recipe.
    #
    # @param [String] id The yummly recipe identifier.
    # @return [Yummly::Recipe] a instance of a recipe object
    # @example
    #   recipe = Yummly::Api.find('French-Onion-Soup-The-Pioneer-Woman-Cooks-_-Ree-Drummond-41364')
    def self.find(id)
      begin
        recipe_json = Yummly::Connection.get("recipe/#{id}")
        Yummly::Recipe.new(recipe_json)
      rescue Yummly::NotFoundError
        return nil
      end
    end

    # Searches for recipes that match the supplied search terms.
    #
    # @param [String] terms A string of terms used to search API
    # @param [Hash] params Additional options to pass to the search API
    # @return [Array] a collection of recipe objects
    # @example
    #   recipes = Yummly::Api.search('Onion soup')
    def self.search(terms, params = {})
      params[:q] = terms unless params.has_key?(:q)
      result = Yummly::Connection.get(:recipes, params)
      result["matches"].collect { |recipe_json| Yummly::Recipe.new(recipe_json) }
    end

  end
end