$LOAD_PATH = ['/grandstand/javascripts'];

$(document).ready(function() {
  $('.wysiwyg').dependency('wysiwyg', function() {
    this.wysiwyg('post', '.post');
  });

  $('head').append('<link charset="utf-8" href="/grandstand/stylesheets/wysiwyg.css" media="screen"  rel="stylesheet" type="text/css" />');
});
