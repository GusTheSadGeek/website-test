module PageModels
  module SearchResultsActions
    def switch_to_grid_view
      unless search_results_page.current_view == :grid
        search_results_page.wait_for_grid_view_button
        search_results_page.wait_until_grid_view_button_visible
        puts 'Switching to grid view of book results'
        search_results_page.grid_view_button.click
        wait_until('Search results page is displayed in Grid view') { search_results_page.current_view == :grid }
      end
    end

    def switch_to_list_view
      unless search_results_page.current_view == :list
        search_results_page.wait_for_list_view_button
        search_results_page.wait_until_list_view_button_visible
        puts 'Switching to list view of book results'
        search_results_page.list_view_button.click
        wait_until('Search results page is displayed in List view') { search_results_page.current_view == :list }
      end
    end

    def switch_to_view(view)
      books_section.wait_for_books
      if view.to_sym == :list
        switch_to_list_view
      elsif view.to_sym == :grid
        switch_to_grid_view
      elsif view.to_sym == :none
        # Do nothing on purpose
      else
        fail "Unsupported view for book results: #{view}"
      end
    end
  end
end

World(PageModels::SearchResultsActions)
