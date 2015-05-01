# Create the tree searcher class

class TreeSearcher
	# Initially takes a DOMTree
	def initialize(tree)
		@tree = tree
		@head = tree.head
	end

	# Search through the tree by a particular attribute (:name, :text, :classes, :id)
	# and return a collection of nodes which meet these attributes.
	def search_by(attribute, search)
		final = find_matches(attribute, search)
	end

	def find_matches(attribute, search)
		matches = []
		queue = [@head]
		while !queue.empty? 
			current_node = queue.pop
			if current_node[attribute] && current_node[attribute].match(/(#{search})/)
				matches << current_node
			end
			current_node.children.each{|child| queue.unshift(child)} unless current_node.children.nil?
		end
		matches
	end

	# TODO: This still leaves the search_children and the search_ancestors searches to complete.
end