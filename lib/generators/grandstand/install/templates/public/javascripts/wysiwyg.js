require('selection');
require('mustache');

jQuery.fn.wysiwyg = function(template, rootSelector) {
  var editor;
  this.each(function() {
    editor = new WYSIWYG(this, template, rootSelector);
  });
  return editor;
};

var WYSIWYG = function(textarea, template, rootSelector) {
  // Find the element we should make editable. Defaults to the BODY element
  // once we've rendered the template.
  this.rootSelector = rootSelector || 'body';
  this.textarea = $(textarea);
  this.container = $('<div class="wysiwyg"></div>');
  var toolbarItems = [
    {id: 'bold', alt: 'Make text bold'},
    {id: 'italic', alt: 'Make text italic'},
    {id: 'hyperlink', alt: 'Insert a link'},
    {id: 'unordered_list', alt: 'Insert a bullet list'},
    {id: 'ordered_list', alt: 'Insert a numbered list'},
    // {id: 'gallery', alt: 'Embed a gallery'},
    {id: 'image', alt: 'Embed an image'}
  ];
  this.toolbar = new WYSIWYG.Toolbar(this, toolbarItems);
  this.container.append(this.toolbar.container);
  this.iframe = $('<iframe frameBorder="0" id="' + textarea.id + '_editor"></iframe>').hide();
  this.container.height(this.textarea.height() + 6.0);
  this.textarea.height(this.textarea.height() + 5.0);
  this.container.append(this.iframe);
  this.startLoading();
  this.textarea.after(this.container);
  this.container.append(this.textarea);
  var editor = this;
  $.get('/grandstand/templates/' + template, function(response) {
    editor.template = response;
    editor.initialize();
  });
};

WYSIWYG.prototype = {
  focus: function(selector, offset) {
    var selection = this.selection();
    selection.select(selector || ':block', offset || 0);
  },
  initialize: function() {
    var editor = this;
    try {
      this.window = this.iframe[0].contentWindow;
      this.document = this.window.document;
    } catch(exception) {
      return setTimeout(function(){ editor.initialize(); }, 10);
    }
    this.write(this.textarea.val());
    this.body = this.document.body;
    // Make sure all data is saved, no matter what.
    this.textarea.parents('form').submit(function() {
      editor.save();
    });
    this.textarea.hide();
    this.toolbar.container.show();
    this.iframe.height(this.textarea.height() - this.toolbar.container.height() - 4);
    this.iframe.show();
    this.root = $(this.document).find(this.rootSelector);
    this.root.css('height', '100%');
    this.root.find('img').live('click', function(event) {
      event.preventDefault();
      event.stopPropagation();
      var img = $(this);
      var ids = this.src.match(/\d\d\d\d\d\d/ig);
      var url = '/grandstand/galleries/' + ids[0].replace(/^0+/, '') + '/images/' + ids[1].replace(/^0+/, '');
      url += '?align=' + this.className + '&size=' + this.src.substring(this.src.lastIndexOf(ids[1]) + 7, this.src.lastIndexOf('.'));
      Dialog.show(url, {
        style: 'medium',
        submit: function(event) {
          event.preventDefault();
          // Grab the right form, thanks a lot IE...
          var form = $(event.target);
          if (!form.is('form')) {
            form = form.parents('form');
          }
          img.removeClass().addClass(form.find('input[name=align]:checked').val());
          img.load(function() {
            img.attr('height', img.height());
            img.attr('width', img.width());
          });
          img.attr('src', form.find('input[name=size]:checked').val());
          img.removeAttr('height');
          img.removeAttr('width');
          Dialog.hide();
        }
      });
    });
    // $([this.document, document]).keyup(function(event) {
    //   editor.selection().normalize();
    // });
    var pasting, selection;
    this.root.keyup(function(event) {
      selection = editor.selection();
      if (editor.root.find('p').length === 0) {
        // Ensure we're using paragraphs and not line breaks when writing
        if (editor.root.text().replace(/\s+/ig, '') == '') {
          editor.root.html('<p></p>');
          selection.select('p');
        } else {
          selection.selectAll();
          selection.wrap('p');
          selection.select('p', 1);
        }
      }
      clearTimeout(editor.timeout);
      editor.timeout = setTimeout(function() { editor.save(); }, 100);
      if (selection.wrappedIn('strong')) {
        editor.toolbar.on('bold');
      } else {
        editor.toolbar.off('bold');
      }
      if (selection.wrappedIn('em')) {
        editor.toolbar.on('italic');
      } else {
        editor.toolbar.off('italic');
      }
    }).bind('paste', function(event) {
      var clipboard;
      if (event.originalEvent.clipboardData) {
        clipboard = event.originalEvent.clipboardData;
      } else if (typeof(Components) != 'undefined' && Components.interfaces.nsIClipboard) {
        // return true;
        // 
        // TODO: Handle Firefox's ABYSMAL onPaste support with signed JavaScript or some equally pointless bullshit.
        // Hey, Firefox! If someone *pastes*, let me see what they *pasted*, you fucking bastard!
        // 
        // var clip = Components.classes["@mozilla.org/widget/clipboard;1"].getService(Components.interfaces.nsIClipboard);
        // // if (!clip) return false;
        // 
        // var trans = Components.classes["@mozilla.org/widget/transferable;1"].createInstance(Components.interfaces.nsITransferable);
        // // if (!trans) return false;
        // trans.addDataFlavor("text/unicode");
        // 
        // clip.getData(trans, clip.kGlobalClipboard);
        // 
        // var str = new Object();
        // var strLength = new Object();
        // trans.getTransferData("text/unicode", str, strLength);
      } else if (window.clipboardData) {
        clipboard = window.clipboardData;
      }
      if (clipboard) {
        selection = editor.selection();
        var text = clipboard.getData('text/plain').toString().split(/(\n|\r){2,}/igm);
        if (text.length > 0) {
          selection.replace(text.shift().clean());
          $.each(text.reverse(), function() {
            selection.endBlock().after('<p>' + this.clean() + '</p>');
          });
          return false;
        }
      }
    });
    this.root.attr('contentEditable', 'true').css('outline', '0');
    // this.document.body.contentEditable = 'true';
    this.focus();
    this.stopLoading();
  },
  save: function() {
    var html = this.root.html();

    // Clean that HTML good
    html = html.replace(/<DIV><BR class="khtml-block-placeholder"><\/DIV>/ig, '<br />');
    html = html.replace(/<[^> ]*/ig, function(match) {
      return match.toLowerCase();
    });
    html = html.replace(/<[^>]*>/ig, function(match) {
      match = match.replace(/ [^=]+=/ig, function(match2) {
        return match2.toLowerCase();
      });
      return match;
    });
    html = html.replace(/<[^>]*>/ig, function(match) {
      match = match.replace(/( [^=]+=)([^"][^ >]*)/ig, "$1\"$2\"");
      return match;
    });
    html = html.replace(/^\s+/, "");
    html = html.replace(/\s+$/, "");
    html = html.replace(/<br>/ig, "<br />");
    html = html.replace(/<br \/>\s*<\/(h1|h2|h3|h4|h5|h6|li|p)/ig, "</$1");
    html = html.replace(/(<img [^>]+[^\/])>/ig, "$1 />");
    html = html.replace(/(<[^\/]>|<[^\/][^>]*[^\/]>)\s*<\/[^>]*>/ig, "");

    this.textarea.val(html);
  },
  // Called when the editor is loaded up for the first time and off finding dependencies / etc.
  // Just puts a white cover over the textarea and waits for everything to load before saying,
  // "okay, now you can edit"
  startLoading: function() {
    if (!this.cover) {
      this.cover = $('<div class="cover"></div>');
      this.loading = $('<div class="loading"></div>');
      this.cover.append(this.loading);
      this.container.append(this.cover);
    }
    this.cover.show();
  },
  selection: function() {
    return $(this.window).selection(this.rootSelector);
  },
  stopLoading: function() {
    if (this.cover) {
      var cover = this.cover;
      this.cover = false;
      setTimeout(function() {
        cover.fadeOut(function() {
          cover.remove();
        });
      }, 100);
    }
  },
  write: function(content) {
    if (content == '') {
      content = '<p><br /></p>';
    }
    var rendered = Mustache.to_html(this.template, {body: content});
    var html = '<html><head><link href="/grandstand/stylesheets/wysiwyg-content.css" rel="stylesheet" type="text/css" /></head>';
    html += '<body class="wysiwyg">';
    html += rendered;
    html += '</body>';
    html += '</html>';
    this.document.open();
    this.document.write(html);
    this.document.close();
  }
};

WYSIWYG.Toolbar = function(editor, buttons) {
  this.editor = editor;
  this.container = $('<div class="toolbar"></div>').hide();
  var toolbar = this;
  $.each(buttons, function() {
    var button = $('<a class="button" rel="' + this.id + '" title="' + this.alt + '"><span class=" icon ' + this.id.replace('_', '-') + '"></span></a>');
    button.click(function() {
      toolbar.buttonClick(button);
    });
    toolbar.container.append(button);
  });
}

WYSIWYG.Toolbar.prototype = {
  buttonClick: function(button) {
    switch(button.attr('rel')) {
      case 'bold':
        var selection = this.editor.selection();
        if (selection.wrappedIn('strong')) {
          selection.unwrap('strong');
        } else {
          selection.wrap('strong');
        }
        // this.document.execCommand('bold', false, null);
      break;
      case 'italic':
      break;
      case 'hyperlink':
        this.editor.document.execCommand('CreateLink', false, prompt("Please enter an URL:"));
      break;
      case 'unordered_list':
        this.editor.document.execCommand('InsertUnorderedList', false, null);
      break;
      case 'ordered_list':
        this.editor.document.execCommand('InsertOrderedList', false, null);
      break;
      case 'gallery':
        Dialog.show('/grandstand/galleries', {
          load: function() {
            
          }
        });
      break;
      case 'image':
        var editor = this.editor;
        Dialog.show('/grandstand/galleries', {
          style: 'large',
          load: function(dialog) {
            dialog.find('.image').click(function(event) {
              event.preventDefault();
              var image = $(this).find('img');
              image = image.clone();
              image.addClass('left');
              editor.selection().insert(image);
              Dialog.hide(function() {
                image.click();
              });
            });
          }
        });
      break;
    }
  },
  off: function(buttonName) {
    this.container.find('a.button[rel=' + buttonName + ']').removeClass('button-hover');
  },
  on: function(buttonName) {
    this.container.find('a.button[rel=' + buttonName + ']').addClass('button-hover');
  }
}

jQuery.fn.childOf = function(a){
  a = (typeof a=='string')?$(a):a;
  return (a.length == 1 && this.length === this.map(function(){if($.inArray(this,a.children())!=-1){return this;}}).length); 
};
