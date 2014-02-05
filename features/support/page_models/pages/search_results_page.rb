module PageModels
  class SearchResultsPage < PageModels::BlinkboxbooksPage
    set_url "/#!/search{?q}"
    set_url_matcher /search\?q\=/
    element :searched_term, ".searched_term"
    elements :books, "div.itemsets div[book=\"book\"]"
    sections :book_results_sections, BookResults, '[data-test="search-results-list"]'

    #did not make it to work, gave up due to lack of time
    #section :book_results, BookItems, "div.itemsets"
  end

  register_model_caller_method(SearchResultsPage, :search_results_page)
end
