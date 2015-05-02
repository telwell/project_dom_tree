# Create the tree searcher class

class TreeSearcher
	# Initially takes a DOMTree
	def initialize(tree)
		@tree = tree
		@head = tree.head
	end

	# Search through the tree by a particular attribute (:name, :text, :class, :id)
	# and return a collection of nodes which meet these attributes.
	def search_by(attribute, search)
		final = find_matches(attribute, search)
	end

	def search_children(attribute, search, start_node)
		# I made it start_node[0] because I figured we wouldn't 
		# be searching multiple nodes in different locations here.
		final = find_matches(attribute, search, start_node[0])
	end

	def search_ancestors(attribute, search, start_node)
		final = find_matches(attribute, search, start_node[0], true)
	end

	def find_matches(attribute, search, start_node = @head, ancestors = false)
		matches = []
		queue = [start_node]
		while !queue.empty? 
			current_node = queue.pop
			if current_node[attribute] && current_node[attribute].match(/(#{search})/)
				matches << current_node
			end
			if ancestors == true
				queue.unshift(current_node.parent) unless current_node.parent.nil?
			else
				current_node.children.each{|child| queue.unshift(child)} unless current_node.children.nil?
			end
		end
		matches
	end
end