$(document).ready(function() {
  $('.nav > li').each(function() {
    var href = $(this).find('a').attr('href');
    if (href === window.location.pathname) {
      $(this).addClass('active');
    }
  });
});