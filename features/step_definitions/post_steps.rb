Given /^Post categories exist$/ do
  PostCategory.create name: 'Introductions'
  PostCategory.create name: 'Fun Stuff'
  PostCategory.create name: 'Medical'
  PostCategory.create name: 'Social Support'
  PostCategory.create name: 'FAQ'
  PostCategory.create name: 'Blog'
end