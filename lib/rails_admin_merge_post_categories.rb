require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions

      class MergePostCategories < Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :bulkable? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            @categories = list_entries#.order('name ')
            if @categories.count > 1
              first_category = @categories.first
              @posts = Post.where(post_category_id: @categories.map(&:id))
              @posts.update_all post_category_id: first_category.id
              PostCategory.where(id: @categories.delete_if {|c| c.id == first_category.id}.map(&:id)).destroy_all
            end
            redirect_to back_or_index, notice: "Post Categories successfully merged. Resulting category id: #{first_category.id}"
          end
        end
      end
    end
  end
end