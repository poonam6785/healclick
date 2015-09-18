$('#treatments_container').html "<%= j render('personal_profiles/treatments') %>"
$('.treatments h3.date').text "<%= l(@date, format: :short) %>"
init_treatments_container()
init_treatments_select2()
$(window).resize()
$('body').trigger 'init_treatment_toggles'