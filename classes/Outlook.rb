require 'win32ole'
require 'active_support'

class Outlook

  TEXT = 1
  HTML = 2

  MAIL_ITEM = 0

  attr_reader :outlook, :email, :subject, :recipients, :attachments, :format, :inbox, :body
  attr_accessor :signature

  def initialize
    puts
    puts 'Opening Outlook...'
    @outlook     = WIN32OLE.new('Outlook.Application')
    @recipients  = Array.new
    @format      = TEXT
    @body        = ''
    # TODO - Put signature in an external YAML file
    @signature   = ''
    @attachments = Array.new
    @ns          = @outlook.getnamespace('MAPI')
    @inbox       = @ns.folders.to_enum.each do |folder|
      if folder.folders.to_enum.collect {|f| f.name}.include? 'Inbox'
        break folder.folders['Inbox']
      end
    end
  end

  def body=(body)
    if @format == HTML
      @body = body.gsub("\n", '<br>')
    else
      @body = body
    end
  end

  def subject=(subject_line)
    @subject = subject_line
  end

  def to(addresses)
    if addresses.is_a? String
      @recipients << addresses
    elsif addresses.is_a? Array
      @recipients += addresses
    end
  end

  def format=(message_format)
    message_format = message_format.downcase.to_sym if message_format.respond_to? :downcase
    if message_format.downcase == :text
      @format = TEXT
      @body = @body.gsub('<br>', "\n")
    elsif message_format.downcase == :html
      @format = HTML
      @body = @body.gsub("\n", '<br>')
    else
      warn "Format setting '#{message_format}' not supported. Defaulting to :text"
      @format = TEXT
    end
  end

  def attachments=(path_to_file)
    files = path_to_file.is_a?(String) ? [path_to_file] : path_to_file
    files.each do |file|
      if File.exists?(file)
        @attachments << file
      else
        raise ArgumentError, "File #{file} not found! Please check file path and try again. "
      end
    end
  end
  alias :attach :attachments=

  def send
    puts 'Opening new email message...'
    @email = @outlook.Createitem(MAIL_ITEM)
    @email.Subject    = @subject
    @email.BodyFormat = @format
    @body += "\n\n#@signature" # TODO - The \n\n will not transpose to HTML properly yet
    attach_body
    attach_files
    attach_addresses
    puts 'Sending email message...'
    @email.Send
    puts 'Done sending email'
  end

  def me
    @ns.currentuser.name
  end

  private

  def attach_files
    if @email
      unless @attachments.empty?
        @attachments.each {|file| @email.Attachments.Add(file, 1)}
      end
    end
  end

  def attach_addresses
    return unless @email

    if @recipients.empty?
      raise ArgumentError, 'There must be at least one name or distribution list in ' +
            'the To, CC, or BCC fields.'
    else
      @recipients.each {|addy| @email.Recipients.Add(addy)}
    end
  end

  def attach_body
    return unless @email
    
    # TODO
    # Note that if @body is put into @email.body and format is set to 
    # HTML then Outlook will actually transpose @body to html. 
    # It will replace all \n to <br> and so on. 
    # However, I can not determine a way to insert a link 
    # <a href="http://example.com">Example</a>
    # without coding it manually and putting it into @email.htmlbody
    if @format == TEXT
      @email.Body = @body
    elsif @format == HTML
      @email.HTMLBody = @body
    end
  end

end