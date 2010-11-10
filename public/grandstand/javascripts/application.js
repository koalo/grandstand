$LOAD_PATH = ['/grandstand/javascripts'];

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
    $.get('/grandstand/expand?add=' + (add ? 'yup' : 'nope') + '&section=' + link.attr('rel'));
  });

  $('form').submit(function() {
    $(this).find('button').attr('enabled', false);
  });

  $('.remote').live('click', function(event) {
    event.preventDefault();
    Dialog.show(this.href);
  });

  $('.galleries.sortable').sortable({
    handle: '.float-left',
    items: '.container',
    stop: function(event, ui) {
      $.post('/grandstand/galleries/reorder', $(this).sortable('serialize'), function() {
        Notifications.show('notice', 'Your changes have been saved!');
      });
    }
  });

  $('.images.sortable').sortable({
    handle: '.float-left',
    items: '.container',
    stop: function(event, ui) {
      $.post(window.location.toString() + '/images/reorder', $(this).sortable('serialize'), function() {
        Notifications.show('notice', 'Your changes have been saved!');
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
          src: '/grandstand/images/uploader.swf',
          width: 118,
          wmode: 'transparent'
        }
      );
      Upload.element = document.getElementById('uploads-flash');
      Upload.list = uploads;
    }
  });

  $('#cover').click(function(event) {
    Dialog.hide();
  });

  $('.tabset').tabs();

  $('.wysiwyg').dependency('wysiwyg', function() {
    this.wysiwyg('post', '.post');
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

  Notifications.hide();

});

var Dialog = {
  hide: function(close) {
    Dialog.unbind();
    if (!close) {
      $('#cover').fadeOut(200);
    }
    var dialog = $('#dialog');
    if (dialog.css('display') != 'none') {
      dialog.animate({top: -(dialog.height())}, 300, function() {
        if (close) {
          close();
        }
        dialog.hide().html('');
      });
    } else {
      close();
    }
  },
  keydown: function(event) {
    if (event.keyCode == 27) {
      $('#dialog a.cancel').addClass('active');
    } else if (event.keyCode == 13) {
      $('#dialog .default').addClass('active');
    }
  },
  keyup: function(event) {
    if (event.keyCode == 27) {
      $('#dialog a.cancel').removeClass('active');
      Dialog.hide();
    } else if (event.keyCode == 13) {
      $('#dialog .default').removeClass('active');
      if ($(event.target).parents('form').length === 0 && !$(event.target).is('form')) {
        Dialog.submit();
      }
    }
  },
  show: function(content, options) {
    var cover = $('#cover');
    cover.fadeIn(100);
    var options = options || {};
    var dialog = $('#dialog');
    dialog.removeClass();
    if (options.style) {
      dialog.addClass(options.style);
    }
    var process = function(content) {
      dialog.html(content);
      dialog.find('a.cancel').click(function(event) {
        event.preventDefault();
        Dialog.hide();
      });
      if (options.load) {
        options.load(dialog);
      }
      $(document).keydown(Dialog.keydown).keyup(Dialog.keyup);
      if (options.submit) {
        dialog.find('form').submit(function(event) {
          return options.submit.call(this, event);
        });
      }
      if (dialog.css('display') == 'none') {
        dialog.css('top', -(dialog.height())).show().animate({top: 0}, 300, function() {
          cover.removeClass('loading');
          if (options.complete) {
            options.complete.call(this);
          }
        });
      } else {
        cover.removeClass('loading');
      }
    }
    if (typeof(content) == 'string' && content.toString().match(/^http(s)*:\/\//) || content.toString().match(/^\//)) {
      cover.addClass('loading');
      $.get(content, function(response) {
        process(response);
      });
    } else {
      process(content);
    }
  },
  submit: function() {
    Dialog.unbind();
    $('#dialog form').submit();
  },
  unbind: function() {
    $(document).unbind('keydown', Dialog.keydown).unbind('keyup', Dialog.keyup);
  }
};

var Notifications = {
  hide: function() {
    $('.notification').each(function() {
      var notification = $(this);
      setTimeout(function() {
        notification.fadeOut(200);
      }, 2000);
    });
  },
  show: function(type, message) {
    var notification = $('.notification.' + type);
    if (notification.length === 0) {
      notification = $('<div class="notification ' + type + '"><div class="inner"></div></div>').hide();
      $(document.body).prepend(notification);
    }
    notification.find('.inner').html(message);
    Notifications.hide();
    return notification.fadeIn(200);
  }
};

var Upload = {
  // Every file is done; move on with our lives
  allComplete: function() {
    window.location = window.location;
  },
  // Called when someone clicks a "cancel this event" button
  cancel: function(event) {
    alert('cancelling the thingy...');
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
    row.find('.delete').removeClass('delete').removeClass('processing').addClass('okay');
  },
  fileError: function(event) {
    var row = Upload.rowFor(event.target.name)
    row.find('.progress-bar').addClass('complete');
    row.find('.icon').removeClass('delete').addClass('error');
  },
  fileProgress: function(event) {
    var row = Upload.rowFor(event.target.name);
    var progress = row.find('.progress');
    var percent = event.bytesLoaded / event.bytesTotal * 100;
    progress.animate({width: percent.toString() + '%'}, 50);
    if (percent == 100) {
      var icon = row.find('.icon');
      if (!icon.hasClass('processing')) {
        progress.parent().addClass('complete');
        row.find('.delete').addClass('processing');
      }
    }
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
