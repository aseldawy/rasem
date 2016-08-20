#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pp'
   
version_url = "http://www.w3.org/TR/SVG11/"

#obtain all elements in this version:
page = Nokogiri::HTML(open(version_url + 'eltindex.html'))

elements = []
structure = {}

page.css("li").each do 
  |li|  
  link = li.css("a")[0]['href']
  span = li.css("span.element-name")
  name = span.children[0].text
  tag = name[1..-2].to_sym

  p "Gathering info for #{tag.to_s}"
  more = Nokogiri::HTML(open(version_url + link))

  more = more.css('div.element-summary').select do
    |summary|
      summary.css('div.element-summary-name').children[0].text == name
  end

  available_elements = more[0].css('span.element-name').map { |s| s.children[0].text[1..-2].to_sym }
  available_attributes = more[0].css('span.attr-name').map { |s| s.children[0].text[1..-2].to_sym }

  available_elements
  available_attributes

  structure[tag] = {
    :elements => available_elements,
    :attributes => available_attributes,
  }

  elements.push(tag)
  p "..."
end

p "Adding xmlns attribute fammily to svg tag:"
xmlns = [
  nil,
  "svg",
  "cc",
  "dc",
  "rdf",
  "inkscape",
  "xlink",
].map! { |e| ( if e then "xmlns:" + e else "xmlns" end).to_sym }
p xmlns
structure[:svg][:attributes].push(*xmlns) 

p "Writing to file."

#write header:
File.open('svg_documentation.rb', 'w') do
  |file|
  file << <<-HEAD
###############################################################################
# Please do not modify this file manually, it is regenerated from w3 website. #
###############################################################################

HEAD
  file << "Rasem::SVG_ELEMENTS = \n"
  PP.pp(elements,file)
  file << "Rasem::SVG_STRUCTURE = \n"
  PP.pp(structure,file)
end

p "Done"

