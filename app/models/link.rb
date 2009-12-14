# The news can have some important links.
# We follow the number of clicks on each of these links.
#
class Link < ActiveRecord::Base
  belongs_to :news

  attr_accessor   :user_id
  attr_accessible :user_id, :title, :url, :lang

  validates_presence_of :title, :message => 'Un lien doit obligatoirement avoir un titre'
  validates_url_format_of :url, :message => "n'est pas une URL valide"

  def url=(url)
    url = "http://#{url}" if url.present? && url.not.starts_with?('http')
    write_attribute :url, url
  end

  def hit
    self.class.increment_counter(:nb_clicks, self.id)
    url
  end

### Chat ###

  after_create :announce_create
  def announce_create
    message = render_to_string(:partial => 'links/board', :locals => {:action => 'lien ajouté', :link => self})
    news.boards.creation.create(:message => message, :user_id => user_id)
  end

  after_update :announce_update
  def announce_update
    message = render_to_string(:partial => 'links/board', :locals => {:action => 'lien modifié', :link => self})
    news.boards.edition.create(:message => message, :user_id => user_id)
  end

  before_destroy :announce_destroy
  def announce_destroy
    message = render_to_string(:partial => 'links/board', :locals => {:action => 'lien supprimé', :link => self})
    news.boards.deletion.create(:message => message, :user_id => user_id)
  end

end

# == Schema Information
#
# Table name: links
#
#  id         :integer(4)      not null, primary key
#  news_id    :integer(4)      not null
#  title      :string(255)
#  url        :string(255)
#  lang       :string(255)
#  nb_clicks  :integer(4)      default(0)
#  created_at :datetime
#  updated_at :datetime
#

