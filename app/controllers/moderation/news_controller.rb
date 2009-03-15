class Moderation::NewsController < ModerationController

  def index
    @news  = News.draft.sorted
    @polls = Poll.draft
  end

  def show
    @news   = News.find(params[:id])
    @boards = @news.boards
  end

  def accept
    @news = News.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @news && @news.acceptable_by?(current_user)
    @news.accept!
    redirect_to @news
  end

  def refuse
    @news = News.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @news && @news.refusable_by?(current_user)
    @news.refuse!
    redirect_to @news
  end

  def edit
    @news = News.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @news && @news.editable_by?(current_user)
  end

  def update
    @news = News.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @news && @news.editable_by?(current_user)
    @news.attributes = params[:news]
    @news.committer  = current_user
    if @news.save
      flash[:success] = "Modification enregistrée"
      redirect_to [:moderation, @news]
    else
      render :edit
    end
  end

  def show_diff
    @news = News.find(params[:news_id])
    raise ActiveRecord::RecordNotFound unless @news
    @version = @news.version(params[:sha])
  end

end