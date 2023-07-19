# @dev This is used to sort columns by headers in the table.
module ApplicationHelper
  # takes column name and title of link
  def sortable(column, title = nil)
    title ||= column.titleize # Default is the name of the column titleized
    # For special css class if needed
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    # Logic, change direction of current column when selected.
    # Col matches currently selected sort column, and if direction then do desc. ect.
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    # Link to that title. Parameters passed to methods in controller to order by.
    link_to title, { sort: column, direction: }, { class: css_class }
  end

  def sortable_host(column, title = nil)
    title ||= column.titleize # Default is the name of the column titleized
    # For special css class if needed
    css_class = column == sort_column_host ? "current #{sort_direction}" : nil
    # Logic, change direction of current column when selected.
    # Col matches currently selected sort column, and if direction then do desc. ect.
    direction = column == sort_column_host && sort_direction == "asc" ? "desc" : "asc"
    # Link to that title. Parameters passed to methods in controller to order by.
    link_to title, { sort: column, direction: }, { class: css_class }
  end
end
