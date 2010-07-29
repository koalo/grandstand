$LOAD_PATH = ['/admin/javascripts'];

$(document).ready(function() {
  $('a[data-method]').live('click', function(event) {
    event.preventDefault();
    var link = $(this);
    var form = $('<form></form>').attr('action', this.href).attr('method', 'post');
    form.append('<input type="hidden" name="_method" value="' + link.attr('data-method') + '" />');
    var authenticityToken = $('meta[name=csrf-token]').attr('content');
    form.append('<input type="hidden" name="authenticity_token" value="' + authenticityToken + '"/>');
    $(document.body).append(form);
    form.submit();
  });

  $('a.expand').live('click', function(event) {
    event.preventDefault();
    var link = $(this);
    var li = link.parents('li');
    var ul = li.find('ul');
    var add;
    if (li.hasClass('expanded')) {
      ul.css('display', 'block');
      li.removeClass('expanded');
      ul.slideUp(100);
      add = false;
    } else {
      ul.hide();
      li.addClass('expanded');
      ul.slideDown(100);
      add = true;
    }
    $.get('/admin/expand?add=' + (add ? 'yup' : 'nope') + '&section=' + link.attr('rel'));
  });

  $('#cover').click(function() {
    $(this).fadeOut(200);
    var pulldown = $('#pulldown');
    if (pulldown.css('display') != 'none') {
      pulldown.animate({top: -(pulldown.height())}, 300, function() {
        pulldown.hide();
      });
    }
  });

  $('#pulldown a.cancel').live('click', function(event) {
    event.preventDefault();
    $('#cover').click();
  });

  $('.remote').live('click', function(event) {
    $('#cover').fadeIn(100);
    event.preventDefault();
    $.get(this.href, function(response) {
      var pulldown = $('#pulldown');
      pulldown.html(response);
      if (pulldown.css('display') == 'none') {
        pulldown.css('top', -(pulldown.height())).show().animate({top: 0}, 300);
      }
    });
  });

  $('.galleries.sortable').sortable({
    handle: '.float-left',
    items: '.container',
    stop: function(event, ui) {
      $.post('/admin/galleries/reorder', $(this).sortable('serialize'), function() {
        Flash.show('notice', "Your changes have been saved!");
      });
    }
  });

  $('.images.sortable').sortable({
    handle: '.float-left',
    items: '.container',
    stop: function(event, ui) {
      $.post(window.location.toString() + '/images/reorder', $(this).sortable('serialize'), function() {
        Flash.show('notice', "Your changes have been saved!");
      });
    }
  });

  $('.container.gallery a').mousemove(function(event) {
    var link = $(this);
    var width = link.width();
    var images = link.parent().children('img');
    var segment = width / images.length;
    var index = Math.max(Math.ceil(event.offsetX / segment), 1);
    var image = $(images[index - 1]);
    var active = link.find('img');
    if (active.attr('src') != image.attr('src')) {
      active.attr('src', image.attr('src'));
    }
  });

  $('#uploads').livequery(function() {
    var uploads = $(this);
    if (uploads.length > 0) {
      var form = uploads.parents('form');
      var data = {}
      $.each(form.serializeArray(), function() {
        data[this.name] = this.value;
      });
      form.find('.toolbar').empty().flash(
        {
          align: 'center',
          flashvars: {action: form.attr('action'), method: form.attr('method').toUpperCase(), data: $.param(data)},
          height: 24,
          id: 'uploads-flash',
          src: '/admin/images/uploader.swf',
          width: 118,
          wmode: 'transparent'
        }
      );
      Upload.element = document.getElementById('uploads-flash');
      Upload.list = uploads;
    }
  });

  $('.tabset').tabs();

  $('.wysiwyg').dependency('wysiwyg', function() {
    this.wysiwyg('post', this.attr('id') == 'post_body' ? '.post' : null);
  });

  $('.source a').live('click', function(event) {
    event.preventDefault();
    var link = $(this);
    if (link.hasClass('active')) {
      return;
    }
    var source = link.parents('.source');
    var destination = source.nextAll('.destination');
    var active = source.find('a.active');
    active.removeClass('active');
    link.addClass('active');
    $('#' + active.attr('rel')).hide();
    $('#' + link.attr('rel')).show();    
  });

  Flash.hideAll();
});

var Upload = {
  // Every file is done; move on with our lives
  allComplete: function() {
    window.location = window.location;
  },
  // Called when someone clicks a "cancel this event" button
  cancel: function(event) {
    
  },
  // Called AFTER we've successfully cancelled, but we initiate the cancelling.
  cancelled: function() {
    
  },
  // Called for each file that's queued for upload
  fileAdded: function(file) {
    var item = $('<tr class="item" id="' + Upload.idFor(file.name) + '"></tr>');
    item.append('<td class="image icon">' + file.name + '</td>');
    item.append('<td class="progress-bar"><div class="progress"></div></td>');
    item.append('<td style="width:20px;"><a class="delete icon"></a></td>');
    item.find('a.delete').click(function(event) {
      event.preventDefault();
      var link = $(this);
      if (link.hasClass('cancel')) {
        $(this).parents('tr.item').remove();
        Upload.stripe();
        Upload.element.cancelFile(file);
      }
    });
    Upload.list.find('tbody').append(item);
  },
  // Called the moment all of the queued files are done being added. We'll start the
  // upload when this event occurs.
  filesAdded: function() {
    Upload.stripe();
    Upload.list.slideDown(200, function() {
      Upload.element.upload();
    });
  },
  // Called when an individual upload finishes. We'll have to move our pointer forward
  // here.
  fileCompleted: function(event) {
    var row = Upload.rowFor(event.target.name);
    row.find('.progress-bar').addClass('complete');
    row.find('.delete').removeClass('delete').addClass('okay');
  },
  fileError: function(event) {
    var row = Upload.rowFor(event.target.name)
    row.find('.progress-bar').addClass('complete');
    row.find('.icon').removeClass('delete').addClass('error');
  },
  fileProgress: function(event) {
    var progress = Upload.rowFor(event.target.name).find('.progress');
    progress.animate({width: (event.bytesLoaded / event.bytesTotal * 100).toString() + '%'}, 50);
  },
  fileStarted: function(event) {

  },
  idFor: function(name) {
    return 'file-' + name.toLowerCase().replace(/[^0-9a-z]/ig, '');
  },
  rowFor: function(name) {
    return $('#' + Upload.idFor(name));
  },
  stripe: function() {
    Upload.list.find('tbody').find('tr').removeClass('odd');
    Upload.list.find('tbody').find('tr:odd').addClass('odd');
  }
};

var Flash = {
  hideAll: function() {
    $('.flash').each(function() {
      var flash = $(this);
      setTimeout(function() {
        flash.fadeOut(200);
      }, 2000);
    });
  },
  show: function(type, message) {
    var flash = $('.flash.' + type);
    if (flash.length === 0) {
      flash = $('<div class="flash ' + type + '"><div class="inner"></div></div>').hide();
      $(document.body).prepend(flash);
    }
    flash.find('.inner').html(message);
    Flash.hideAll();
    return flash.fadeIn(200);
  }
};
