# ! MINOR BUGS: 
# 1) :text is being deleted from the <ul> node. I know this has to do with 
# the special gsub for <li> children but not specifically why it's happening.
# 2) Spacing error on some of the other :text fields. Specifically the 'outer-div'

# Require relatives
require_relative('node_renderer.rb')
require_relative('tree_searcher.rb')
require_relative('tree_loader.rb')

# Create a DOM Tree Class

# First thing is to create the Node struct
Node = Struct.new(:name, :text, :classes, :id, :children, :parent)

class DOMTree
	attr_reader :file, :head

	def initialize(file_name)
		# gsub(/<!.*?>/, "") Removes <! doctype > from the document
		# gsub(/>\s*</,"><") Removes all the whitespace from between > & < characters
		# gsub(/\n/, "") Removes the newline characters from the document
		@file = TreeLoader.new(file_name).file
		@head = Node.new("Document", @file)
		create_tree
	end

	# Recursively get the children for each node. Returns nil
	# if there are no more children.
	def create_tree
		queue = [@head]
		while !queue.empty?
			current_node = queue.pop
			if has_children?(current_node.text)
				current_node.children = []
				create_children(current_node, queue)
			else
				current_node.text = current_node.text.strip
			end
		end
	end

	def create_children(node, queue)
		while has_children?(node.text)
			first_tag = get_first_tag(node.text)
			child_name = get_name(first_tag)
			child_class = get_class(first_tag)
			child_id = get_id(first_tag)
			child_text = (child_name == "li" ? get_inner_HTML(node.text, child_name, true) : get_inner_HTML(node.text, child_name))
			child_node = Node.new(child_name, child_text, child_class, child_id, nil, node)
			node.children << child_node
			queue.unshift(child_node)
			if child_name == "li" # Need to make things lazy for <li>
				node.text = node.text.gsub(/^.*?(<#{child_name}.*?>.*?<\/#{child_name}>)/, "")
			else
				node.text = node.text.gsub(/(<#{child_name}.*?>.*<\/#{child_name}>)/, "")
			end
		end
	end

	# Return the HTML from between a pair of tags by name.
	def get_inner_HTML(input, name, lazy = false)
		if lazy == true
			matches = input.match(/^.*?<#{name}.*?>(.*?)<\/#{name}>/)
		else
			matches = input.match(/<#{name}.*?>(.*)<\/#{name}>/)
		end
		matches ? matches.captures[0] : false
	end

	def has_children?(input)
		# Looking for any kind of <> in the text. Remember, <...> tags might not
		# be at the beginning.
		matches = input.match(/<(.*?)>/)
		(get_first_tag(input) == false && matches.nil?) ? false : true 
	end

	# Function will take an argument and return everything between the 
	# first <...> tags. Otherwise returns false.
	def get_first_tag(input)
		matches = input.match(/<(.*?)>/)
		# We only want to return the first thing captured by this. Otherwise
		# return false.
		matches ? matches.captures[0] : false
	end

	# Function takes an argument (which which has already been sterilized by the get_first_tag function) 
	# and will then return the NAME of the tag. This will be used later so that I can get the 
	# first and last tags of a particular group.
	def get_name(input)
		# Regex is to match the 'name' of a certain tag. It looks for any amount of 
		# characters after the beginning and stops when it reaches a space the end of the string. 
		# This way both <html> and <p class="foo"> will match "html" and "p" respectively.
		matches = input.match(/^(.*?)\s|^(.*?)$/)
		# The name could be in the first or the second match. Therefore we want to check if the first
		# match is nil. If it is, return the second.
		matches.captures[0].nil? ? matches.captures[1] : matches.captures[0]
	end

	# Function will take an argument (steralized from get_first_tag) and return
	# the class of the tag if it has one. Otherwise will return nil.
	def get_id(input)
		# Trying to account for two situations. 1) Where double-quotes OR single-quotes 
		# are used. 2) Where there is a space after the ID (i.e. id ="foo"). Should build
		# up other contingincies such as id = "foo" and id= "foo" but these add up quickly.
		matches = input.match(/id="(.*?)"|id\s="(.*?)"|id='(.*?)'|id\s='(.*?)'/)
		# Since I have contingency plans some of these matches will return nil. I only want the 
		# one that has a value.
		return nil if matches.nil?
		matches.captures.each do |match|
			return match if !match.nil?
		end
	end

	def get_class(input)
		# Almost the same as get_id above.
		matches = input.match(/class="(.*?)"|class\s="(.*?)"|class='(.*?)'|class\s='(.*?)'/)
		# Same as above.
		return nil if matches.nil?
		matches.captures.each do |match|
			return match if !match.nil?
		end
	end
end