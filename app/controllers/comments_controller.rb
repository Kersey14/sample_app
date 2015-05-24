class CommentsController < ApplicationController
  def new 
  end

  def create
    respond_to do |format|
    	@comment = current_user.comments.build(comment_params)
    	if @comment.save
    	  flash[:success] = 'Your comment was successfully posted!'
    	else
    	  flash[:error] = 'Your comment cannot be saved.'
    	end
    	format.html {redirect_to '/stream'}
      format.js
    end
  end

  def stream
  	@comment = Comment.new
  	@comments = Comment.order('created_at DESC')

    job_id = Rufus::Scheduler.singleton.every '1h' do 
      Rails.logger.info "Removing excessive comments now..."
      Comment.remove_excessive!
    end
  end

  def index
    @comments = Comment.where('id > ?', params[:after_id].to_i).order('created_at DESC')
  end

  private

    def comment_params
      params.require(:comment).permit(:body)
    end
end
