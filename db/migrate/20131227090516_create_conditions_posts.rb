class CreateConditionsPosts < ActiveRecord::Migration
  def change
    create_table :conditions_posts, id: false do |t|
      t.references :condition
      t.references :post
    end
  end
end
