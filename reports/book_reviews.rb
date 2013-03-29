require_relative '../classes/Report'

report = Report.new do |r|
  r.name   = 'Shadows Series Book Reviews'
  r.type   = :oracle
  r.folder = 'Report Folder'
  r.file   = 'Book Reviews for'
  r.excel_sheet = 'Review Scores'
  r.date_range  = Time.last_business_day
end

run_at_6_am
report.run!

email = Outlook.new
email.subject = "Shadow series reviews for #{report.rundate.first}"
email.body    = %Q{
Good morning,
  Attached are the reviews for the Shadow series by Orson Scott Card for #{report.rundate.first}.
  Let me know if you have any questions.
  }
email.attachments = report.file_path
email.to('boss@example.com')
email.cc('reporting@example.com')
email.send