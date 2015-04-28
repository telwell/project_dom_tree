# Create a DOM Tree Class

class DOMTree


end

# Playground
def load(file_name)
	arr = []
	file = File.open(file_name, "r") do |file|
		arr = file.readlines
		arr = arr.map {|word| word.strip }
	end
	arr
end
