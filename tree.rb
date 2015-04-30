# Create a DOM Tree Class

# First thing is to create the Node struct
Node = Struct.new(:name, :text, :classes, :id, :children, :parent)

class DOMTree
	attr_reader :file
	attr_accessor :head

	def initialize(file_name)
		# gsub(/<!.*?>/, "") Removes <! doctype > from the document
		# gsub(/>\s*</,"><") Removes all the whitespace from between > & < characters
		# gsub(/\n/, "") Removes the newline characters from the document
		@file = load(file_name).read.gsub(/\n/, "").gsub(/>\s*</,"><").gsub(/<!.*?>/, "")
		@head = Node.new("Document", @file)
	end

	def load(file_name)
		File.open(file_name, "r")
	end

	# Recursively get the children for each node. Returns nil
	# if there are no more children.
	def get_children(node = @head)
		first_tag = get_first_tag(node.text)
		
	end

	# Function will take an argument and return everything between the 
	# first <...> tags.
	def get_first_tag(input)
		matches = input.match(/^<(.*?)>/)
		# We only want to return the first thing captured by this (the second will likely be
		# either a space character or a >).
		matches.captures[0]
	end

	# Function takes an argument (which which has already been sterilized by the get_first_tag function) 
	# and will then return the NAME of the tag. This will be used later so that I can get the 
	# first and last tags of a particular group.
	def get_name(input)
		# Regex is to match the 'name' of a certain tag. It looks for any amount of 
		# characters after the beginning and stops when it reaches a space the end of the string. 
		# This way both <html> and <p class="foo"> will match "html" and "p" respectively.
		matches = input.match(/^(.*)\s|^(.*)$/)
		# The name could be in the first or the second match. Therefore we want to check if the first
		# match is nil. If it is, return the second.
		if matches.captures[0].nil?
			matches.captures[1]
		else
			matches.captures[0]
		end
	end

	# Function will take an argument (steralized from get_first_tag) and return
	# the class of the tag if it has one. Otherwise will return false.
	def get_id(input)
		# Trying to account for two situations. 1) Where double-quotes OR single-quotes 
		# are used. 2) Where there is a space after the ID (i.e. id ="foo"). Should build
		# up other contingincies such as id = "foo" and id= "foo" but these add up quickly.
		matches = input.match(/id="(.*?)"|id\s="(.*?)"|id='(.*?)'|id\s='(.*?)'/)
		# Since I have contingency plans some of these matches will return nil. I only want the 
		# one that has a value.
		matches.captures.each do |match|
			return match if !match.nil?
		end
	end
end

# Playground

# Get id from string (double or single quote)
# id=((\"|\').*?(\"|\'))

# Get class from string (double or single quote)
# class=((\"|\').*?(\"|\'))