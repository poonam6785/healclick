$('#labs-container').html "<%= j render('personal_profiles/labs') %>"
$('.labs h3.date').text "<%= l(@date.to_time, format: :short) %>"
init_treatments_select2()