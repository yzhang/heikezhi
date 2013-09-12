# encoding: utf-8
class ArticlesController < ApplicationController
  before_filter :authenticate_user!, :only => [:mine, :edit, :new, :destroy, :update, :publish]

  def index
    @user = OpenStruct.new(
      twitter: "http://twitter.com/yuanyiz",
      google_plus: 'http://gplus.to/yuanyiz',
      github: 'https://github.com/yzhang/heikezhi',
      atom_feed: '/atom',
      json_feed: '/'
    )
    @disqus = true

    respond_to do |format|
      format.html { 
        @article = Article.recommended.first 
        
        user_agent =  request.env['HTTP_USER_AGENT'].downcase
        render html: '' if user_agent.index('iPhone;')
      }
      format.json {
        @articles = Article.includes(:user).recommended.to_a
        render json: @articles.to_json(logged_in:false) 
      }
      format.atom { @articles = Article.recommended.page(1) }
    end
  end

  def user
    @articles_url = "/#{params[:name]}"
    @user = User.where(name:params[:name]).first
    @article = @user.articles.includes(:user).published.first
    @disqus = true

    respond_to do |format|
      format.html { render 'index' }
      format.json {
        @articles = @user.articles.includes(:user).published.to_a
        render json: @articles.to_json(logged_in:false) 
      }
      format.atom { 
        @articles = @user.articles.includes(:user).published.page(1) 
        render 'index'
      }
    end
  end

  def show
    @articles_url = "/#{params[:name]}"

    @user    = User.where(:name => params[:name]).first!
    @article = Article.where(:permalink => params[:permalink]).first!
    bare   = params[:bare] == '1'
    @disqus = true

    respond_to do |wants|
      wants.html {render layout: !bare}
    end
  end

  def mine
    @user = OpenStruct.new(json_feed: '/mine')
    bare   = params[:bare] == '1'
    @disqus = false

    @article = current_user.articles.where(permalink:params[:permalink]).first
    @article ||= current_user.articles.order("created_at DESC").first
    @article ||= current_user.articles.create

    respond_to do |wants|
      wants.html {render layout: !bare}
      wants.json {
        render json: current_user.articles.includes(:user).order("created_at DESC").to_json(logged_in:true)
      }
    end
  end

  def new
    @article = current_user.articles.create
    redirect_to edit_article_path(@article.permalink)
  end

  def edit
    @user = OpenStruct.new(json_feed: '/mine')
    @article = current_user.articles.where(permalink:params[:permalink]).first

    render layout:'edit'
  end

  def destroy
    @article = current_user.articles.where(permalink:params[:permalink]).first
    @article.destroy
    redirect_to '/mine'
  end

  def update
    @article = current_user.articles.where(permalink:params[:permalink]).first
    @article.update_attributes(
      title: params[:title],
      permalink: params[:permalink],
      content: params[:content]
    )
    respond_to do |wants|
      wants.json {render :json => {:result => 'success'}}
    end
  end

  def publish
    @article = current_user.articles.where(permalink:params[:permalink]).first
    @article.publish! if @article.pending?

    respond_to do |wants|
      wants.json {render :json => {:result => 'published'}}
    end
  end
end
