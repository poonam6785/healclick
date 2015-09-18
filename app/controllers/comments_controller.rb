class CommentsController < ApplicationController
  before_action :set_post, :set_photo, :set_parent_comment
  before_action :authenticate_user!, except: [:index, :show]

  # GET /comments
  # GET /comments.json
  def index
    @comment = Comment.new
    @latest_comment = if @post.present?
      #FIXME: do not use sql in controllers
      @post.comments.order('comments.created_at DESC').first
    end
    respond_to do |format|
      format.js
      format.html { redirect_to view_context.post_review_path_helper(@post) }
    end
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    @comment = Comment.find(params[:id]) if params[:id].present?
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
    @comment = current_user.comments.find(params[:id])
    respond_to do |format|
      format.html
      format.js { @remote = true }
    end    
  end

  # POST /comments
  # POST /comments.json
  def create
    if @parent_comment.present?
      @comment = @parent_comment.comments.new(comment_params.merge(user: current_user))
      if @comment.save
        if @parent_comment.commentable.is_a?(Post)
          @parent_comment.commentable.touch
          @parent_comment.commentable.reload
          respond_to do |format|
            format.html { redirect_to "#{post_path(@parent_comment.commentable)}?expanded=true&comment_id=#{@parent_comment.id}#comment_#{@comment.id}", notice: 'Comment was successfully created.' }
            format.js
          end
        elsif @parent_comment.commentable.is_a?(Photo)
          respond_to do |format|
            format.html { redirect_to "#{user_photo_path(@parent_comment.commentable.user, @parent_comment.commentable)}?expanded=true&comment_id=#{@parent_comment.id}#comment_#{@comment.id}", notice: 'Comment was successfully created.' }
            format.js
          end
        end
      end

    elsif @post.present?
      @comment = @post.comments.new(comment_params.merge(user: current_user))

      if @comment.save
        @post.touch
        @post.reload
        respond_to do |format|
          format.html { redirect_to "#{post_path(@post)}#comment_#{@comment.id}", notice: 'Comment was successfully created.' }
          format.js
        end
      else
        respond_to do |format|
          format.html { render action: 'new' }
          format.js
        end
      end

    elsif @photo.present?
      @comment = @photo.comments.new(comment_params.merge(user: current_user))
      if @comment.save
        respond_to do |format|
          format.html { redirect_to user_photo_path(@photo.user, @photo), notice: 'Comment was successfully created.' }
          format.js {render 'create_for_photo'}
        end
      else
        respond_to do |format|
          format.html { render action: 'new' }
          format.js
        end
      end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    @comment = current_user.comments.find(params[:id])
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to post_path(@post), notice: 'Comment was successfully updated.' }
        format.js { render (@comment.commentable.is_a?(Photo) ? 'update_for_photo' : 'update.js') }
      else
        format.html { render action: 'edit' }
        format.js { render 'update.js' }
      end
    end
  end

  def mark_as_helpful
    @comment = Comment.find(params[:id])
    helpfuls = @comment.helpfuls.where(user_id: current_user.id)
    if helpfuls.count > 0
      helpfuls.map(&:destroy)
    else
      @comment.helpfuls.create!(user: current_user)      
    end

    @comment.reload

    @element_id = "#comment_helpful_container_#{@comment.id}"

    respond_to do |format|
      format.js { render 'mark_as_helpful.js' }
    end
  end

  def luv
    @comment = Comment.find(params[:id])
    if (@luvs = @comment.luvs.where(:user_id => current_user.id)).present?
      @luvs.destroy_all
    else
      @comment.luv!(current_user)
    end
    @element_id = "#comment_luv_container_#{@comment.id}"
    respond_to do |format|
      format.js
    end
  end


  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment = current_user.comments.find(params[:id])
    @post = @comment.commentable if @comment.present? && @post.blank? && @comment.commentable.is_a?(Post)      
    @photo = @comment.commentable if @comment.present? && @photo.blank? && @comment.commentable.is_a?(Photo)

    @comment_id = @comment.id
    @commentable = @comment.commentable
    @parent = @comment.parent

    @comment.destroy!
    @commentable.update_interactions_count!(true) if @commentable.respond_to? :update_interactions_count!
    
    respond_to do |format|
      format.html do 
        if @post.present?
          redirect_to post_path(@post), notice: 'Comment was successfully removed'
        elsif @photo.present?
          redirect_to user_photo_path(@photo.user, @photo), notice: 'Comment was successfully removed'
        end
      end
      format.js { render (@photo.present? ? 'destroy_for_photo.js' : 'destroy.js') }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.from_param(params[:post_id]) if params[:post_id].present?
    end

    def set_photo
      @photo = Photo.find(params[:photo_id]) if params[:photo_id].present?
    end

    def set_parent_comment
      @parent_comment = Comment.find(params[:comment_id]) if params[:comment_id].present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:user_id, :post_id, :parent_id, :content, :comments_count, :helpfuls_count, :anonymous, :attachment)
    end
end
