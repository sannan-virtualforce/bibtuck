class GmailDownloader
  class << self
    def download_all
      gmail = Gmail.connect(ENV['SAVED_PHOTOS_EMAIL'], ENV['SAVED_PHOTOS_PASSWORD'])
      gmail.inbox.unread.each do |mail|
        begin
          save_attachments_from_mail(mail)
        rescue => e
          mail.unread!
          raise e
        end
      end
    end

    def save_attachments_from_mail(mail)
      from_email = "#{mail.from.first.mailbox}@#{mail.from.first.host}"
      puts "Reading mail from #{from_email}"
      user = User.find_by_email(from_email)
      return false if !user
      photos = []

      mail.attachments.each do |attachment|
        if attachment.content_type['image']
          file = StringIO.new(attachment.decoded)
          file.class.class_eval { attr_accessor :original_filename, :content_type }
          file.original_filename = attachment.filename
          file.content_type = attachment.mime_type

          photos << Photo.create!(:user => user, :path => file)
        end
      end
    end
  end
end
