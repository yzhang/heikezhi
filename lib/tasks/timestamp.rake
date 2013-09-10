namespace :hkz do

  task :update_timestamp => :environment do
    f = File.open('1.txt')
    f.each_line do |line|
      published_at, permalink = line.split(',')
      permalink.sub!(/[\r\n]/, '')
      a = Article.where(permalink: permalink).first

      next unless a
      puts a.title
      a.published_at = Time.parse(published_at)
      a.save
    end
    f.close
  end
end
