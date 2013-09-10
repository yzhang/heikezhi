atom_feed do |feed|
  feed.title("黑客志")
  feed.updated(@articles[0].created_at) if @articles.length > 0

  @articles.each do |article|
    feed.entry(article, url: article_permalink_url(article.user.name, article.permalink)) do |entry|
      entry.title(article.title)
      entry.content(article.content, :type => 'html')

      entry.author do |author|
        author.name(article.user.name)
      end
    end
  end
end