require('selection');
require('mustache');

jQuery.fn.wysiwyg = function(template, rootSelector) {
  var editor;
  this.each(function() {
    editor = new Editor(this, template, rootSelector);
  });
  return editor;
};

var Editor = function(textarea, template, rootSelector) {
  // Load up mustache
  this.template = template;
  // Find the element we should make editable. Defaults to the BODY element
  // once we've rendered the template.
  this.rootSelector = rootSelector || 'body';
  this.textarea = $(textarea);
  this.container = $('<div class="wysiwyg"></div>');
  this.toolbar = $('<div class="toolbar"></div>').hide();
  // this.container.append(this.toolbar);
  var toolbarItems = [
    {id: 'bold', alt: 'Make text bold'},
    {id: 'italic', alt: 'Make text italic'},
    {id: 'hyperlink', alt: 'Insert a link'},
    {id: 'unordered_list', alt: 'Insert a bullet list'},
    {id: 'ordered_list', alt: 'Insert a numbered list'},
    {id: 'gallery', alt: 'Embed a gallery'},
    {id: 'image', alt: 'Embed an image'}
  ];
  var editor = this;
  // $.each(toolbarItems, function() {
  //   var button = $('<a class="button" rel="' + this.id + '" title="' + this.alt + '"><span class=" icon ' + this.id.replace('_', '-') + '"></span></a>');
  //   button.click(function() {
  //     editor.buttonClick(button);
  //   });
  //   editor.toolbar.append(button);
  // });
  this.iframe = $('<iframe frameBorder="0" id="' + textarea.id + '_editor"></iframe>').hide();
  this.container.height(this.textarea.height() + 6.0);
  this.textarea.height(this.textarea.height() + 5.0);
  this.container.append(this.iframe);
  this.startLoading();
  this.textarea.after(this.container);
  this.container.append(this.textarea);
  $.get('/grandstand/templates/' + template, function(response) {
    editor.template = response;
    editor.initialize();
  });
};

Editor.prototype = {
  buttonClick: function(button) {
    switch(button.attr('rel')) {
      case 'bold':
        var selection = this.selection();
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
        this.document.execCommand('CreateLink', false, prompt("Please enter an URL:"));
      break;
      case 'unordered_list':
        this.document.execCommand('InsertUnorderedList', false, null);
      break;
      case 'ordered_list':
        this.document.execCommand('InsertOrderedList', false, null);
      break;
      case 'gallery':
        this.dialog('/grandstand/galleries', function() {

        }, function() {
        
        });
      break;
      case 'image':
      this.dialog('/grandstand/galleries?image=yup', function(dialog) {
        var editor = this;
        dialog.find('.image').click(function(event) {
          event.preventDefault();
          var image = $(this).find('img');
          image = image.clone();
          image.addClass('left');
          editor.closeDialog();
          var imageWrap = $('<div></div>');
          imageWrap.append(image);
          editor.selection().insert(imageWrap.html());
        });
      }, function() {
        
      });
      break;
    }
  },
  closeDialog: function(block) {
    var dialogs = this.container.find('.dialog');
    if (dialogs.length === 0) {
      if (block) {
        block.call(this);
      }
    } else {
      var editor = this;
      dialogs.animate({top: -(dialogs.height())}, 300, function() {
        $(this).remove();
        if (block) {
          block.call(editor);
        }
      });
    }
  },
  // Loads up a dialog box using AJAX contents, and animates it in over top of the editor.
  // 
  // `onLoad` will be called when the contents is loaded, and `this` will be the editor
  // instance, and the only argument passed will be the dialog DIV. This allows you to
  // define behavior for the dialog's controls.
  // 
  // `onSubmit` is called when the user submits the form. `this` will be the editor instance
  // (like onLoad), and the only argument passed will be an Object corresponding to the form
  // elements. So a form like:
  // 
  // "image[caption]=I am an image Caption&image[align]=left" will be:
  // 
  // {image: {caption: "I am an image", align: "left"}}
  // 
  dialog: function(url, onLoad, onSubmit) {
    var editor = this;
    // Setup a dialog container
    var dialog = $('<div class="dialog"></div>');
    // Setup a method to wrap the dialog. If the plugin passes a string, we'll render a
    // dialog with the contents at that URL. If it passes an object, we'll just append it
    // to `dialog` and display IT.
    var processDialog = function() {
      editor.container.append(dialog.hide());
      var top = editor.toolbar.outerHeight();
      dialog.css('height', editor.container.height() - top * 2);
      if (onLoad && typeof(onLoad) == 'function') {
        onLoad.call(editor, dialog);
      }
      dialog.css('top', -(dialog.height()) + top).show().animate({top: top}, 300);
      dialog.find('form').submit(function(event) {
        event.preventDefault();
        if (onSubmit && typeof(onSubmit) == 'function') {
          onSubmit.call(editor, $(this).serialize());
        }
      });
    };
    if (typeof(url) == 'string') {
      editor.startLoading();
      $.get(url, function(response) {
        response = $(response);
        dialog.append(response);
        editor.closeDialog(function() {
          editor.stopLoading();
          processDialog.call(editor);
        });
      });
    } else {
      dialog.append(url);
      editor.closeDialog(processDialog);
    }
  },
  editImage: function(image) {
    image = $(image);
    var form = $('<form class="pad"></form>');
    form.append(image.clone());
    this.dialog(form, false, function() {
      alert('okay!');
    });
  },
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
    this.toolbar.show();
    this.iframe.height(this.textarea.height() - this.toolbar.height() - 4);
    this.iframe.show();
    this.root = $(this.document).find(this.rootSelector);
    this.root.find('img').live('click', function(event) {
      event.preventDefault();
      event.stopPropagation();
      editor.editImage(this);
    });
    $([this.iframe, this.root, this.document.body]).click(function(event) {
      console.log(event.target);
      if ($(event.target).childOf(editor.root)) {
        return;
      } else {
        event.preventDefault();
        editor.closeDialog();
        editor.focus(':block:last', -1);
      }
    });
    $([this.document, document]).keyup(function(event) {
      if (event.keyCode == 27) {
        editor.closeDialog();
        editor.focus();
      } else {
        editor.selection().normalize();
      }
    });
    var pasting;
    this.root.keyup(function() {
      clearTimeout(editor.timeout);
      editor.timeout = setTimeout(function() { editor.save(); }, 100);
      if (pasting) {
        var before = $('<div></div>').html(pasting.shift()).html(), after = $('<div></div>').html(pasting.shift()).html();
        console.log(after);
      }
      pasting = false;
    }).keydown(function(event) {
      if (event.keyCode == 13) {
        // If a user hits "Enter", we'll hijack the event and clean it up just a little bit
        var selection = editor.selection();
        if (event.shiftKey) {
          // If the user held shift and pressed enter, split it with a line break
          selection.insert('<br />', true);
        } else {
          // If the selection is inside of a list, let the browser do its magic. In
          // other words: don't interrupt anything; just leave well enough alone.
          if (selection.wrappedIn('li, ol, ul')) {
            return;
          }
          // If we're not inside of an li / ol / ul, default behavior is to split the
          // selected content into two paragraphs, one with the content before the 
          // selection, and another with the content after it.
          selection.split('p');
        }

        event.preventDefault();
        event.stopPropagation();

      } else if (event.keyCode == 86 && (event.metaKey || event.ctrlKey) && !pasting) {
        // If the user is pasting, we'll prep keyUp for the past event. This means we'll
        // set the pasting variable to the HTML content before and after the current selection.
        // Once the content is pasted, we'll parse out WHAT was pasted in, clean it up, and viola!
        // Better content.
        pasting = [editor.selection().beforeAll(), editor.selection().afterAll()];
      }
    });
    this.root.attr('contentEditable', 'true').css('outline', '0');
    // this.document.body.contentEditable = 'true';
    this.focus();
    this.stopLoading();
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
  stopLoading: function() {
    if (this.cover) {
      var cover = this.cover;
      setTimeout(function() {
        cover.fadeOut();
      }, 100);
    }
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
  selection: function() {
    return $(this.window).selection(this.rootSelector);
  },
  write: function(content) {
    if (content == '') {
      content = '<p>&nbsp;</p>';
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

jQuery.fn.childOf = function(a){
  a = (typeof a=='string')?$(a):a;
  return (a.length == 1 && this.length === this.map(function(){if($.inArray(this,a.children())!=-1){return this;}}).length); 
};