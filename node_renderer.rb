# Create the class for the node renderer

class NodeRenderer
	# Will be passed a DOMTree
	def initialize(tree)
		@tree = tree
		@head = tree.head
	end

	# Render the stats for a particular node. 
	# This will be based on the name attribute
	# for the time being.
	def render(nodes = [@head])
		nodes.each do |node|
			match_node = find_match(node)
			output = get_stats(match_node)
			puts output
		end
		return nil
	end

	# Will start at the @head node of the tree and look at all
	# the children nodes to see if any of the names match up.
	# If the name is nil then it will return @head. If there is
	# a match then it will return that node. Otherwise return false
	# if there's no match.
	def find_match(node)
		queue = [@head]
		while !queue.empty?
			current_node = queue.pop
			if current_node == node
				return current_node
			else
				current_node.children.each{|child| queue.unshift(child)} unless current_node.children.nil?
			end
		end
		false
	end 

	# get_stats will take a node (or false) and return stats about it.
	# stats we want are the node's data attributes (name, text, class, id, children, parent).
	# Also, total number of nodes below this node and a cound of each node type below it.
	# if get_stats receives false then it will return that no node with that name was found.
	def get_stats(node)
		if node == false
			"Sorry, no node by that name was found."
		else
			sub_stats = sub_node_stats(node)
			sub_count = sub_stats.values.inject{|sum, el| sum + el} || 0
			node_info = get_node_info(node)
			output = create_output([sub_stats, sub_count, node_info])
		end
	end

	# Creates a string of output to be sent to the render function.
	# info[2] has a hash of :name, :text, :classes, and :id
	def create_output(info)
		output = "Info for #{info[2][:name]} node:\n"
		output += "Text: #{info[2][:text]}\n"
		output += "Classes: #{info[2][:classes]}\n"
		output += "ID: #{info[2][:id]}\n"
		output += "Sub node count: #{info[1]}\n"
		output += "Sub node info: #{info[0]}"
	end

	# Returns a hash of all of the particular node's data
	# (name, text, classes, id)
	def get_node_info(node)
		args = [:name, :text, :classes, :id]
		info = {}
		args.each{|arg| info[arg] = (node[arg] && !node[arg].empty? ? node[arg] : "none")}
		info
	end

	# Returns a hash of all of the node's sub nodes as keys and their count as values.
	def sub_node_stats(node)
		queue = [node]
		sub_nodes = {}
		while !queue.empty?
			current_node = queue.pop
			if current_node.children
				sub_node_stats_add(current_node, sub_nodes, queue)
			end
		end
		sub_nodes
	end

	# If the current node has children then increment the hash value
	# if the key already exists. Otherwise, create the key and set the
	# value to 1.
	def sub_node_stats_add(current_node, sub_nodes, queue)
		current_node.children.each do |child|
			if sub_nodes[child.name]
				sub_nodes[child.name] += 1
			else
				sub_nodes[child.name] = 1
			end
			queue.unshift(child)
		end
	end
end