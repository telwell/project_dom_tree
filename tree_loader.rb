# Create a tree loader Class so we can access a useable file.

class TreeLoader
	attr_reader :file

	def initialize(file_name)
		@file = sterilize_file(load(file_name))
	end

	def load(file_name)
		File.open(file_name, "r")
	end

	def sterilize_file(input)
		input.read.gsub(/\n/, "").gsub(/>\s*</,"><").gsub(/<!.*?>/, "")
	end
end