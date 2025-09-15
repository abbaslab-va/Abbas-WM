function remove_figure_text(figH)
set(figH.Children(end), 'XTickLabels', {})
set(figH.Children(end), 'YTickLabels', {})