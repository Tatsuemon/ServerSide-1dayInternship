class CardsController < ApplicationController
  def show
    credentials = Aws::Credentials.new(ACCESS_KEY, ACCESS_SECRET_KEY)
    card_id = params[:id]
    s3 = Aws::S3::Resource.new(credentials: credentials, region: REGION, endpoint: END_POINT, force_path_style: true)
    obj = s3.bucket(BUCKET).object(card_id)
    body = obj.get().body
    send_data body.read()
  end
  
  private
  ACCESS_KEY = 'ak_eight'
  ACCESS_SECRET_KEY = 'sk_eight'
  REGION = 'us-east-1'
  BUCKET = 'cards'
  END_POINT = 'http://serverside-1dayinternship_minio_1:9000'
end