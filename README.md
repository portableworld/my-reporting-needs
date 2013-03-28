# My Reporting Needs

Various scripts I use to facilitate my reporting needs at work.

## What this is
### What I do
I am currently working at CitiMortgage (I have nothing to do with loans so don't ask) where my responsibility is to run reports for management. These reports are ran against an Oracle data warehouse and a series of Microsoft Access databases. I query the database, copy the data into an Excel spreadsheet, update the pivot tables, zip up the file, and both upload it to a SharePoint site and email it to those who require it. It is myself and my peer in Dallas that run the reports for our department. He runs between 15 and 20 of these reports over the first 6 hours of his day. I run 45 in the first hour of my day. How?

### What Ruby does for me
Since we run Windows computers, I have used the `win32ole` library included with the Windows install of Ruby MRI to make connections to the Microsoft Office applications used in my reporting. `Database.rb` makes a connection to either an Access database or an Oracle database. Once the data is acquired, it is inserted into Excel using `Excel.rb`. From there, I use a third-party zip library to zip up the spreadsheet. I'll then email out the report using `Outlook.rb`. This is all tied together using `Report.rb` (not yet pushed to Github due to sensitive details about our company's system that still need to be cleaned up out of the class). 

Once the `Report` class is in place, running a report is as simple as

    require 'report'
    
    report = Report.new do |r|
      r.name = 'New Report'
      r.type = :oracle
      r.folder = 'path/to/folder'
      r.file = 'New Report spreadsheet'
      r.sheet = 'Main Data'
    end
    
    report.run!
    
    email = Outlook.new
    email.subject = 'Your report is ready'
    email.body = %Q{Here is your report for #{Time.now.formatted}.}
    email.attatchment = report.file
    email.to('boss@example.com')
    email.send

