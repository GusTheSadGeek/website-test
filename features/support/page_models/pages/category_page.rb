module PageModels
  class CategoryPage < PageModels::BlinkboxbooksPage
    set_url "/#!/category"
    set_url_matcher /category/
    element :category_books, '#category'
    sections :book_results_sections, BookResults,'[data-test="search-results-list"]'
    element :category_name, '[data-test="category-title"]'
  end

  register_model_caller_method(CategoryPage)
end