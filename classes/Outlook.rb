require 'win32ole'
require_relative 'active_support'

class Outlook

  TEXT = 1
  HTML = 2

  SEND_TO   = 1
  SEND_CC   = 2
  SEND_BCC  = 3

  MAIL_ITEM = 0

  attr_reader :outlook, :email, :subject, :recipients, :attachments, :format, :inbox, :body
  attr_accessor :signature

  def initialize
    puts
    puts 'Opening Outlook...'
    @outlook     = WIN32OLE.new('Outlook.Application')
    @recipients  = Hash.new
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

  def to(*addresses)
    add_recipient(addresses, SEND_TO)
  end
  
  def cc(*addresses)
    add_recipient(addresses, SEND_CC)
  end
  
  def bcc(*addresses)
    add_recipient(addresses, SEND_BCC)
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

  def send(*args)
    # Note that this overrides Object#send. Use Object#__send__ instead.
    # Overriding Object#send is screwing up RSpec 'have' matcher
    # The following is an attempt to capture Object#send attempts and pass it up the chain
    return super unless args.empty?
    
    puts 'Opening new email message...'
    @email = @outlook.Createitem(MAIL_ITEM)
    @email.Subject    = @subject
    @email.BodyFormat = @format
    @body += "\n\n#{@signature}" # TODO - The \n\n will not transpose to HTML properly yet
    attach_body
    attach_files
    attach_addresses # TODO - Move this into #to, #cc, and #bcc
    puts 'Sending email message...'
    @email.Send
    puts 'Done sending email'
  end

  def me
    @ns.currentuser.name
  end

  def view_recipients(type = :all)
    # TODO - Display list of recipients based on :to, :cc, :bcc, or :all
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
      @recipients.each {|addy, type| @email.Recipients.Add(addy).type = type}
    end
  end

  def add_recipient(*addresses, type)
    addresses.each do |address|
      if address.is_a? String
        # Note there is no validation to confirm the string is an email address
        # TODO - Validation. Put the massive regex for email confirmation into a Module
        @recipients[address] = type
      elsif address.is_a? Array
        add_recipient(*address, type)
      else
        raise 'Methods #to must take either a string or an array of strings.'
      end
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
