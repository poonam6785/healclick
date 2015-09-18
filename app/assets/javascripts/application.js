// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//

//= require loading
//= require modernizr
//= require oms.min
//= require sew/jquery.caretposition
//= require sew/jquery.sew
//= require jquery-ui
//= require jquery-ui/slider
//= require jquery-ui/sortable
//= require toggles.min
//= require bootstrap-file-input
//= require bootstrap-hover-dropdown
//= require bootstrap-datepicker
//= require jquery.Jcrop
//= require crop
//= require jquery.remotipart
//= require jquery.form
//= require jquery.autogrow
//= require jquery.bootstrap-growl
//= require jquery.tablesorter
//= require jquery.scrollTo.min
//= require jquery-dateFormat.min
//= require imagesloaded
//= require highcharts/highstock
//= require exporting
//= require exporting-old-look
//= require select2
//= require jquery.cookie
//= require search_by
//= require_tree ./application/.

$(document).ready(function () {
	$('.file-inputs').addClass('changed').bootstrapFileInput();
	$(window).on('notificationsArrow', function () {
		if ($('.notifications-widget .popover').is('*')) {
			$(".notifications-widget .popover .arrow").css({
				left: $('.notifications-top').offset().left + 15
			});
		}
	});
});

$(function () {
	$(document).on('click', ".popover [data-dismiss='popover']", function (e) {
		$('.popover-active').popover('hide');
	}).on('click', ".alert [data-hide='alert']", function (e) {
		$(e.target).closest('.alert').hide();
	});
	if ($('#is_mobile').attr('class') == 'false') {

		// TO-DO Inspect this
		$(document).on('click', ".popover [data-dismiss='popover']", function (e) {
			$($(e.target).data('target')).popover('hide');
			$($(e.target)).closest('.popover').hide()
		}).on('click', ".alert [data-hide='alert']", function (e) {
			$(e.target).closest('.alert').hide();
		});

		$("textarea.autogrow").autogrow();

	} else {
		// Hide the keyboard if we click outside a input/textarea element
		document.addEventListener('touchstart', function (e) {
			if (!isTextInput(e.target) && isTextInput(document.activeElement) && e.target.className != '') {
				document.activeElement.blur();
			}
		}, false);

		function isTextInput(node) {
			return ['INPUT', 'TEXTAREA'].indexOf(node.nodeName) !== -1;
		}
	}
});

window.hc.pages.initS2();
