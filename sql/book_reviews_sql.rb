require_relative '../classes/sql'

def example_report_sql(entry_date_array)

  <<EOF
SELECT books.title,
       books.author,
       books.publisher,
       books.release_date,
       books.genre,
       reviews.number_of_stars,
       reviews.reviewer,
       reviews.date_of_review
FROM #{Sql.book_reviews}
WHERE reviews.date_of_review #{Sql.between(entry_date_array, :oracle)} AND
      books.author = 'Card, Orson Scott' AND
      books.title LIKE '%shadow%'
EOF

end

# In case I want to output the SQL to a file and run it in Oracle SQL Developer or Microsoft Access
if $0 == __FILE__
  File.open(File.basename(__FILE__).split('.')[0] + '.sql', 'w', File::CREAT) {|f| f.puts example_report_sql(Report.run_for_dates)}
end
