if AWS_S3_CONFIG[:assets_bucket].present?
  Paperclip::Attachment.default_options.merge!(
      :storage => :s3,
      :s3_credentials => {
        :bucket => AWS_S3_CONFIG[:assets_bucket],
        :access_key_id => AWS_S3_CONFIG[:access_key_id],
        :secret_access_key => AWS_S3_CONFIG[:secret_access_key]
      },
      :url => ":s3_west_2_url",
      :path => '/:class/:attachment/:id_partition/:style/:filename'
    )
  Paperclip.interpolates(:s3_west_2_url) do |att, style|
    "https://s3-us-west-2.amazonaws.com/#{att.bucket_name}#{att.path(style)}"
  end
end
