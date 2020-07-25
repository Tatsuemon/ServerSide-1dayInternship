# frozen_string_literal: true

require 'csv'
require 'aws-sdk-s3'

def card_image_bin(org, dep, name, email)
  color = '#' + Array.new(3) { [*126..255].sample.to_s(16) }.join
  image = Magick::Image.new(600, 381) do
    self.format = 'jpeg'
    self.background_color = color
  end
  draw = Magick::Draw.new.tap do |d|
    d.font = 'VL-Gothic-Regular'
    d.pointsize = 40
    d.gravity = Magick::NorthWestGravity
  end
  draw.annotate(image, 600, 381, 0, 0, "#{org}\n#{dep}")
  draw.pointsize = 32
  draw.gravity = Magick::SouthEastGravity
  draw.annotate(image, 600, 381, 0, 0, "#{name}\n#{email}")
  image.to_blob
end

# reset tables
begin
  ActiveRecord::Base.connection.execute('START TRANSACTION')
  Person.destroy_all
  ActiveRecord::Base.connection.execute('ALTER TABLE cards AUTO_INCREMENT = 1')
  ActiveRecord::Base.connection.execute('ALTER TABLE people AUTO_INCREMENT = 1')
  ActiveRecord::Base.connection.execute('COMMIT')
rescue => e
  ActiveRecord::Base.connection.execute('ROLLBACK')
  raise e
end

# find or create a s3 bucket
resource = Aws::S3::Resource.new(
  endpoint: 'http://serverside-1dayinternship_minio_1:9000',
  region: 'us-east-1',
  access_key_id: 'ak_eight',
  secret_access_key: 'sk_eight',
  force_path_style: true,
)
bucket = resource.bucket('cards').exists? ? resource.bucket('cards') : resource.create_bucket(bucket: 'cards')

# insert seeds data
ActiveRecord::Base.transaction do
  CSV.foreach('db/cards.csv') do |row|
    card = Card.new(
      name: row[0],
      email: row[1],
      organization: row[2],
      department: row[3],
      title: row[4],
    )
    Person.new.tap { |person| person.cards << card }.save!

    bucket.object(card.id.to_s).put(body: card_image_bin(card.organization, card.department, card.name, card.email))
  end
end
