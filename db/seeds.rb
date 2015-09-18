# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
PostCategory.create name: 'Introductions'
PostCategory.create name: 'Fun Stuff'
PostCategory.create name: 'Medical'
PostCategory.create name: 'Social Support'
PostCategory.create name: 'FAQ'
PostCategory.create name: 'Blog'